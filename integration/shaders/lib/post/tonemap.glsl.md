# Halcyon changes to Glimmer file `shaders/lib/post/tonemap.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. Removed Glimmer code (replaces Glimmer line 161) — in `tonyMcMapface()`

Halcyon deletes these Glimmer lines (no replacement).

## 2. replaces Glimmer line 170 — in `tonyMcMapface()`

```glsl
  return pow(max0(texture(tonyMcMapfaceTex, coord).rgb), vec3(rcp(2.2)));
```

