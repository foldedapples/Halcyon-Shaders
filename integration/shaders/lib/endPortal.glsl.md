# Halcyon changes to Glimmer file `shaders/lib/endPortal.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 5-11

```glsl
// END PORTAL. instead of the vanilla starfield, the portal shows actual space with a black hole in it. I went way too far
#include "/lib/atmosphere/sky/stars.glsl"
#include "/lib/atmosphere/sky/blackHole.glsl"

// 4x brightness boost because the space looked like a dark puddle without it
#define END_PORTAL_GAIN 4.0

// direction where the fake black hole sits. pointing mostly down. these specific digits are NOT random. ok they're a little random
const vec3 portalHoleDir = vec3(0.2133, -0.9696, 0.1357);
// 'einstein radius'. that's a real thing apparently. I named a variable after einstein and now I feel smart
const float portalEinstein = 0.075;
const float portalShadow = 0.05;

// gravitational lensing. bends the view direction around the black hole. how? the formula below. why does it work? einstein, probably
// returns the bent direction plus the shadow, the glowy ring, and how zoomed in it got
vec3 portalLens(vec3 dir, out float shadow, out float ring, out float magnification) {
  shadow = 0.0;
  ring = 0.0;
  magnification = 1.0;
  float a = clamp(dot(dir, portalHoleDir), -1.0, 1.0);
  float theta = acos(a);
  // far from the hole, light goes straight. lucky light
  if (theta > 0.6) return dir;
  vec3 perp = dir - portalHoleDir * a;
  float pl = length(perp);
  // looking dead center into the hole. it's black. obviously. you looked into a black hole, what did you expect
  if (pl < 1e-5) {
    shadow = 1.0;
    return dir;
  }
  perp /= pl;
  shadow = 1.0 - smoothstep(portalShadow * 0.92, portalShadow * 1.04, theta);
  // the photon ring. 1.06 and 0.06, nudged until it looked like the interstellar movie. scientific method
  ring = exp(-pow2((theta - portalShadow * 1.06) / (portalShadow * 0.06)));
  float fade = 1.0 - smoothstep(0.35, 0.6, theta);
  float th = max(theta, portalShadow * 0.5);
  // the actual bending. einstein squared divided by angle. I copied this off a whiteboard in my head
  float thetaSrc = theta - portalEinstein * portalEinstein / th * fade;
  magnification = 1.0 + portalEinstein * portalEinstein / (th * th) * fade;
  return portalHoleDir * cos(thetaSrc) + perp * sin(thetaSrc);
}

// floating sparkly dust particles inside the portal at fake depth. EIGHT parameters. this function signature is a novel
vec3 portalMotes(
  vec3 surfacePos,
  vec3 dir,
  vec3 normal,
  float depth,
  float cellSize,
  float drift,
  float seed,
  float pixelAngle
) {
  // clamp to 0.08 so looking at the portal edge-on doesn't divide by zero and summon a NaN demon
  float cosIn = max(dot(dir, -normal), 0.08);
  float t = depth / cosIn;
  vec3 hit = surfacePos + dir * t + cameraPosition;
  // build a 2D grid on the portal surface. pick any axis that's not parallel to the normal. cross products go brrr
  vec3 ax = abs(normal.y) < 0.9 ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
  vec3 u = normalize(cross(normal, ax));
  vec3 v = cross(normal, u);
  vec2 p = vec2(dot(hit, u), dot(hit, v));
  p += vec2(0.7, 0.4) * frameTimeCounter * drift;
  vec2 g = p / cellSize;
  vec2 base = floor(g);
  float dist = length(surfacePos) + t;
  // far away motes get blurrier but dimmer so they don't flicker. energy conservation or whatever. it stopped sparkling like crazy, that's all I know
  float footprint = dist * pixelAngle / cosIn;
  float r0 = 0.035 * cellSize;
  float r = sqrt(r0 * r0 + footprint * footprint);
  float energy = (r0 * r0) / (r * r);
  vec3 col = vec3(0.0);
  // check the 3x3 neighbor cells for a mote. 32% of cells get one. why 0.32. because 0.3 felt empty
  for (int j = -1; j <= 1; j++) {
    for (int i = -1; i <= 1; i++) {
      vec2 cell = base + vec2(i, j);
      vec3 h = hash33(vec3(cell, seed));
      if (h.x > 0.32) continue;
      vec2 centre = (cell + 0.15 + 0.7 * hash33(vec3(cell, seed + 17.0)).xy) * cellSize;
      float d2 = dot(p - centre, p - centre);
      if (d2 > 9.0 * r * r) continue;
      float pulse = 0.8 + 0.2 * sin(frameTimeCounter * (0.4 + 0.5 * h.y) + h.z * 40.0);
      vec3 tint = mix(vec3(0.62, 0.48, 1.0), vec3(0.45, 0.68, 1.0), h.z);
      col += tint * exp(-d2 / (r * r)) * energy * pow(h.y, 3.0) * pulse;
    }
  }
  return col;
```

## 2. replaces Glimmer lines 15-52 — in `endPortal()`

```glsl
  if (dot(dir, normal) > 0.0) normal = -normal;
  float pixelAngle = 2.0 / (gbufferProjection[1][1] * viewHeight);

  float shadow, ring, magnification;
  vec3 spaceDir = portalLens(dir, shadow, ring, magnification);
  vec3 space = cosmicBackground(spaceDir, pixelAngle * magnification) * (1.0 - shadow);
  space += vec3(0.85, 0.62, 1.0) * ring * 0.0025;

  // three layers of motes at different depths for parallax. 1.5, 4.5, 11.0 deep. the seeds 3, 11, 29 are primes because primes feel lucky
  vec3 motes =
    portalMotes(playerPos, dir, normal, 1.5, 0.55, 0.015, 3.0, pixelAngle) * 0.03 +
    portalMotes(playerPos, dir, normal, 4.5, 0.9, 0.009, 11.0, pixelAngle) * 0.018 +
    portalMotes(playerPos, dir, normal, 11.0, 1.6, 0.005, 29.0, pixelAngle) * 0.01;

  return (space * END_PORTAL_GAIN + motes) * END_PORTAL_BRIGHTNESS;
```

