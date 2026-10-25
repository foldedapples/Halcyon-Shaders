# Halcyon changes to Glimmer file `shaders/program/final.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 34 — in `main()`

```glsl
#include "/lib/post/heatHaze.glsl"
```

## 2. inserted after Glimmer line 42 — in `main()`

```glsl
  // nether gets wobbly heat haze. clamp so we don't sample off the edge of the screen and get garbage
  #ifdef WORLD_THE_NETHER
  color = texture(colortex0, clamp01(texcoord + heatHazeOffset(texcoord)));
  #else
```

## 3. inserted after Glimmer line 43 — in `main()`

```glsl
  #endif
```

## 4. replaces Glimmer line 54 — in `main()`

```glsl
        0.01 * BLOOM_STRENGTH + rain * 0.06 * RAIN_STREAK_OPACITY + wetness * 0.04 * EBS.y + blindness
```

## 5. inserted after Glimmer line 62 — in `main()`

```glsl
  // color grading, unless debug view 5 or 8. I don't remember what 5 and 8 are anymore
  #if DEBUG_VIEW != 5 && DEBUG_VIEW != 8
  color.rgb = gradeLinear(color.rgb);
  #endif
  #if DEBUG_VIEW == 8
  color.rgb = pow(clamp01(color.rgb), vec3(rcp(2.2))); // debug view 8 = plain gamma 2.2, no fancy tonemap. rcp is 1/x, took me a while to figure that out
  #else
```

## 6. inserted after Glimmer line 63 — in `main()`

```glsl
  #endif

  #if DEBUG_VIEW != 5 && DEBUG_VIEW != 8
```

## 7. inserted after Glimmer line 65 — in `main()`

```glsl
  #else
  color.a = 1.0;
  #endif
```

