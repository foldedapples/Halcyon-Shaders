# Halcyon changes to Glimmer file `shaders/program/c48_writeLuminance.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 34 — in `main()`

```glsl
// the shared buffer from the exposure compute. binding 2. I picked 2 by closing my eyes
#ifdef AUTO_EXPOSURE
layout(std430, binding = 2) buffer frameData {
  float averageLuminanceSmooth;
};
#endif
```

## 2. replaces Glimmer line 38 — in `main()`

```glsl
  // NaN and infinity detector. one bad pixel used to turn the WHOLE screen black for like a second. it haunted me for weeks
  bool bad = any(isnan(color.rgb)) || any(isinf(color.rgb));
  if (bad) color.rgb = vec3(0.0);
  // 65000 because half floats max out around 65504 and I'm not trying to find out what happens past that
  color.rgb = clamp(color.rgb, 0.0, 65000.0);
  // stash log2 brightness in alpha so the mipmap averages it in log space. geometric mean. a smart person told me to and I listened, for once
  color.a = log2(max(luminance(color.rgb), 1e-4));
  #ifdef AUTO_EXPOSURE
  // if the pixel was cursed, pretend it's average brightness so it doesn't drag the exposure around
  if (bad) color.a = log2(max(averageLuminanceSmooth, 1e-4));
  #endif
```

