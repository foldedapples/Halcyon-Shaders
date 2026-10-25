# Halcyon changes to Glimmer file `shaders/program/shadow.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 84 — in `main()`

```glsl
    if (isLava(materialID)) {
      data.emission = clamp01(data.emission * LAVA_LIGHT_STRENGTH); // lava light strength slider. clamp it or someone sets it to 999 and the world melts
    }
```

## 2. replaces Glimmer line 146 — in `main()`

```glsl
  if (color.a < alphaTestRef || isLightBlock(materialID)) { // light-emitting blocks don't cast shadows. a torch shadowing itself would be dumb
```

