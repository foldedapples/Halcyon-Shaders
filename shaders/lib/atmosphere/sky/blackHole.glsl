#ifndef BLACK_HOLE_GLSL
#define BLACK_HOLE_GLSL

// welcome to the black hole file. I put a BLACK HOLE in the END. abandon hope all ye who scroll here
#include "/lib/atmosphere/sky/endAmbient.glsl"


// 5.196152 = 3 * sqrt(3). it's the "critical impact parameter". I don't know what that means but a physics PDF said it and it looked important
const float BH_CRIT = 5.196152;
// innermost stable circular orbit. closer than 6 and stuff just falls in and dies. same, honestly
const float BH_ISCO = 6.0;

// quality presets. 140 steps on ultra. RIP your framerate, it was nice knowing you
#if BH_QUALITY == 0
  #define BH_STEPS_PER_PI 40
#elif BH_QUALITY == 1
  #define BH_STEPS_PER_PI 64
#elif BH_QUALITY == 2
  #define BH_STEPS_PER_PI 96
#else
  #define BH_STEPS_PER_PI 140
#endif

// a rotation matrix for the End sky so the galaxy band isn't perfectly flat. sqrt(3)/2 is in there. I recognize her from trig class
const mat3 endSkyFrame = mat3(
  0.8660254, 0.0, -0.5,
  0.2236068, 0.8944272, 0.3872983,
  0.4472136, -0.4472136, 0.7745967
);
const vec3 endGalacticNormal = vec3(0.30, 0.86, 0.41); // which way is "up" for the galaxy. I tilted it until it looked cinematic

// relative-luminance-normalised blackbody colour (Helland fit), linear
// ^ temperature in, color out. these 10-digit constants are someone else's curve fit. I would NEVER have come up with 1.19625408914
vec3 bhBlackbody(float kelvin) {
  float t = clamp(kelvin, 1000.0, 40000.0) / 100.0;
  vec3 c;
  // 66 is the magic split point where everything changes. why 66. nobody knows. order 66. it's always order 66
  c.r = t <= 66.0 ? 1.0 : clamp01(1.292936 * pow(t - 60.0, -0.1332047592));
  c.g = t <= 66.0
    ? clamp01(0.3900815787 * log(t) - 0.6318414438)
    : clamp01(1.129890861 * pow(t - 60.0, -0.0755148492));
  c.b = t >= 66.0
    ? 1.0
    : (t <= 19.0 ? 0.0 : clamp01(0.5432067891 * log(t - 10.0) - 1.19625408914));
  c = pow(c, vec3(2.2));
  return c / max(luminance(c), 1e-4); // divide out the brightness so only the color is left. brightness gets handled later. somewhere. trust
}

// gradient for space gas: blue -> violet -> rose -> teal. picked these off a nebula wallpaper
vec3 nebulaTint(float x) {
  vec3 violet = vec3(0.55, 0.36, 0.85);
  vec3 blue = vec3(0.28, 0.40, 0.95);
  vec3 teal = vec3(0.25, 0.68, 0.78);
  vec3 rose = vec3(0.85, 0.36, 0.52);
  // nested ternaries. three levels deep. I'm not sorry
  vec3 c = x < 0.33
    ? mix(blue, violet, x / 0.33)
    : x < 0.66
      ? mix(violet, rose, (x - 0.33) / 0.33)
      : mix(rose, teal, (x - 0.66) / 0.34);
  return c / luminance(c);
}

// pretty space clouds plus dark dust lanes that block the stars. 3 layers. each one a little smaller. like a nebula onion
vec3 cosmicClouds(vec3 c, float band, out float dustT) {
  dustT = 1.0;
  #ifndef COSMIC_CLOUDS
  return vec3(0.0);
  #else
  const float scale[3] = float[3](0.55, 1.05, 1.9);
  const float weight[3] = float[3](1.0, 0.7, 0.45);
  vec3 col = vec3(0.0);
  float T = 1.0;
  for (int k = 0; k < 3; k++) {
    // offset each layer by a random-ish vector so they don't line up. 0.17 0.53 0.71, I mashed the numpad
    vec3 q = c * scale[k] + vec3(0.17, 0.53, 0.71) * float(k + 1);
    vec4 n1 = texture(cloudNoiseTex, fract(q));
    vec4 n2 = texture(cloudNoiseTex, fract(q * 2.9 + (n1.gba - 0.5) * 0.45)); // warp the second noise with the first noise. noiseception
    float fbm = n1.r * 0.55 + n2.g * 0.3 + n2.b * 0.15;
    float gas = pow2(smoothstep(0.5, 0.92, fbm * (0.7 + 0.5 * band))) * NEBULA_DENSITY;
    // filaments: 1 - abs(2x - 1) makes a ridge. ridges look like stringy space goo. I'm basically NASA now
    float filament = smoothstep(0.6, 1.0, 1.0 - abs(n2.a * 2.0 - 1.0)) * gas;
    float dust = smoothstep(0.55, 0.9, n2.r * (0.8 + 0.4 * band)) * NEBULA_DENSITY;
    vec3 tint = nebulaTint(fract(n1.g * 1.7 + 0.31 * float(k)));
    tint = mix(vec3(luminance(tint)), tint, NEBULA_SATURATION);
    col += T * tint * (gas * (0.6 + 0.4 * n1.b) + filament * 0.35) * weight[k];
    T *= exp(-dust * 1.1); // dust eats light. beer's law again. it's always beer's law
  }
  dustT = T;
  return col * 0.0005 * NEBULA_BRIGHTNESS; // 0.0005. it was blinding before. like, looking-at-the-sun blinding. in the END
  #endif
}

// tiny smudgy galaxies scattered around. cube-map the direction, grid it, roll dice per cell. if it works it works
vec3 distantGalaxies(vec3 c) {
  vec3 a = abs(c);
  // figure out which cube face we're on. this line is unreadable and I wrote it. future me, I'm sorry
  int axis = a.x > a.y ? (a.x > a.z ? 0 : 2) : (a.y > a.z ? 1 : 2);
  float major = axis == 0 ? c.x : axis == 1 ? c.y : c.z;
  vec2 uv = (axis == 0 ? c.yz : axis == 1 ? c.xz : c.xy) / abs(major);
  float faceId = float(axis) * 2.0 + (major > 0.0 ? 1.0 : 0.0);
  const float cells = 18.0;
  vec2 g = (uv * 0.5 + 0.5) * cells;
  vec2 cell = floor(g);
  vec3 h = hash33(vec3(cell, faceId * 13.0 + 7.0));
  if (h.x > 0.08) return vec3(0.0); // only 8% of cells get a galaxy. the rest get the void. the void is free
  vec2 centre = cell + 0.3 + 0.4 * hash33(vec3(cell, faceId + 3.0)).xy;
  vec2 p = (g - centre) * 14.0;
  float ang = h.y * 6.2831853; // 6.2831853 = 2 * PI. I typed it out instead of using a constant because I'm chaotic
  p = mat2(cos(ang), sin(ang), -sin(ang), cos(ang)) * p;
  p.y /= mix(0.25, 1.0, h.z); // squash some of them so they look tilted. instant 3D. I'm a genius (I'm not)
  float r2 = dot(p, p);
  float disk = exp(-r2 * 2.0);
  float core = exp(-r2 * 18.0);
  vec3 tint = mix(vec3(1.0, 0.9, 0.78), vec3(0.85, 0.9, 1.0), h.z);
  return tint * (disk * 0.35 + core) * 0.0035 * mix(0.3, 1.0, h.y);
}

// the whole End space backdrop: gas, stars, galaxies, glow. the stuff BEHIND the black hole that it bends around
vec3 cosmicBackground(vec3 worldDir, float pixelAngle) {
  vec3 c = endSkyFrame * worldDir;
  float b = dot(c, endGalacticNormal);
  float band = exp(-b * b / 0.035); // gaussian galaxy band. 0.035 = how thicc the milky way is

  float dustT;
  vec3 gas = cosmicClouds(c, band, dustT);

  // three star layers: tons of dim ones, some medium ones, a few big bois
  float density = END_STAR_DENSITY * (1.0 + 1.2 * band);
  vec3 stars =
    starLayer(c, floor(240.0 * sqrt(END_STAR_DENSITY)), 0.05 * sqrt(density), 0.02, pixelAngle, 0.0) +
    starLayer(c, 70.0, 0.06 * density, 0.18, pixelAngle, 0.0) +
    starLayer(c, 18.0, 0.10, 0.9, pixelAngle, 0.0);
  stars *= END_STAR_BRIGHTNESS;

  vec3 glow = vec3(0.75, 0.78, 1.0) * band * 0.00045;
  vec3 floorGlow = vec3(0.30, 0.28, 0.45) * 0.00012; // minimum brightness so the void isn't pure 0. pure black looked like my monitor died

  return ((stars + glow + distantGalaxies(c)) * dustT + gas + floorGlow) * COSMIC_SKY_BRIGHTNESS;
}

// coordinate frame for the black hole. c = where it is, n = disk normal, t1/t2 = disk axes, D = distance. D for Doom
struct BHFrame {
  vec3 c;
  vec3 n;
  vec3 t1;
  vec3 t2;
  float D;
  float outer;
};

// builds the frame. cross products everywhere. I use the right hand rule and still get it wrong half the time
BHFrame bhFrame() {
  BHFrame f;
  f.c = worldLightDir;
  vec3 upRef = abs(f.c.y) < 0.99 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0); // if it's straight up pick a different up or cross() gives zero and everything is NaN. ask me how I know
  vec3 side = normalize(cross(f.c, upRef));
  vec3 up = cross(side, f.c);
  float tilt = radians(BH_DISK_TILT);
  vec3 n = normalize(up * cos(tilt) - f.c * sin(tilt));
  float roll = radians(BH_DISK_ROLL);
  // rodrigues rotation formula. rodrigues if you're reading this, thank you, I have no idea how you figured this out
  n = n * cos(roll) + cross(f.c, n) * sin(roll) + f.c * dot(f.c, n) * (1.0 - cos(roll));
  f.n = normalize(n);
  f.t1 = normalize(cross(f.n, f.c));
  f.t2 = cross(f.n, f.t1);
  f.D = BH_CRIT / sin(radians(BH_SIZE)); // back out how far away it must be to look BH_SIZE degrees big. trig: still haunting me
  f.outer = min(BH_DISK_OUTER, 0.6 * f.D);
  return f;
}

// accretion disk temperature vs radius. the 0.4879 at the end normalizes the peak to 1. I found it by brute force in desmos for an hour
float bhDiskTemperature(float r) {
  float x = BH_ISCO / r;
  return pow(x, 0.75) * pow(max(1.0 - sqrt(x), 0.0), 0.25) / 0.4879;
}

// swirly disk density. spins faster on the inside (kepler!! r^-1.5!! I remembered something!!)
float bhDiskDensity(float r, float psi, float outer) {
  const float period = 30.0;
  float t = frameTimeCounter * BH_ROTATION_SPEED;
  float omega = 2.5 * pow(r / BH_ISCO, -1.5);
  // two copies of the noise half a period apart, crossfaded, so the swirl doesn't wind up into infinitely tight spaghetti. took me 6 hours to figure this out, my brain is fried
  float ph0 = fract(t / period);
  float ph1 = fract(t / period + 0.5);
  float w = abs(ph0 * 2.0 - 1.0);
  float lr = log(r);
  float a = psi / 6.2831853;

  vec2 q0 = vec2(a * 3.0 + omega * ph0 * period / 6.2831853 * 3.0, lr * 1.7);
  vec2 q1 = vec2(a * 3.0 + omega * (ph1 * period) / 6.2831853 * 3.0, lr * 1.7 + 0.37);
  float n0 = texture(perlinNoiseTex, fract(q0)).r * 0.65 + texture(perlinNoiseTex, fract(q0 * vec2(3.0, 4.1))).g * 0.35;
  float n1 = texture(perlinNoiseTex, fract(q1)).r * 0.65 + texture(perlinNoiseTex, fract(q1 * vec2(3.0, 4.1))).g * 0.35;
  float n = mix(n1, n0, w);

  // little rings and gaps in the disk, wiggled by the noise. saturn vibes. 5.3 and 1.9 are pulled straight out of my ass
  float rings = 0.75 + 0.25 * sin(r * 5.3 + n * 6.0) * sin(r * 1.9 + 1.3);
  float dens = clamp01((n - 0.18) * 1.6) * rings;
  float edge = smoothstep(BH_ISCO, BH_ISCO * 1.12, r) * (1.0 - smoothstep(outer * 0.55, outer, r));
  return dens * edge;
}

// THE BLACK HOLE. traces light rays backwards through curved spacetime. in a minecraft shader. at 2am. on a school night
vec3 blackHoleSky(vec3 d, float pixelAngle) {
  BHFrame f = bhFrame();

  float cosT = dot(d, f.c);
  float sinT = length(cross(d, f.c));
  // looking DEAD center. straight into the abyss. you get black. congratulations
  if (sinT < 1e-6) {
    return cosT > 0.0 ? vec3(0.0) : cosmicBackground(d, pixelAngle);
  }

  // the photon moves in a flat plane, so make 2D axes for that plane. e1 points away from the hole
  vec3 e1 = -f.c;
  vec3 e2 = (d - cosT * f.c) / sinT;

  // u = 1/r. physicists use 1/r because the equation gets nicer. nicer for THEM
  float u = 1.0 / f.D;
  float w = cosT / (f.D * sinT);
  float cp = 1.0, sp = 0.0; // cos and sin of the orbit angle, spun forward each step with a rotation instead of calling sin() a million times
  const float dphi = 3.14159265 / float(BH_STEPS_PER_PI);
  const float cs = cos(dphi), sn = sin(dphi);
  float a = dot(e1, f.n), b = dot(e2, f.n);

  vec3 radiance = vec3(0.0);
  float T = 1.0;
  int images = 0;
  bool escaped = false;
  vec3 escapeDir = d;
  float gObs = sqrt(1.0 - 2.0 / f.D); // gravitational redshift for the observer. I'm the observer. I'm being redshifted. I feel it

  // up to 3 half-orbits (3 * PI). light can loop around the hole. LIGHT. LOOPS. what the fuck, einstein
  for (int i = 0; i < BH_STEPS_PER_PI * 3; i++) {
    // RK4. runge-kutta 4th order. solving u'' = 3u^2 - u (the photon orbit equation). I copied this pattern from a youtube video and did NOT understand it
    // DO NOT FUCKING TOUCH ANY OF THESE 8 LINES. I changed a 0.5 to 0.25 once and the black hole became a white hole
    float k1u = w, k1w = 3.0 * u * u - u;
    float u2 = u + 0.5 * dphi * k1u, w2 = w + 0.5 * dphi * k1w;
    float k2u = w2, k2w = 3.0 * u2 * u2 - u2;
    float u3 = u + 0.5 * dphi * k2u, w3 = w + 0.5 * dphi * k2w;
    float k3u = w3, k3w = 3.0 * u3 * u3 - u3;
    float u4 = u + dphi * k3u, w4 = w + dphi * k3w;
    float k4u = w4, k4w = 3.0 * u4 * u4 - u4;
    float un = u + dphi / 6.0 * (k1u + 2.0 * k2u + 2.0 * k3u + k4u); // the 1 2 2 1 over 6 thing. it's like a weighted average. of slopes. I think
    float wn = w + dphi / 6.0 * (k1w + 2.0 * k2w + 2.0 * k3w + k4w);
    float cpn = cp * cs - sp * sn;
    float spn = sp * cs + cp * sn;

    // did the photon cross the disk plane this step? sign flip = yes. the one trick I actually understood first try
    float s0 = a * cp + b * sp;
    float s1 = a * cpn + b * spn;
    if (s0 * s1 < 0.0 && un > 0.0) {
      float t = s0 / (s0 - s1);
      float uc = mix(u, un, t);
      float r = 1.0 / max(uc, 1e-6);
      if (r > BH_ISCO && r < f.outer) {
        vec2 cph = normalize(mix(vec2(cp, sp), vec2(cpn, spn), t));
        vec3 er = cph.x * e1 + cph.y * e2;
        vec3 ephi = -cph.y * e1 + cph.x * e2;
        vec3 P = er * r;
        float psi = atan(dot(P, f.t2), dot(P, f.t1));
        float dens = bhDiskDensity(r, psi, f.outer);
        if (dens > 0.0) {
          // which way the light is REALLY going (we trace backwards because we're backwards people)
          float wc = mix(w, wn, t);
          vec3 k = normalize(wc * er - uc * ephi);
          vec3 vdir = normalize(cross(f.n, er));
          // relativistic doppler beaming. one side of the disk is brighter because it's coming AT you at like 70% light speed. capped at 0.7 so it doesn't go infinity
          float beta = min(inversesqrt(max(r - 2.0, 0.5)), 0.7);
          float gamma = inversesqrt(1.0 - beta * beta);
          float doppler = 1.0 / (gamma * (1.0 - beta * dot(vdir, k)));
          float g = doppler * sqrt(1.0 - 2.0 / r) / gObs;
          g = mix(1.0, g, BH_DOPPLER);

          // 4400 kelvin base, pow 1.35, pow 3 for intensity. every exponent here was a guess. I'm a professional guesser
          float temp = bhDiskTemperature(r) * g;
          vec3 col = bhBlackbody(4400.0 * pow(temp, 1.35));
          float intensity = pow(temp, 3.0);
          float alpha = clamp01(dens * 1.3) * 0.92;
          float ringBoost = images > 0 ? BH_PHOTON_RING : 1.0; // second+ hit = photon ring. that thin bright line from the interstellar movie. I cried
          radiance += T * col * intensity * alpha * 0.025 * BH_DISK_BRIGHTNESS * ringBoost;
          T *= 1.0 - alpha;
          images++;
          if (T < 0.01) break;
        }
      }
    }

    // fuzzy glow hugging the disk so it doesn't look like a paper plate in space
    {
      float r = 1.0 / max(un, 1e-6);
      float height = abs(s1) * r;
      if (r < f.outer * 1.3 && r > 3.0 && height < 4.0) {
        float ds = r * dphi * sqrt(1.0 + pow2(wn / max(un, 1e-6))); // arc length of this step. calculus. I hate calculus. calculus hates me
        float glow = exp(-pow2(height / (0.7 + 0.06 * r))) * bhDiskTemperature(max(r, BH_ISCO)) * smoothstep(f.outer * 1.3, f.outer * 0.4, r);
        radiance += T * vec3(1.0, 0.62, 0.32) * glow * min(ds, 4.0) * 0.00018 * BH_DISK_BRIGHTNESS;
      }
    }

    u = un; w = wn; cp = cpn; sp = spn;

    // got eaten: past the event horizon (u >= 0.5 means r <= 2), or inside the photon sphere and still falling. F in chat
    if (u >= 0.5 || (u > 0.36 && w > 0.0)) break;

    // far enough out and moving away = escaped. jump straight to the final direction instead of marching to infinity like an idiot
    if (u < 0.25 / f.D && w < 0.0) {
      float rest = atan(u, -w);
      float ce = cos(rest), se = sin(rest);
      vec2 ph = vec2(cp * ce - sp * se, sp * ce + cp * se);
      escapeDir = ph.x * e1 + ph.y * e2;
      escaped = true;
      break;
    }
    if (u <= 0.0) {
      escapeDir = cp * e1 + sp * e2;
      escaped = true;
      break;
    }
  }

  // light made it out! show whatever it hit in the background, bent and warped. lensing baby
  if (escaped) {
    radiance += T * cosmicBackground(normalize(escapeDir), pixelAngle);
  }
  return radiance;
}


// entry point for the End sky. reflections get the cheap ambient version because I am not raytracing a black hole inside a puddle
vec3 cosmicSky(vec3 dir, bool includeSun) {
  if (!includeSun) return endAmbientSky(dir);
  float pixelAngle = clamp(2.0 / (gbufferProjection[1][1] * viewHeight), 1e-4, 1e-2); // how big one pixel is in radians. [1][1] of the projection matrix is focal length-ish. allegedly
  #ifdef BLACK_HOLE
  return blackHoleSky(dir, pixelAngle);
  #else
  return cosmicBackground(dir, pixelAngle);
  #endif
}

#endif // BLACK_HOLE_GLSL
