#!/usr/bin/env python3
"""
Offline previews of the volumetric clouds (lib/atmosphere/volumetricClouds.glsl).

NOT in-game renders: the pack's own cloud GLSL runs in a full-screen fragment
shader on the local GPU (moderngl, OpenGL 4.3, works on Windows), with stand-ins
for the rest of the frame:
  - a flat "terrain" plane at y = GROUND (Minecraft-green, lit by the sun and
    the baked-style cloud shadow from getVolumetricCloudShadow) with simple
    aerial haze, so compositing over geometry can be seen;
  - a sky gradient; fixed exposure + Reinhard.
Each frame is a single jittered sample (no temporal accumulation) unless
ACCUM=n is set, which averages n blue-noise-like jitters like the in-game
history does when the camera is still.

  python tools/preview_clouds_gpu.py OUT_DIR [scene ...]

COMPOSITE=sky   composites clouds over sky pixels only (alpha.21 behaviour)
COMPOSITE=all   clips the march at the terrain and composites everywhere
                (the alpha.22 behaviour; needs the maxDist overload)
Requires: pip install moderngl numpy pillow
"""
import math
import os
import re
import sys

import numpy as np

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "shaders"))
INCLUDE_RE = re.compile(r'^\s*#include\s+"([^"]+)"')


def resolve(path, overrides):
    src = open(os.path.join(ROOT, path.lstrip("/")), encoding="utf-8").read()
    for name, val in overrides.items():
        pat = re.compile(r"^(\s*)(//\s*)?#define\s+" + re.escape(name) + r"\b(.*)$", re.M)
        if val is None:
            src = pat.sub(lambda m: f"{m.group(1)}// #define {name}", src)
        elif val is True:
            src = pat.sub(lambda m: f"{m.group(1)}#define {name}", src)
        else:
            src = pat.sub(lambda m: f"{m.group(1)}#define {name} {val}", src)
    out = []
    for line in src.splitlines():
        m = INCLUDE_RE.match(line)
        out.append(resolve(m.group(1), overrides) if m else line)
    return "\n".join(out)


STUBS = """
#define WORLD_OVERWORLD
#define fsh
#define CLOUD_EXTINCTION_COLOR vec3(1.0)
uniform float frameTimeCounter, wetness, thunderStrength, viewWidth, viewHeight;
uniform int worldTime, worldDay, frameCounter;
uniform vec3 cameraPosition;
uniform vec4 lightningBoltPosition;
uniform sampler2D perlinNoiseTex, blueNoiseTex;
uniform sampler3D cloudNoiseTex;
uniform vec3 uSunDir, uSunColor, uSkyColor, uForward;
uniform float uFov, uGround, uComposite, uJitterBase;
uniform int uAccum, uSteps;
vec3 worldLightDir = normalize(uSunDir);
vec3 lightDir = vec3(0.0, 0.0, 1.0);
vec3 sunDir = vec3(0.0, 0.0, 1.0);
vec3 sunlightColor = uSunColor;
vec3 skylightColor = uSkyColor;
float skyMultiplier = 1.0;
mat4 gbufferProjection = mat4(1.0 / uFov);
#define worldTimeCounter ((worldTime / 20.0) + (worldDay * 1200.0))
"""

BODY = """
in vec2 uv; layout(location = 0) out vec4 o;
vec3 viewRay() {
  vec3 f = normalize(uForward);
  vec3 r = normalize(cross(f, vec3(0.0, 1.0, 0.0)) + vec3(1e-5, 0.0, 0.0));
  vec3 u = cross(r, f);
  vec2 ndc = uv * 2.0 - 1.0;
  return normalize(f + (ndc.x * r * (viewWidth / viewHeight) + ndc.y * u) * uFov);
}
void main() {
  vec3 rd = viewRay();
  vec3 sky = mix(vec3(0.55, 0.7, 0.9), vec3(0.15, 0.35, 0.8), clamp(rd.y, 0.0, 1.0)) * uSkyColor * 1.5;
  // terrain plane
  float tg = rd.y < 0.0 ? (uGround - cameraPosition.y) / rd.y : -1.0;
  bool ground = tg > 0.0;
  vec3 scene = sky;
  if (ground) {
    vec3 gp = rd * tg; // feet player pos
    vec3 cs = getVolumetricCloudShadow(gp, 8);
    vec3 albedo = vec3(0.18, 0.32, 0.12);
    vec3 lit = albedo * (uSunColor * 7.5 * max(worldLightDir.y, 0.0) * cs + uSkyColor * 1.2);
    float haze = 1.0 - exp(-tg * 0.0006);
    scene = mix(lit, sky * 0.9, haze);
  }
  vec3 S = vec3(0.0); vec3 T = vec3(0.0);
  for (int i = 0; i < uAccum; i++) {
    float j = fract(interleavedGradientNoise(gl_FragCoord.xy, i) + uJitterBase);
    vec3 Ti;
    vec3 Si;
    if (uComposite > 0.5) {
      Si = getVolumetricClouds(vec3(0.0), rd, uSteps, j, ground ? tg : 1e9, Ti);
    } else {
      Si = ground ? vec3(0.0) : getVolumetricClouds(vec3(0.0), rd, uSteps, j, Ti);
      if (ground) Ti = vec3(1.0);
    }
    S += Si; T += Ti;
  }
  S /= float(uAccum); T /= float(uAccum);
  vec3 col = scene * T + S;
  bool bad = any(isnan(S)) || any(isinf(S)) || any(isnan(T)) || any(isinf(T));
  col *= 6.0;
  o = vec4(pow(col / (1.0 + col), vec3(1.0 / 2.2)), 1.0);
  if (bad) o = vec4(1.0, 0.0, 1.0, 1.0); // magenta: NaN/Inf
}
"""


def build(overrides, composite_all):
    body = BODY if composite_all else BODY.replace(
        "Si = getVolumetricClouds(vec3(0.0), rd, uSteps, j, ground ? tg : 1e9, Ti);",
        "Si = getVolumetricClouds(vec3(0.0), rd, uSteps, j, Ti);")
    return "\n".join([
        "#version 430 compatibility",
        resolve("/lib/common/settings.glsl", overrides),
        resolve("/lib/common/syntax.glsl", overrides),
        STUBS,
        resolve("/lib/common/util.glsl", overrides),
        resolve("/lib/atmosphere/volumetricClouds.glsl", overrides),
        body,
    ])


def look(yaw_deg, pitch_deg):
    y, p = math.radians(yaw_deg), math.radians(pitch_deg)
    return (math.sin(y) * math.cos(p), math.sin(p), -math.cos(y) * math.cos(p))


SCENES = {
    "ground_up": (80, 0, 25, 70, 0.0, 0.0),
    "ground_horizon": (80, 0, 4, 70, 0.0, 0.0),
    "approach_below": (560, 0, 8, 70, 0.0, 0.0),
    "inside_level": (800, 0, 0, 70, 0.0, 0.0),
    "inside_up": (800, 0, 45, 70, 0.0, 0.0),
    "inside_down": (800, 0, -35, 70, 0.0, 0.0),
    "above_down": (1500, 0, -20, 70, 0.0, 0.0),
    "above_level": (1500, 0, 0, 70, 0.0, 0.0),
    "storm_ground": (80, 0, 20, 70, 1.0, 1.0),
    "overcast_ground": (80, 0, 20, 70, 1.0, 0.0),
    "cloud_inside_level": (760, 90, 0, 70, 0.0, 0.0, -1285, 1385),
    "cloud_inside_up": (760, 90, 50, 70, 0.0, 0.0, -1285, 1385),
    "cloud_inside_down": (760, 90, -50, 70, 0.0, 0.0, -1285, 1385),
    "cloud_approach_300": (760, 90, 0, 70, 0.0, 0.0, -1585, 1385),
    "cloud_approach_120": (760, 90, 0, 70, 0.0, 0.0, -1405, 1385),
    "cloud_edge_40": (760, 90, 0, 70, 0.0, 0.0, -1325, 1385),
}


def main():
    import moderngl
    from PIL import Image
    out = sys.argv[1]
    names = sys.argv[2:] or list(SCENES)
    os.makedirs(out, exist_ok=True)
    composite_all = os.environ.get("COMPOSITE", "sky") == "all"
    accum = int(os.environ.get("ACCUM", "1"))
    steps = int(os.environ.get("STEPS", "32"))
    w, h = int(os.environ.get("W", "640")), int(os.environ.get("H", "360"))
    ctx = moderngl.create_standalone_context(require=430)
    noise = Image.open(os.path.join(ROOT, "textures/perlinNoise.png")).convert("RGBA")
    ntex = ctx.texture(noise.size, 4, noise.tobytes())
    ntex.repeat_x = ntex.repeat_y = True
    raw = open(os.path.join(ROOT, "textures/cloudNoise.bin"), "rb").read()
    ctex = ctx.texture3d((64, 64, 64), 4, raw)
    ctex.repeat_x = ctex.repeat_y = ctex.repeat_z = True
    ctex.filter = (moderngl.LINEAR, moderngl.LINEAR)
    prog = ctx.program(
        vertex_shader="#version 430 compatibility\nin vec2 p; out vec2 uv; void main(){ uv = p*0.5+0.5; gl_Position = vec4(p,0,1); }",
        fragment_shader=build({}, composite_all))
    vbo = ctx.buffer(np.array([-1, -1, 3, -1, -1, 3], dtype="f4").tobytes())
    vao = ctx.vertex_array(prog, [(vbo, "2f", "p")])
    ntex.use(0)
    ctex.use(1)
    for k, v in dict(perlinNoiseTex=0, cloudNoiseTex=1).items():
        if k in prog:
            prog[k].value = v
    sheet = []
    for name in names:
        sc = SCENES[name]
        camy, yaw, pitch, fov, wet, th = sc[:6]
        camx, camz = sc[6:8] if len(sc) > 6 else (0.0, 0.0)
        u = dict(frameTimeCounter=50.0, wetness=wet, thunderStrength=th, viewWidth=float(w), viewHeight=float(h),
                 worldTime=4000, worldDay=3, frameCounter=0, cameraPosition=(float(camx), float(camy), float(camz)),
                 lightningBoltPosition=(0.0, 0.0, 0.0, 0.0), uSunDir=(0.45, 0.7, -0.55),
                 uSunColor=(0.12, 0.116, 0.11), uSkyColor=(0.1, 0.13, 0.18), uForward=look(yaw, pitch),
                 uFov=math.tan(math.radians(fov / 2)), uGround=64.0, uComposite=1.0 if composite_all else 0.0,
                 uJitterBase=0.0, uAccum=accum, uSteps=steps)
        for k, v in u.items():
            if k in prog:
                prog[k].value = v
        fbo = ctx.simple_framebuffer((w, h), components=4)
        fbo.use()
        vao.render()
        img = Image.frombytes("RGBA", (w, h), fbo.read(components=4)).transpose(Image.FLIP_TOP_BOTTOM).convert("RGB")
        fbo.release()
        img.save(os.path.join(out, name + ".png"))
        sheet.append((name, img))
        print("wrote", name)
    cols = 2
    rows = (len(sheet) + cols - 1) // cols
    from PIL import ImageDraw
    s = Image.new("RGB", (w * cols, h * rows))
    for i, (name, img) in enumerate(sheet):
        im = img.copy()
        ImageDraw.Draw(im).text((6, 6), name, fill=(255, 255, 0))
        s.paste(im, ((i % cols) * w, (i // cols) * h))
    s.save(os.path.join(out, "sheet.png"))


if __name__ == "__main__":
    main()
