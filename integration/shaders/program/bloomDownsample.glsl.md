# Halcyon changes to Glimmer file `shaders/program/bloomDownsample.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 41 — in `main()`

```glsl
  int bloomMaterial = int(texture(colortex1, texcoord).a * 255.0 + 0.5) + 1000; // +0.5 rounds it, +1000 because material IDs start at 1000 for some reason I'm too tired to look up
  if (bloomMaterial == 1022) bloomColor *= LAVA_BLOOM; // 1022 = lava. lava gets EXTRA glow because lava is fucking hot
```

