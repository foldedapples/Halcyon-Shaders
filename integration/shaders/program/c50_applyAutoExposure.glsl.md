# Halcyon changes to Glimmer file `shaders/program/c50_applyAutoExposure.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. Removed Glimmer code (replaces Glimmer line 37) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 2. replaces Glimmer line 45 — in `main()`

```glsl
  // debug view 4 skips auto exposure. I don't remember what debug view 4 shows. something important probably
  #if defined AUTO_EXPOSURE && DEBUG_VIEW != 4
```

## 3. inserted after Glimmer line 59 — in `main()`

```glsl
  // the end gets a flat 0.15 because the end has no sun and frankly no rules
  #elif defined WORLD_THE_END
  float targetAverageLuminance = 0.15;
```

## 4. replaces Glimmer line 61 — in `main()`

```glsl
  // nether and everything else: same as day. the nether is basically a giant oven so whatever
  float targetAverageLuminance = pow(140.0 / 255.0, 2.2);
```

## 5. replaces Glimmer line 64 — in `main()`

```glsl
  // 0.6 key value. photographers say 0.18 is middle gray. I said 0.6. I'm not a photographer
  float key = targetAverageLuminance * 0.6;
  // EV = exposure value. log2 of how much we need to brighten. camera nerds, please don't email me
  float ev = log2(key / (float(EXPOSURE) * averageLuminanceSmooth));
  #ifdef WORLD_THE_NETHER
  // nether gets its exposure capped at +1 EV and then the nether slider added. otherwise the nether is a lava sun
  ev = clamp(ev, float(EXPOSURE_MIN_EV), min(float(EXPOSURE_MAX_EV), 1.0)) + NETHER_EXPOSURE;
  #else
  ev = clamp(ev, float(EXPOSURE_MIN_EV), float(EXPOSURE_MAX_EV));
  #endif
  // back from log land to regular multiply land
  float exposure = float(EXPOSURE) * exp2(ev);
```

## 6. inserted after Glimmer line 68 — in `main()`

```glsl
  #ifdef WORLD_THE_NETHER
  color.rgb *= exp2(NETHER_EXPOSURE);
  #endif
```

