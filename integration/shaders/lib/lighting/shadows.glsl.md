# Halcyon changes to Glimmer file `shaders/lib/lighting/shadows.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 19

```glsl
#if defined CAUSTICS && CAUSTICS_MODE == 2
#include "/lib/water/caustics.glsl"
#endif
```

## 2. replaces Glimmer lines 85-86 — in `getShadowing()`

```glsl
    // henyey greenstein. sounds like a law firm. it's a phase function, whatever that is. 0.3 and 2.2 are vibes
    float VoL = dot(normalize(feetPlayerPos), worldLightDir);
    scatter *= henyeyGreenstein(0.3, VoL) * 2.2;
```

## 3. inserted after Glimmer line 145 — in `getShadowing()`

```glsl
      // random rotation per pixel so the samples don't make an obvious pattern. noise fixes everything
      float rot = noise * 2.0 * PI;
      mat2 rotM = mat2(cos(rot), sin(rot), -sin(rot), cos(rot));

      bool resolved = false;
      #if SHADOW_SAMPLES >= 16
      // shortcut: take 4 test samples first. if they all agree, skip the other like 60. free fps, hell yeah
      const int probeStride = SHADOW_SAMPLES / 4;
      vec3 probeMin = vec3(1e6), probeMax = vec3(-1e6), probeSum = vec3(0.0);
      for (int k = 0; k < 4; k++) {
        int i = k * probeStride + probeStride / 2;
        float r = sqrt((float(i) + 0.5) / float(SHADOW_SAMPLES));
        float a = float(i) * goldenAngle;
        vec3 offset = vec3(rotM * vec2(cos(a), sin(a)) * r, 0.0) * sampleRadius;
        vec3 s = sampleShadow(shadowScreenPos + offset);
        probeMin = min(probeMin, s);
        probeMax = max(probeMax, s);
        probeSum += s;
      }
      if (maxVec3(probeMax - probeMin) < 1e-3) {
        shadow = probeSum * 0.25;
        resolved = true;
      }
      #endif

      if (!resolved) {
```

## 4. replaces Glimmer lines 147-148 — in `getShadowing()`

```glsl
          float r = sqrt((float(i) + 0.5) / float(SHADOW_SAMPLES));
          float a = float(i) * goldenAngle;
          vec3 offset = vec3(rotM * vec2(cos(a), sin(a)) * r, 0.0) * sampleRadius;
```

## 5. inserted after Glimmer line 152 — in `getShadowing()`

```glsl
      }
```

## 6. inserted after Glimmer line 159 — in `getShadowing()`

```glsl
#if CAUSTICS_MODE == 2
      // the procedural one. prettier. slower. like a peacock
      float caustics = proceduralCaustics(feetPlayerPos + cameraPosition,
                                          worldLightDir, blockerDistance,
                                          length(feetPlayerPos));
#else
```

## 7. inserted after Glimmer line 164 — in `getShadowing()`

```glsl
#endif
```

