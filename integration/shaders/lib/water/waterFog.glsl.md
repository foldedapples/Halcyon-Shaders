# Halcyon changes to Glimmer file `shaders/lib/water/waterFog.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 18-19

```glsl
// water color presets. every number in here was picked by staring at a screenshot of the caribbean for 20 minutes
#if WATER_COLOR_PRESET == 1
#define WATER_ABSORPTION_BASE vec3(0.30, 0.050, 0.022)
#define WATER_SCATTERING_BASE vec3(0.0011, 0.0028, 0.0046)
#elif WATER_COLOR_PRESET == 2
#define WATER_ABSORPTION_BASE vec3(0.45, 0.110, 0.044)
#define WATER_SCATTERING_BASE vec3(0.0006, 0.0013, 0.0034)
#elif WATER_COLOR_PRESET == 3
// preset 3 is the swamp one. purple-ish absorption. it looks like soup. people asked for it
#define WATER_ABSORPTION_BASE vec3(0.25, 0.15, 0.30)
#define WATER_SCATTERING_BASE vec3(0.025, 0.035, 0.015)
#elif WATER_COLOR_PRESET == 4
#define WATER_ABSORPTION_BASE vec3(0.42, 0.098, 0.038)
#define WATER_SCATTERING_BASE vec3(0.0007, 0.0016, 0.0040)
// default water. red dies first, blue survives. that's why water is blue. I read that on a cereal box
#else
#define WATER_ABSORPTION_BASE vec3(0.38, 0.085, 0.034)
#define WATER_SCATTERING_BASE vec3(0.0009, 0.0019, 0.0040)
#endif

// saturation hack: average in log space then push away from the average. a guy on shadertoy did this and I just went "yep"
#define WATER_SATURATE(c) exp2(mix(vec3(dot(log2(c), vec3(1.0 / 3.0))), log2(c), WATER_SATURATION))
#define WATER_ABSORPTION (WATER_SATURATE(WATER_ABSORPTION_BASE) * (WATER_ABSORPTION_MOD / WATER_CLARITY))
#define WATER_SCATTERING (WATER_SATURATE(WATER_SCATTERING_BASE) * (WATER_SCATTERING_MOD / WATER_CLARITY))
```

## 2. inserted after Glimmer line 20

```glsl
// exp2 of some slider stuff. the deep darkness slider makes deep water darker. self-explanatory, for once
#define WATER_INSCATTER_GAIN exp2((0.5 - WATER_DEEP_DARKNESS) * 2.0)

// 0.5 * 0.93, why not just write 0.465? because then I'd forget where it came from. (I already forgot where it came from)
#define WATER_SKY_INSCATTER (0.5 * 0.93)

// snell's law for cosines. 1.33 again. this number is following me
float waterRefractedCos(float cosAir) {
  return sqrt(1.0 - (1.0 - pow2(clamp01(cosAir))) / (1.33 * 1.33));
}

// fresnel (schlick version). 0.02 reflects, the rest goes in. pow5 because schlick said so and who am I to argue
float waterSunTransmission(float cosAir) {
  return 1.0 - (0.02 + 0.98 * pow5(1.0 - clamp01(cosAir)));
}

// bend the sunlight into the water. divide x and z by 1.33, fix y. physically sus but looks right
vec3 waterRefractedLightDir(vec3 worldLight) {
  return vec3(worldLight.x / 1.33, waterRefractedCos(worldLight.y), worldLight.z / 1.33);
}
```

## 3. replaces Glimmer line 24 — in `waterFog()`

```glsl
// THE water fog function. a and b are the start and end of the path through water. dhFactor is for distant horizons and I barely understand it
vec3 waterFog(vec3 color, vec3 a, vec3 b, float dhFactor, vec3 scatterFactor, float densityMul) {
```

## 4. replaces Glimmer lines 34-40 — in `waterFog()`

```glsl
  float d = distance(a, b);
  vec3 ext = waterExtinction * WATER_DENSITY * densityMul;
  // beer's law! the light just. dies. exponentially. like my motivation
  vec3 transmittance = exp(-ext * d);

  // mu is how much the ray goes downward. downward rays get darker faster because you're going deeper. smart, right? I didn't come up with it
  vec3 worldStep = mat3(gbufferModelViewInverse) * (b - a);
  float mu = max(-worldStep.y, 0.0) / max(d, 1e-4);
  vec3 waterLight = waterRefractedLightDir(worldLightDir);
  float cosL = waterLight.y;
  // 1e-6 so nothing divides by zero, I've been burned before
  vec3 kSun = max(ext * (1.0 + mu / cosL), 1e-6);
  vec3 kSky = max(ext * (1.0 + mu * 1.2), 1e-6);
  // sun light scattered in. the (1 - exp) / k thing is the integral of beer's law. I copied it off a whiteboard in my head
  vec3 sunPart = weatherSunlightColor * waterSunTransmission(worldLightDir.y) *
    henyeyGreenstein(0.4, dot(normalize(worldStep), waterLight)) *
    (1.0 - exp(-kSun * d)) / kSun;
  // skylight scattered in. 1.2 is a fudge factor. everything is a fudge factor if you squint
  vec3 skyPart = EBS.y * weatherSkylightColor * WATER_SKY_INSCATTER *
    (1.0 - exp(-kSky * d)) / kSky;
```

## 5. replaces Glimmer line 43 — in `waterFog()`

```glsl
  sunPart *= sunVisibilitySmooth;
  skyPart *= sunVisibilitySmooth;
```

## 6. replaces Glimmer line 46 — in `waterFog()`

```glsl
  vec3 scatter = (sunPart + skyPart) * WATER_SCATTERING * WATER_DENSITY * densityMul *
    WATER_INSCATTER_GAIN;
```

## 7. inserted after Glimmer line 50 — in `waterFog()`

```glsl
// lazy overloads so I don't have to type 1.0 everywhere
vec3 waterFog(vec3 color, vec3 a, vec3 b, float dhFactor, vec3 scatterFactor) {
  return waterFog(color, a, b, dhFactor, scatterFactor, 1.0);
}
```

## 8. replaces Glimmer line 53 — in `waterFog()`

```glsl
  return waterFog(color, a, b, 0.0, scatterFactor, 1.0);
}

// floaty particles in the water. dirt. fish poop. whatever. 0.022 0.028 0.032
#define UW_PARTICLE_SCATTERING (vec3(0.022, 0.028, 0.032) * UNDERWATER_HAZE)

vec3 uwScattering() {
  return UW_PARTICLE_SCATTERING + WATER_SCATTERING;
}

vec3 uwExtinction() {
  return (WATER_ABSORPTION + uwScattering()) * UNDERWATER_FOG;
}

// guess how deep the camera is using the sky light. 15 blocks max. totally accurate, I swear (it's not)
float uwCameraDepth() {
  return (1.0 - EBS.y) * 15.0 + 0.5;
}

// how much sun reaches a given depth underwater. beer's law again, I told you it's everywhere
vec3 uwSunlightAtDepth(float depth) {
  float cosAir = abs((mat3(gbufferModelViewInverse) * lightDir).y);
  return weatherSunlightColor * waterSunTransmission(cosAir) *
    exp(-uwExtinction() * depth / waterRefractedCos(cosAir));
}

vec3 uwSkylightAtDepth(float depth) {
  return weatherSkylightColor * exp(-uwExtinction() * depth);
}

// fog for when YOU are the one underwater. totally different code path because of course it is
vec3 underwaterFog(vec3 color, vec3 a, vec3 b, bool includeSun) {
  float d = distance(a, b);
  if (d < 0.01) return color;
  // 1e-6 floor. you know the drill by now
  vec3 ext = max(uwExtinction(), 1e-6);
  vec3 T = exp(-ext * d);
  float depth = uwCameraDepth();
  vec3 light = uwSkylightAtDepth(depth);
  if (includeSun) {
    vec3 worldRay = mat3(gbufferModelViewInverse) * normalize(b - a);
    // henyey-greenstein 0.4 here, 0.65 in the shafts file. no I don't know why they're different. stop asking
    light += uwSunlightAtDepth(depth) * sunVisibilitySmooth *
      henyeyGreenstein(0.4, dot(worldRay, waterRefractedLightDir(worldLightDir)));
  }
  return color * T +
    light * (uwScattering() * UNDERWATER_FOG / ext) * (1.0 - T) * WATER_INSCATTER_GAIN;
}

vec3 underwaterFog(vec3 color, vec3 a, vec3 b) {
  return underwaterFog(color, a, b, true);
```

