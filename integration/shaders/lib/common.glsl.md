# Halcyon changes to Glimmer file `shaders/lib/common.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 79

```glsl
#define weatherSkylightColor mix(skylightColor, vec3(0.86, 0.93, 1.0) * luminance(sunlightColor) * 0.045, pow(wetness, rcp(5.0)))
```

## 2. inserted after Glimmer line 120

```glsl
#ifdef SSR_OPAQUE
/*
    const int colortex8Format = RGBA8;
*/
#endif

// SSGI hogs FOUR buffers. greedy little feature
#ifdef SSGI
/*
    const int colortex11Format = RGBA8;
    const int colortex12Format = RGBA16F;
    const int colortex13Format = RGBA16F;
    const int colortex14Format = RGBA16F;
*/
const bool colortex13Clear = false;
const bool colortex14Clear = false;
#endif

// clouds get three buffers. clouds get whatever clouds want
#ifdef VOLUMETRIC_CLOUDS
/*
    const int colortex10Format = RGBA16F;
    const int colortex15Format = RGBA8;
    const int colortex9Format = RG16F;
*/
const bool colortex10Clear = false;
const bool colortex9Clear = false;
const vec4 colortex10ClearColor = vec4(0.0, 0.0, 0.0, 1.0);
#endif
```

