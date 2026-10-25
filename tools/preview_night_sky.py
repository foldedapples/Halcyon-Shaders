#!/usr/bin/env python3
"""
Offline previews and checks of the night sky (lib/atmosphere/sky/stars.glsl).

NOT in-game renders: this runs the pack's own GLSL (stars.glsl, celestial.glsl,
aurora.glsl with their real textures) in a full-screen fragment shader on the
local GPU through an OpenGL 4.3 context, with a simple stand-in for the
atmosphere (exponential extinction) and a fixed exposure + Reinhard curve
instead of Halcyon's auto exposure and tone mapper. Unlike glpreview.py it
works on Windows (moderngl creates a hidden WGL context), so it also compiles
the code with the real NVIDIA/AMD/Intel driver.

  python tools/preview_night_sky.py views  OUT_DIR   # PNG views (see VIEWS)
  python tools/preview_night_sky.py verify           # orientation + photometry checks

verify computes where named stars must appear with textbook alt/az formulas
(latitude from sunPathRotation, sidereal time from NIGHT_SKY_SEASON) and checks
that the GPU render puts their points there, with the right brightness order.
That catches a mirrored or rotated sky, which no compiler would.

Requires: pip install moderngl numpy pillow
"""
import math
import os
import re
import sys

import numpy as np

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "shaders"))
INCLUDE_RE = re.compile(r'^\s*#include\s+"([^"]+)"')


def resolve(path, overrides, stack=()):
    full = os.path.join(ROOT, path.lstrip("/"))
    src = open(full, encoding="utf-8").read()
    for name, val in overrides.items():
        pat = re.compile(r"^(\s*)(//\s*)?#define\s+" + re.escape(name) + r"\b(.*)$", re.M)
        if val is None:
            src = pat.sub(lambda m: f"{m.group(1)}// #define {name}", src)
        elif val is True:
            src = pat.sub(lambda m: f"{m.group(1)}#define {name}", src)
        else:
            src = pat.sub(lambda m: f"{m.group(1)}#define {name} {val}", src)
            cpat = re.compile(r"^(\s*const\s+\w+\s+" + re.escape(name) + r"\s*=\s*)[^;]+;", re.M)
            src = cpat.sub(lambda m: f"{m.group(1)}{val};", src)
    out = []
    for line in src.splitlines():
        m = INCLUDE_RE.match(line)
        if m:
            out.append(resolve(m.group(1), overrides, stack + (path,)))
        else:
            out.append(line)
    return "\n".join(out)


STUBS = """
#define WORLD_OVERWORLD
#define fsh
uniform float frameTimeCounter, rainStrength, wetness, viewWidth, viewHeight, uFov;
uniform int moonPhase, worldDay, worldTime, frameCounter;
uniform sampler2D perlinNoiseTex, moonTex, milkyWayTex, starCatalogTex, blueNoiseTex;
uniform vec3 uSunDir, uCenter;
uniform float uExposure, uAurora, uFisheye;
mat4 gbufferProjection = mat4(1.0 / uFov);
vec3 worldSunDir = normalize(uSunDir);
const vec3 sunIrradiance = vec3(1.0, 0.949, 0.937) * 126e3 * 1e-6;
const vec3 moonIrradiance = vec3(0.86, 0.93, 1.0) * 0.0029;
"""

BODY = """
in vec2 uv;
layout(location = 0) out vec4 o;
vec3 viewRay() {
  vec2 ndc = uv * 2.0 - 1.0;
  if (uFisheye > 0.5) {
    // equidistant all-sky fisheye, zenith in the middle, north up, east LEFT
    // (as a sky chart held overhead)
    float r = length(ndc);
    if (r > 1.0) return vec3(0.0, -1.0, 0.0);
    float th = r * 0.5 * PI;
    vec2 d = ndc / max(r, 1e-6);
    return vec3(-d.x * sin(th), cos(th), -d.y * sin(th));
  }
  vec3 f = normalize(uCenter);
  vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0)) + vec3(1e-5, 0, 0));
  vec3 u = cross(r, f);
  return normalize(f + (ndc.x * r * (viewWidth / viewHeight) + ndc.y * u) * uFov);
}
void main() {
  vec3 rd = viewRay();
  // stand-in atmosphere: Rayleigh + aerosol extinction along the airmass
  float airmass = 1.0 / max(rd.y + 0.025, 0.025);
  vec3 T = rd.y < -0.01 ? vec3(0.0) : exp(-vec3(0.09, 0.14, 0.25) * min(airmass, 40.0));
  vec3 stars;
  vec3 sky = (nightSky(rd, uAurora, 0.0, stars) + stars) * T + vec3(3e-6, 4e-6, 7e-6);
  if (rd.y < 0.0) sky = vec3(2e-6);
  o = vec4(sky, 1.0);
}
"""

TONEMAP_EXPOSURE = 220.0


def build(overrides):
    parts = [
        "#version 430 compatibility",
        resolve("/lib/common/settings.glsl", overrides),
        resolve("/lib/common/syntax.glsl", overrides),
        STUBS,
        resolve("/lib/common/util.glsl", overrides),
        resolve("/lib/atmosphere/sky/celestial.glsl", overrides),
        resolve("/lib/atmosphere/sky/aurora.glsl", overrides),
        resolve("/lib/atmosphere/sky/stars.glsl", overrides),
        BODY,
    ]
    return "\n".join(parts)


class Renderer:
    def __init__(self, tex_res=8192):
        import moderngl
        from PIL import Image
        self.ctx = moderngl.create_standalone_context(require=430)
        print("GL:", self.ctx.info["GL_RENDERER"], self.ctx.info["GL_VERSION"])
        mw = Image.open(os.path.join(ROOT, f"textures/milkyway_{tex_res // 1024}k.png")).convert("RGB")
        self.mw = self.ctx.texture(mw.size, 3, mw.tobytes())
        self.mw.filter = (moderngl.LINEAR, moderngl.LINEAR)
        self.mw.repeat_x = self.mw.repeat_y = True
        raw = np.fromfile(os.path.join(ROOT, "textures/starCatalog.bin"), dtype="<f4")
        rows = raw.size // (1024 * 4)
        self.cat = self.ctx.texture((1024, rows), 4, raw.tobytes(), dtype="f4")
        self.cat.filter = (moderngl.NEAREST, moderngl.NEAREST)
        noise = Image.open(os.path.join(ROOT, "textures/perlinNoise.png")).convert("RGBA")
        self.noise = self.ctx.texture(noise.size, 4, noise.tobytes())
        self.noise.repeat_x = self.noise.repeat_y = True
        self.vbo = self.ctx.buffer(np.array([-1, -1, 3, -1, -1, 3], dtype="f4").tobytes())
        self.programs = {}

    def program(self, overrides):
        key = tuple(sorted(overrides.items()))
        if key not in self.programs:
            vs = "#version 430 compatibility\nin vec2 p; out vec2 uv; void main(){ uv = p * 0.5 + 0.5; gl_Position = vec4(p, 0, 1); }"
            prog = self.ctx.program(vertex_shader=vs, fragment_shader=build(overrides))
            self.programs[key] = (prog, self.ctx.vertex_array(prog, [(self.vbo, "2f", "p")]))
        return self.programs[key]

    def render(self, w, h, uniforms, overrides=None):
        prog, vao = self.program(overrides or {})
        units = {"milkyWayTex": (self.mw, 0), "starCatalogTex": (self.cat, 1),
                 "perlinNoiseTex": (self.noise, 2), "moonTex": (self.noise, 3)}
        for name, (tex, unit) in units.items():
            tex.use(unit)
            if name in prog:
                prog[name].value = unit
        base = dict(frameTimeCounter=100.0, rainStrength=0.0, wetness=0.0, viewWidth=float(w),
                    viewHeight=float(h), moonPhase=4, worldDay=0, worldTime=18000, frameCounter=0,
                    uExposure=1.0, uAurora=0.0, uFisheye=0.0)
        base.update(uniforms)
        for k, v in base.items():
            if k in prog:
                prog[k].value = v
        fbo = self.ctx.simple_framebuffer((w, h), components=4, dtype="f4")
        fbo.use()
        fbo.clear()
        vao.render()
        img = np.frombuffer(fbo.read(components=4, dtype="f4"), dtype="f4").reshape(h, w, 4)[..., :3]
        fbo.release()
        return img


def to_png(img, path, exposure=TONEMAP_EXPOSURE):
    from PIL import Image
    c = img * exposure
    c = c / (1.0 + c)
    c = np.clip(c, 0, 1) ** (1 / 2.2)
    Image.fromarray((c[::-1] * 255 + 0.5).astype(np.uint8), "RGB").save(path)


def sun_dir(theta_deg, path_rotation=-40.0):
    """Iris celestial transform: YP(-90) * ZP(sunPathRotation) * XP(skyAngle)."""
    t, r = math.radians(theta_deg), math.radians(path_rotation)
    return (-math.sin(t), math.cos(t) * math.cos(r), -math.cos(t) * math.sin(r))


def theta_for_sun_altitude(alt_deg, evening=True, path_rotation=-40.0):
    c = math.sin(math.radians(alt_deg)) / math.cos(math.radians(path_rotation))
    t = math.degrees(math.acos(max(-1.0, min(1.0, c))))
    return t if evening else -t


def look(az_deg, alt_deg):
    """az from north through east; Minecraft north = -z, east = +x."""
    az, alt = math.radians(az_deg), math.radians(alt_deg)
    return (math.cos(alt) * math.sin(az), math.sin(alt), -math.cos(alt) * math.cos(az))


VIEWS = [
    ("allsky_summer_midnight", None, 0, 180.0, {}, {}),
    ("allsky_winter_midnight", None, 0, 180.0, {"NIGHT_SKY_SEASON": 2}, {}),
    ("south_core_70fov", (180, 22), 70, 180.0, {}, {}),
    ("overhead_cygnus_70fov", (150, 65), 70, 180.0, {}, {}),
    ("zoom_cygnus_15fov", (60, 80), 15, 180.0, {}, {}),
    ("zoom_orion_20fov", (180, 35), 20, 180.0, {"NIGHT_SKY_SEASON": 2}, {}),
    ("style_astrophotography", (180, 22), 70, 180.0, {"MILKY_WAY_STYLE": 1}, {}),
    ("style_cinematic", (180, 22), 70, 180.0, {"MILKY_WAY_STYLE": 2}, {}),
    ("full_moon_up", (180, 22), 70, 180.0, {}, {"moonPhase": 0}),
    ("aurora_strong", (0, 30), 70, 180.0, {"AURORA_FREQUENCY": 4}, {"uAurora": 1.0}),
    ("density_0.5_naked_eye", (180, 22), 70, 180.0, {"STAR_DENSITY": 0.5}, {}),
    ("filter_0_bilinear", (150, 65), 70, 180.0, {"MILKY_WAY_FILTER": 0}, {}),
]


def views(out_dir, w=1280, h=720):
    os.makedirs(out_dir, exist_ok=True)
    rnd = Renderer()
    for name, center, fov, theta, ov, extra in VIEWS:
        u = dict(uSunDir=sun_dir(theta), **extra)
        if center is None:
            u.update(uFisheye=1.0, uFov=math.pi / 2, uCenter=(0.0, 1.0, 0.0))
            img = rnd.render(h, h, u, ov)
        else:
            u.update(uFov=math.tan(math.radians(fov / 2)), uCenter=look(*center))
            img = rnd.render(w, h, u, ov)
        to_png(img, os.path.join(out_dir, name + ".png"))
        print("wrote", name)
    for alt in (-3, -7, -11, -15, -20):
        u = dict(uSunDir=sun_dir(theta_for_sun_altitude(alt)), uFov=math.tan(math.radians(35)),
                 uCenter=look(110, 35))
        to_png(rnd.render(w, h, u), os.path.join(out_dir, f"twilight_sun{alt}.png"))
        print("wrote twilight", alt)
    for name, (ww, hh) in (("res_1080p", (1920, 1080)), ("res_2160p", (3840, 2160))):
        u = dict(uSunDir=sun_dir(180.0), uFov=math.tan(math.radians(35)), uCenter=look(150, 65))
        img = rnd.render(ww, hh, u)
        to_png(img, os.path.join(out_dir, name + ".png"))
        print(f"{name}: summed sky radiance x pixel solid angle = {img.sum() * (2 * math.tan(math.radians(35)) / hh) ** 2:.4g}")


NAMED = [
    ("Sirius", 101.287, -16.716, -1.44),
    ("Betelgeuse", 88.793, 7.407, 0.45),
    ("Rigel", 78.634, -8.202, 0.18),
    ("Bellatrix", 81.283, 6.350, 1.64),
    ("Aldebaran", 68.980, 16.509, 0.87),
    ("Procyon", 114.825, 5.225, 0.40),
    ("Capella", 79.172, 45.998, 0.08),
    ("Polaris", 37.955, 89.264, 1.97),
]


def expected_dir(ra, dec, lst, lat):
    h = math.radians(lst - ra)
    d, p = math.radians(dec), math.radians(lat)
    alt = math.asin(math.sin(p) * math.sin(d) + math.cos(p) * math.cos(d) * math.cos(h))
    az = math.atan2(-math.cos(d) * math.sin(h), math.sin(d) * math.cos(p) - math.cos(d) * math.cos(h) * math.sin(p))
    return look(math.degrees(az), math.degrees(alt)), math.degrees(alt), math.degrees(az)


def project(d, center, fov_tan, w, h):
    f = np.array(center) / np.linalg.norm(center)
    r = np.cross(f, [0, 1, 0]) + [1e-5, 0, 0]
    r /= np.linalg.norm(r)
    u = np.cross(r, f)
    d = np.array(d)
    z = d @ f
    if z <= 0:
        return None
    x = (d @ r) / z / fov_tan / (w / h)
    y = (d @ u) / z / fov_tan
    return ((x + 1) * 0.5 * w - 0.5, (y + 1) * 0.5 * h - 0.5)


def verify():
    rnd = Renderer()
    w, h = 1600, 1200
    ok = True
    lst, lat = 90.0, 40.0
    checks = [((175, 40), 80.0, ["Sirius", "Betelgeuse", "Rigel", "Bellatrix", "Aldebaran", "Procyon"]),
              ((0, 40), 30.0, ["Polaris"]),
              ((0, 80), 60.0, ["Capella"])]
    for center_azalt, fov, names in checks:
        center = look(*center_azalt)
        ft = math.tan(math.radians(fov / 2))
        img = rnd.render(w, h, dict(uSunDir=sun_dir(180.0), uFov=ft, uCenter=center),
                         {"NIGHT_SKY_SEASON": 2, "MILKY_WAY": None, "STAR_TWINKLE": None, "STAR_BLOOM": 0.0})
        lum = img @ np.array([0.2126, 0.7152, 0.0722])
        pixel_sr = (2.0 * ft / h) ** 2
        for name, ra, dec, v in [s for s in NAMED if s[0] in names]:
            d, alt, az = expected_dir(ra, dec, lst, lat)
            p = project(d, center, ft, w, h)
            if p is None or not (6 < p[0] < w - 7 and 6 < p[1] < h - 7):
                print(f"  BAD {name}: outside the view (alt {alt:.1f} az {az:.1f})")
                ok = False
                continue
            x, y = int(round(p[0])), int(round(p[1]))
            win = lum[y - 6:y + 7, x - 6:x + 7]
            peak = np.unravel_index(np.argmax(win), win.shape)
            off = math.hypot(peak[1] - 6, peak[0] - 6)
            z = float(np.dot(d, np.array(center) / np.linalg.norm(center)))
            T = math.exp(-0.14 / max(math.sin(math.radians(alt)) + 0.025, 0.025))
            e = float(win.sum()) * pixel_sr * z ** 3 / T
            mag = -2.5 * math.log10(max(e, 1e-30) / 8.5e-7)
            good = off <= 1.5 and abs(mag - v) < 0.15
            ok &= good
            print(f"  {'OK ' if good else 'BAD'} {name:10s} V={v:5.2f} expected alt {alt:5.1f} az {az:6.1f}"
                  f" -> peak offset {off:.1f} px, rendered magnitude {mag:5.2f}")
    print("verify:", "PASSED" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "verify":
        sys.exit(verify())
    if len(sys.argv) >= 3 and sys.argv[1] == "views":
        views(sys.argv[2])
        sys.exit(0)
    print(__doc__)
    sys.exit(2)
