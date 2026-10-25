# Halcyon changes to Glimmer file `shaders/lib/atmosphere/clouds.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 65 — in `multipleScattering()`

```glsl
#ifdef VOLUMETRIC_CLOUDS
#include "/lib/atmosphere/volumetricClouds.glsl"
#endif
```

## 2. inserted after Glimmer line 120 — in `getCloudDensity()`

```glsl
#define CLOUD_SHADOW_MAP_RES float(CLOUD_SHADOW_RES)

// snaps the cloud shadow map to whole texels so the shadows don't swim around when you walk. took me forever to figure out why they were swimming
vec2 cloudShadowMapOrigin() {
  float texel = CLOUD_SHADOW_RANGE / CLOUD_SHADOW_MAP_RES;
  return floor(cameraPosition.xz / texel + 0.5) * texel;
}

#ifdef VOLUMETRIC_CLOUDS
// what height the shadow map pretends to live at. min(0, ...) so it never goes above the camera. or below. one of those
float cloudShadowMapHeight() {
  return min(0.0, vcLayer().x - 1.0 - cameraPosition.y);
}
#endif
```

## 3. inserted after Glimmer line 122 — in `getCloudShadow()`

```glsl
#ifndef CLOUDS
  return vec3(1.0);
#endif
#ifdef VOLUMETRIC_CLOUDS
#ifndef WORLD_OVERWORLD
  return vec3(1.0);
#endif
#ifndef PREPARE_CLOUD_SHADOW_MAP
  {
    // project the point up along the sun direction onto the shadow map. max 0.05 so we don't divide by zero at sunset and blow up
    float ly = max(worldLightDir.y, 0.05);
    vec2 xz = origin.xz + cameraPosition.xz +
              worldLightDir.xz / ly * (cloudShadowMapHeight() - origin.y);
    vec2 uv = (xz - cloudShadowMapOrigin()) / CLOUD_SHADOW_RANGE + 0.5;
    // clamp01(uv) == uv is a sneaky way to check "is uv inside 0..1". I felt so clever writing this
    if (clamp01(uv) == uv) {
      vec3 baked = texture(colortex15, uv).rgb;
      vec2 e = min(uv, 1.0 - uv);
      float edge = smoothstep(0.0, 0.05, min(e.x, e.y));
      if (edge >= 1.0) return baked;
      return mix(getVolumetricCloudShadow(origin, 2), baked, edge); // near the edge of the map blend into the slow version so there's no seam
    }
    return getVolumetricCloudShadow(origin, 2);
  }
#endif
  return getVolumetricCloudShadow(origin);
#endif
```

## 4. inserted after Glimmer line 140 — in `getClouds()`

```glsl
#endif

#ifdef VOLUMETRIC_CLOUDS
  {
    float vcJitter = 0.5;
#if defined fsh && !defined CLOUD_STABLE_JITTER
    vcJitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
#endif
    return getVolumetricClouds(origin, worldDir, VC_REFLECTION_STEPS_Q, vcJitter,
                               transmittance);
  }
```

## 5. replaces Glimmer line 169 — in `getClouds()`

```glsl
      skylightColor + sunlightColor * (1.0 + 6.5 * float(lightDir == sunDir)) *
```

