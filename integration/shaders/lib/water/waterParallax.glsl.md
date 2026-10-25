# Halcyon changes to Glimmer file `shaders/lib/water/waterParallax.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 14-19 — in `getWaterParallaxPos()`

```glsl
// returns the fake position on the waves where your eye "actually" hits. trust me bro
vec2 getWaterParallaxPos(vec3 playerPos, float jitter, float heightScale) {
```

## 2. replaces Glimmer lines 23-33 — in `getWaterParallaxPos()`

```glsl
  vec3 dir = normalize(playerPos);
  // looking up or sideways at water? nope, not dealing with that, return early
  if (dir.y > -0.01 || heightScale <= 0.0) return playerPos.xz;

  float depth = WAVE_DEPTH * heightScale;
  float tMax = depth / -dir.y;
  // cap at 4 blocks or looking at the water at a shallow angle makes the loop go forever and the game dies
  tMax = min(tMax, 4.0);

  vec3 start = playerPos;
  float surfaceY = playerPos.y;
  float stepLen = tMax / float(WATER_PARALLAX_SAMPLES);

  // jitter the start, half a step, because full step looked weird. I tried
  float t = stepLen * jitter * 0.5;
  float tPrev = 0.0;
  bool hit = false;
```

## 3. replaces Glimmer lines 36-41 — in `getWaterParallaxPos()`

```glsl
    vec3 p = start + dir * t;
    // "1.0 - waveHeight" because the heightmap was upside down and I flipped it instead of fixing it properly
    float surf =
      surfaceY - (1.0 - waveHeight(p.xz + cameraPosition.xz, 8)) * depth;
    if (p.y <= surf) {
      hit = true;
      break;
```

## 4. replaces Glimmer line 44 — in `getWaterParallaxPos()`

```glsl
    tPrev = t;
    t += stepLen;
```

## 5. replaces Glimmer line 48 — in `getWaterParallaxPos()`

```glsl
  // never hit anything? just use the max distance and pray
  if (!hit) {
    t = tMax;
  }

  // binary search to refine the hit!! I learned binary search for a job interview and this is the only time I've ever used it
  float lo = tPrev;
  float hi = t;
  // 4 iterations because 2^4 = 16x more precise. that's enough for water. it's WATER.
  for (int i = 0; i < 4; i++) {
    float mid = 0.5 * (lo + hi);
    vec3 p = start + dir * mid;
    float surf =
      surfaceY - (1.0 - waveHeight(p.xz + cameraPosition.xz, 8)) * depth;
    if (p.y <= surf) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return (start + dir * hi).xz;
  #else
  return playerPos.xz;
```

## 6. Removed Glimmer code (replaces Glimmer lines 52-56) — in `getWaterParallaxPos()`

Halcyon deletes these Glimmer lines (no replacement).

