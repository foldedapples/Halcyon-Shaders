# Halcyon changes to Glimmer file `shaders/program/gbuffers_skybasic.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 42 — in `main()`

```glsl
    #ifdef REALISTIC_STARS
    color = vec4(0.0); // realistic stars on? kill the vanilla ones too, the real starfield in stars.glsl takes over. vanilla stars look like dandruff
    #endif
```

