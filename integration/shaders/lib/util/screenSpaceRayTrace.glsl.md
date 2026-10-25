# Halcyon changes to Glimmer file `shaders/lib/util/screenSpaceRayTrace.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 52 — in `rayIntersects()`

```glsl
  rayPos = vec3(0.0);
```

