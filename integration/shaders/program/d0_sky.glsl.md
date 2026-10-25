# Halcyon changes to Glimmer file `shaders/program/d0_sky.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 32 — in `main()`

```glsl
#if defined VOLUMETRIC_CLOUDS && defined CLOUDS
#include "/lib/atmosphere/cloudComposite.glsl"
#endif
```

## 2. inserted after Glimmer line 69 — in `main()`

```glsl
    // two cloud paths: fancy volumetric ones, or cheap flat ones for potato PCs like mine
    #if defined VOLUMETRIC_CLOUDS && defined CLOUDS
    vec4 cloudData = sampleCloudsUpsampled(texcoord, CLOUD_SKY_DISTANCE);
    vec3 scattering = cloudData.rgb;
    transmittance = vec3(cloudData.a);
    #else
```

## 3. inserted after Glimmer line 71 — in `main()`

```glsl
    #endif
```

