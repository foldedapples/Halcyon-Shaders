# Halcyon changes to Glimmer file `shaders/lib/atmosphere/sky/hillaireCommon.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 13-14

```glsl
// 0.2665 degrees = how big the sun looks. converted to radians because GLSL hates degrees as much as I hate GLSL
const float sunAngularRadius = 0.2665 * PI / 180.0 * SUN_SIZE;
const float moonAngularRadius = 0.26 * PI / 180.0 * MOON_SIZE;
```

## 2. replaces Glimmer lines 17-18

```glsl
const vec3 sunRadiance = sunIrradiance / (0.2 * PI / 180.0); // wait why 0.2 here and 0.2665 up there. I'm afraid to ask
const vec3 moonIrradiance = vec3(0.86, 0.93, 1.0) * 0.0029;
```

## 3. inserted after Glimmer line 131 — in `unmapAerialPerspectivePos()`

```glsl
#include "/lib/atmosphere/sky/celestial.glsl"
```

