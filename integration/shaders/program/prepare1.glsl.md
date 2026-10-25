# Halcyon changes to Glimmer file `shaders/program/prepare1.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 32 — in `main()`

```glsl
#define CLOUD_STABLE_JITTER // stable jitter so the reflection clouds don't shimmer like a mirage. must come BEFORE the include or it does nothing. found that out the hard way
```

