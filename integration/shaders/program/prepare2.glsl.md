# Halcyon changes to Glimmer file `shaders/program/prepare2.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 28 — in `main()`

```glsl
  vec3 skylightSum = vec3(0.0);
```

## 2. replaces Glimmer line 31 — in `main()`

```glsl
      vec2 noise = (vec2(x, y) + 0.5) / SKYLIGHT_SAMPLES; // +0.5 to sample the middle of each grid cell, not the corner
```

## 3. replaces Glimmer lines 37-38 — in `main()`

```glsl
      skylightSum += getSky(
        vec3(cos(phi) * sinTheta, cosTheta, sin(phi) * sinTheta),
```

## 4. replaces Glimmer line 45 — in `main()`

```glsl
  skylightColor = skylightSum / float(samples); // average. sum / count. the one bit of math I'd stake my life on
```

