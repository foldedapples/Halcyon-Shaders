# Halcyon changes to Glimmer file `shaders/lib/common/uniforms.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 143

```glsl
uniform sampler2D moonTex;
uniform sampler3D cloudNoiseTex;
// night sky textures for stars.glsl. made with tools/nasa_night_sky.py, a python script I ran once and was too scared to run again
uniform sampler2D milkyWayTex;
uniform sampler2D starCatalogTex;
```

## 2. inserted after Glimmer line 192

```glsl
uniform float oceanBiomeSmooth;
uniform float riverBiomeSmooth;

uniform float surfaceWetness;
uniform float puddleAmount;
```

