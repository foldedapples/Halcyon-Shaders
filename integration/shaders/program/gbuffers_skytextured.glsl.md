# Halcyon changes to Glimmer file `shaders/program/gbuffers_skytextured.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 43 — in `main()`

```glsl
  // custom moon on? toss the vanilla sun AND moon, the fancy custom ones get drawn somewhere else
  #ifdef CUSTOM_MOON
  if (
    renderStage == MC_RENDER_STAGE_MOON ||
    renderStage == MC_RENDER_STAGE_SUN
  ) {
    discard;
  }
  #endif
```

