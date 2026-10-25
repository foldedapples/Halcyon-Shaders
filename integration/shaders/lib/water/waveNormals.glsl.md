# Halcyon changes to Glimmer file `shaders/lib/water/waveNormals.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 10

```glsl
#define WAVE_DETAIL_ITERATIONS 12 // 12 layers of waves. GPU go brrrr

// wave clock. multiply by WAVE_SPEED so you can make the ocean go fast forward
float waveTime() {
  return frameTimeCounter * WAVE_SPEED;
}
```

## 2. replaces Glimmer line 23 — in `wavedx()`

```glsl
// 12 random-ish directions, all unit length. pretty sure someone generated these with a script. I'd never type this many decimals by hand
const vec2 waveDirections[12] = vec2[12](
  vec2(0.644218, 0.764842),
  vec2(0.041617, -0.999134),
  vec2(-0.705592, 0.708618),
  vec2(0.998946, -0.045892),
  vec2(-0.767592, -0.640939),
  vec2(0.133050, 0.991109),
  vec2(0.571378, -0.820687),
  vec2(-0.975682, 0.219189),
  vec2(0.867498, 0.497441),
  vec2(-0.303649, -0.952784),
  vec2(-0.419695, 0.907665),
  vec2(0.922589, -0.385784)
);

// add up all the wave layers. each one smaller and faster than the last. fractal ocean baby
float waveHeight(vec2 position, int iterations) {
  // divide by 1.6 because the waves were too small. or too big. one of those
  position /= WAVE_SCALE * 1.6;
```

## 3. Removed Glimmer code (replaces Glimmer line 25) — in `waveHeight()`

Halcyon deletes these Glimmer lines (no replacement).

## 4. replaces Glimmer lines 31-41 — in `waveHeight()`

```glsl
  // 0.6 because full speed looked like a washing machine
  float t = waveTime() * 0.6;
  for (int i = 0; i < min(iterations, 12); i++) {
    vec2 p = waveDirections[i];

    // do the wave thing
    vec2 res = wavedx(position, p, frequency, t * timeMultiplier + wavePhaseShift);
```

## 5. replaces Glimmer line 51 — in `waveHeight()`

```glsl
    // shrink 27% per layer, grow frequency 18%, grow speed 7%. these ratios are cursed knowledge passed down from shadertoy elders
    weight = mix(weight, 0.0, 0.27);
```

## 6. Removed Glimmer code (replaces Glimmer line 56) — in `waveHeight()`

Halcyon deletes these Glimmer lines (no replacement).

## 7. inserted after Glimmer line 60 — in `waveHeight()`

```glsl
}

float waveHeight(vec2 position) {
  return waveHeight(position, WAVE_DETAIL_ITERATIONS);
}

// big slow noise so the waves are calmer in some spots and choppier in others. 384 blocks wide. 0.0007 makes it drift
float waveFieldModulation(vec2 worldXZ) {
  float n = texture(perlinNoiseTex, fract(worldXZ / 384.0 + waveTime() * 0.0007)).r;
  return mix(0.45, 1.0, smoothstep(0.2, 0.8, n));
}

// gerstner swells (the big rolling ocean ones), normals from GPU Gems ch.1 (Finch 2004) at the undisplaced position. I read the chapter. twice. understood half
const int SWELL_COUNT = 7;
// wavelengths in blocks, 72 down to 9.3. the 72 one is chonky
const float swellWavelength[SWELL_COUNT] = float[SWELL_COUNT](72.0, 49.0, 34.0, 24.0, 17.0, 12.5, 9.3);
const float swellAngle[SWELL_COUNT] = float[SWELL_COUNT](0.0, 0.32, -0.38, 0.62, -0.7, 1.0, -1.15);
// steepness. 0.075 max. anything higher and the waves fold over themselves and turn inside out
const float swellSteepness[SWELL_COUNT] = float[SWELL_COUNT](0.075, 0.07, 0.062, 0.055, 0.047, 0.04, 0.034);

// storms make swells bigger. never phases, so no jumps. gated by biome not sky access, since the swell doesn't care if you're under a tree
float waterSwellWeather() {
  return 1.0 + WATER_STORM_WAVES * biomeCanPrecipitateSmooth * (0.15 * wetness + 0.35 * thunderStrength);
}

// same idea but for the small detail waves. 0.3 and 0.3 because I'm lazy and symmetric
float waterDetailWeather() {
  return 1.0 + WATER_STORM_WAVES * biomeCanPrecipitateSmooth * (0.3 * wetness + 0.3 * thunderStrength);
}

// oceans get 1.4x swells, rivers get 0.45x. rivers are not the ocean, rivers are chill
float waterSwellMul() {
  #ifdef WATER_BIOME_WAVES
  return mix(mix(1.0, 1.4, oceanBiomeSmooth), 0.45, riverBiomeSmooth) * waterSwellWeather();
  #else
  return waterSwellWeather();
  #endif
}

float waterDetailMul() {
  #ifdef WATER_BIOME_WAVES
  return mix(1.0, 0.75, oceanBiomeSmooth) * WAVE_DETAIL * waterDetailWeather();
  #else
  return WAVE_DETAIL * waterDetailWeather();
  #endif
}
// Q = how sharp the gerstner peaks are. 0.8. at 1.0 they get pointy, past 1.0 they loop and look like a glitch
const float swellQ = 0.8;

// wave groups: makes swells come in sets instead of one infinite boring line. 0.7706 is to normalize it. I found it with a calculator and a lot of swearing
float swellGroup(int i, float k, float x, float omega, float t) {
  return (0.75 + 0.25 * sin(k * 0.125 * x - omega * 0.0625 * t + float(i) * 2.3)) / 0.7706;
}

// swell slope. footprint stuff is anti-aliasing: waves smaller than a pixel get removed so the far ocean doesn't shimmer like crazy
vec2 swellSlope(vec2 worldXZ, float amplitudeMul, vec2 viewXZ, vec2 footprint, inout float slopeVariance) {
  if (amplitudeMul <= 0.0) return vec2(0.0);
  // 2.26 cap. why 2.26? I genuinely do not remember. it's load-bearing though
  amplitudeMul = min(amplitudeMul, 2.26);

  // same wind direction as everywhere else. consistency!! the one thing I did right
  const vec2 windDir = vec2(0.8, 0.6);
  float t = waveTime();
  vec2 slopeNum = vec2(0.0);
  float ny = 1.0;
  for (int i = 0; i < SWELL_COUNT; i++) {
    float L = swellWavelength[i] * WAVE_SCALE;
    float k = 2.0 * PI / L;
    // deep water dispersion: omega = sqrt(g*k). long waves go faster. I memorized this for a test once and it finally paid off
    float omega = sqrt(9.81 * k);
    vec2 D = rotate(windDir, swellAngle[i]);
    float kA = swellSteepness[i] * amplitudeMul;
    float x = dot(D, worldXZ);
    kA *= swellGroup(i, k, x, omega, t);

    // how big this wave looks on screen vs the pixel size. along/across the view direction. took me forever, shit was flickering for days
    float along = dot(D, viewXZ);
    float fp = length(vec2(along * footprint.x, sqrt(max(1.0 - along * along, 0.0)) * footprint.y));
    // waves smaller than ~0.2-0.55 wavelengths per pixel get faded out. nyquist or something. I nodded along
    float keep = 1.0 - smoothstep(0.2 * L, 0.55 * L, fp);
    // keep track of the slope we threw away so the roughness can fake it back in later. honestly genius, not mine
    slopeVariance += 0.5 * kA * kA * (1.0 - keep * keep);
    if (keep <= 0.0) continue;
    kA *= keep;

    // 1.7 phase offset per swell, same as in caustics. if they don't match, the caustics lie. learned that the hard way
    float theta = k * x - omega * t + float(i) * 1.7;
    float s = sin(theta);
    float c = cos(theta);
    slopeNum += D * kA * c;
    ny -= swellQ * kA * s;
  }
  // 0.2 floor or the normal can flip upside down and the water goes black. ask me how many times that happened
  return slopeNum / max(ny, 0.2);
}

// lazy version without the anti-aliasing stuff
vec2 swellSlope(vec2 worldXZ, float amplitudeMul) {
  float unused = 0.0;
  return swellSlope(worldXZ, amplitudeMul, vec2(1.0, 0.0), vec2(0.0), unused);
}

// micro waves. the teeny tiny ripples up close. 4 of them because that's how many I could afford
const int MICRO_COUNT = 4;
const float microWavelength[MICRO_COUNT] = float[MICRO_COUNT](0.41, 0.31, 0.23, 0.17);
const float microAngle[MICRO_COUNT] = float[MICRO_COUNT](0.4, 2.8, -1.9, 1.3);

vec2 microSlope(vec2 worldXZ) {
  const vec2 windDir = vec2(0.8, 0.6);
  float t = waveTime();
  vec2 slope = vec2(0.0);
  // noise warp so the tiny waves don't look like a perfect grid. 9.0 is the amount of chaos
  vec2 warp =
    (texture(perlinNoiseTex, fract(worldXZ / 11.0 + t * 0.01)).rg - 0.5) * 9.0;
  for (int i = 0; i < MICRO_COUNT; i++) {
    float L = microWavelength[i] * WAVE_SCALE;
    float k = 2.0 * PI / L;
    // capillary waves! the 0.074/1000 is surface tension. water has surface tension. in minecraft. I looked this up, I swear
    float omega = sqrt(9.81 * k + 0.074 / 1000.0 * k * k * k);
    vec2 D = rotate(windDir, microAngle[i]);
    float theta =
      // warp[i & 1] picks r or g from the noise. bitwise AND in a shader, I feel like a hacker
      k * dot(D, worldXZ) - omega * t + float(i) * 2.1 + warp[i & 1] * (1.0 + 0.3 * float(i));
    // 0.018 tiny slope. bigger and it looks like the water is boiling
    slope += D * 0.018 * cos(theta);
  }
  return slope;
}

// far away water gets rougher to fake all the tiny waves we can't render. cheating but nobody can tell
float waterRoughness(float dist) {
  return mix(0.0, 0.035, smoothstep(6.0, 48.0, dist)) * (WAVE_DEPTH / 0.3);
}

float waterRoughness(float dist, float cosView) {
  // how big one pixel is at this distance. projection matrix [1][1] is the zoom thing. I think
  float pixelAngle = 2.0 / (gbufferProjection[1][1] * viewHeight);
  // 0.06 clamp so looking at water edge-on doesn't divide by basically zero
  float footprint = dist * pixelAngle / max(cosView, 0.06);
  float r = 0.045 * smoothstep(0.03, 0.25, footprint) * (WAVE_DEPTH / 0.3);
  return max(r, waterRoughness(dist));
}

// past 192 blocks the waves go low-detail. you can't see them anyway, you're not an eagle
#define WAVE_LOD_DISTANCE 192.0

// slopeVariance: mean squared slope removed by the footprint filter. aka "the slope we deleted, kept on a receipt"
vec2 waterSurfaceSlope(
  vec2 worldXZ,
  float heightmapFactor,
  float openness,
  float dist,
  vec2 viewXZ,
  vec2 footprint,
  out float slopeVariance
) {
  slopeVariance = 0.0;
  // level of detail: 0 up close, 1 far away. used to cut iterations
  float lod = smoothstep(16.0, WAVE_LOD_DISTANCE, dist);
  float noiseField = waveFieldModulation(worldXZ);
  float field = noiseField * mix(0.35, 1.0, openness);

  // 12 iterations close, 5 far. the + 0.5 is rounding. int() just chops, I learned that from a very confusing bug
  int iterations = int(mix(float(WAVE_DETAIL_ITERATIONS), 5.0, lod) + 0.5);
  // bigger epsilon far away, otherwise the slope gets noisy as hell
  float e = WAVE_E * (1.0 + dist * 0.04);
  // this line has 6 multipliers. I added one every time something looked wrong. it's an archaeology site now
  float amp = WAVE_DEPTH * heightmapFactor * field * mix(1.0, 0.35, lod) * 0.45 * waterDetailMul();

  // kill detail waves when they're smaller than a pixel, same anti-aliasing trick as the swells
  float detailKeep = 1.0 - smoothstep(1.0, 3.0, (0.5 * footprint.x + footprint.y) / WAVE_SCALE);
  slopeVariance += pow2(amp * 0.06 / WAVE_SCALE) * (1.0 - detailKeep * detailKeep);
  amp *= detailKeep;

  vec2 slope = vec2(0.0);
  if (amp > 0.0) {
    // rivers flow! 0 = ocean waves, 1 = river waves
    float river = 0.0;
    #ifdef WATER_BIOME_WAVES
    river = riverBiomeSmooth;
    #endif
    // finite differences: sample height 3 times, subtract, divide by e. that's a derivative. calculus is just subtraction with a fancy hat
    if (river < 0.999) {
      float h0 = waveHeight(worldXZ, iterations);
      float hx = waveHeight(worldXZ + vec2(e, 0.0), iterations);
      float hz = waveHeight(worldXZ + vec2(0.0, e), iterations);
      slope = vec2(hx - h0, hz - h0) / e * amp * (1.0 - river);
    }
    if (river > 0.001) {
      // river waves scroll along the wind direction at 0.9 speed so it looks like the water is flowing. it is not flowing. it's a lie. it's all lies
      vec2 d = worldXZ - vec2(0.8, 0.6) * waveTime() * 0.9;
      float h0 = waveHeight(d, iterations);
      float hx = waveHeight(d + vec2(e, 0.0), iterations);
      float hz = waveHeight(d + vec2(0.0, e), iterations);
      slope += vec2(hx - h0, hz - h0) / e * amp * river;
    }
  }

  // add the big swells on top. (WAVE_DEPTH / 0.3) appears like 9 times in this file, I should've made a define, too late now
  #ifdef WATER_SWELLS
  float swellVariance = 0.0;
  slope +=
    swellSlope(worldXZ, WAVE_SWELL * waterSwellMul() * noiseField * mix(0.12, 1.0, openness),
      viewXZ, footprint, swellVariance) *
    (WAVE_DEPTH / 0.3);
  slopeVariance += swellVariance * pow2(WAVE_DEPTH / 0.3);
  #endif

  // micro ripples only within 16 blocks. past that nobody sees them
  float microFade = 1.0 - smoothstep(3.0, 16.0, dist);
  float microAmp = WAVE_RIPPLES * field * heightmapFactor * (WAVE_DEPTH / 0.3);
  // 4 * 0.5 * 0.018 * 0.018... the variance of the micro waves. I did this math on a napkin. the napkin is gone
  slopeVariance += 4.0 * 0.5 * 0.018 * 0.018 * pow2(microAmp) * (1.0 - microFade * microFade);
  if (microFade > 0.0) {
    // why is this expression split across 7 lines? prettier did it. I'm not fighting prettier
    slope +=
      microSlope(worldXZ) *
      WAVE_RIPPLES *
      microFade *
      field *
      heightmapFactor *
      (WAVE_DEPTH / 0.3);
  }

  return slope;
}

// lazy version again. "unused" because we don't care about variance here
vec2 waterSurfaceSlope(
  vec2 worldXZ,
  float heightmapFactor,
  float openness,
  float dist
) {
  float unused;
  return waterSurfaceSlope(worldXZ, heightmapFactor, openness, dist, vec2(1.0, 0.0), vec2(0.0), unused);
}

// turn the slope into an actual normal vector, then rotate it to whatever face the water is on. minus signs because I said so (and because it was inverted)
vec3 slopeToNormal(vec2 slope, vec3 worldFaceNormal) {
  vec3 n = normalize(vec3(-slope.x, 1.0, -slope.y));
  return normalize(rotate(n, vec3(0.0, 1.0, 0.0), worldFaceNormal));
```

## 8. replaces Glimmer lines 74-92 — in `waveNormal()`

```glsl
  return slopeToNormal(
    waterSurfaceSlope(pos, heightmapFactor, 1.0, 0.0),
    worldFaceNormal
```

## 9. replaces Glimmer lines 96-97 — in `waveNormal()`

```glsl
}

// waveNormal version 2: now with coastal stuff and extra slope!
vec3 waveNormal(
  vec2 pos,
  vec3 worldFaceNormal,
  float heightmapFactor,
  float coastalFactor,
  float dist,
  vec2 extraSlope
) {
  #ifdef PIXEL_LOCKED_LIGHTING
  pos = floor(pos * PIXEL_SIZE) / PIXEL_SIZE;
  #endif
  vec2 slope =
    waterSurfaceSlope(pos, heightmapFactor, coastalFactor, dist) + extraSlope;
  return slopeToNormal(slope, worldFaceNormal);
}

// waveNormal version 3: the deluxe edition with footprint filtering. the one that actually gets used in the important places I think
vec3 waveNormal(
  vec2 pos,
  vec3 worldFaceNormal,
  float heightmapFactor,
  float coastalFactor,
  float dist,
  vec2 extraSlope,
  vec2 viewXZ,
  vec2 footprint,
  out float slopeVariance
) {
  #ifdef PIXEL_LOCKED_LIGHTING
  pos = floor(pos * PIXEL_SIZE) / PIXEL_SIZE;
  #endif
  vec2 slope =
    waterSurfaceSlope(pos, heightmapFactor, coastalFactor, dist, viewXZ, footprint, slopeVariance) +
    extraSlope;
  return slopeToNormal(slope, worldFaceNormal);
}

// how much water one pixel covers. x stretches when you look at water at a grazing angle. 0.002 so it doesn't explode at the horizon
vec2 waterFootprint(float dist, float cosView) {
  float pixelAngle = 2.0 / (gbufferProjection[1][1] * viewHeight);
  return vec2(dist * pixelAngle / max(cosView, 0.002), dist * pixelAngle);
}

// (Heitz 2014) G2 / G1(view) at the mirror configuration. it's a fancy masking term that darkens rough reflections. I read the paper abstract and gave up
float waterReflectionMasking(float alpha, float NoV) {
  // 1e-4 floor. every function in this file has a "please don't divide by zero" line. this is my life now
  float cos2 = max(NoV * NoV, 1e-4);
  float lambda = 0.5 * (sqrt(1.0 + alpha * alpha * (1.0 - cos2) / cos2) - 1.0);
  return (1.0 + lambda) / (1.0 + 2.0 * lambda);
```

