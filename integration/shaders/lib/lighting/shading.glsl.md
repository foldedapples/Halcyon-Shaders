# Halcyon changes to Glimmer file `shaders/lib/lighting/shading.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 20

```glsl
#ifdef WORLD_THE_END
#include "/lib/atmosphere/sky/endAmbient.glsl"
#endif
```

## 2. inserted after Glimmer line 54 — in `getShadedColor()`

```glsl
  #if DEBUG_VIEW == 6 // sun only, for when I need to figure out which part is fucked
  return max0(color);
  #elif DEBUG_VIEW == 7 // sky light only. it's always the sky's fault
  return max0(material.albedo * weatherSkylightColor * pow2(lightmap.y) * ambientOcclusion);
  #endif
```

## 3. replaces Glimmer line 63 — in `getShadedColor()`

```glsl
  // the warden darkness effect. 2.5 makes it scary enough. I jumped the first time
  ambient *= clamp01(1.0 - darknessLightFactor * 2.5);

  // how much of the torch light goes to shiny instead of diffuse. energy conservation or whatever the nerds call it
  float NoVb = clamp01(dot(mappedNormal, normalize(-viewPos)));
  vec3 blockSpecShare =
    fresnelRoughness(material, NoVb) * pow2(1.0 - material.roughness);
```

## 4. inserted after Glimmer line 71 — in `getShadedColor()`

```glsl
        (1.0 - blockSpecShare) *
```

## 5. inserted after Glimmer line 92 — in `getShadedColor()`

```glsl
  #ifdef WORLD_THE_END
  vec3 specular = endAmbientSky(mat3(gbufferModelViewInverse) * reflected);
  #else
```

## 6. inserted after Glimmer line 93 — in `getShadedColor()`

```glsl
  #endif
```

## 7. inserted after Glimmer line 104 — in `getShadedColor()`

```glsl
  {
    // torches reflecting off shiny stuff. the 0.6 is me squinting at an iron block for 20 minutes
    vec3 blockIrradiance =
      blocklight * BLOCKLIGHT_STRENGTH * 0.002 * clamp01(1.0 - darknessLightFactor * 2.5);
    float occlusion = material.ao * 0.5 + 0.5;
    color += blockIrradiance * blockSpecShare * occlusion * 0.6 * ambientOcclusion;
  }
```

