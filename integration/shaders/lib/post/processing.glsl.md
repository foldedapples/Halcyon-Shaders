# Halcyon changes to Glimmer file `shaders/lib/post/processing.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 6-26 — in `blackbodyRGB()`

```glsl
// white balance. turns a temperature in kelvin into a color. blackbody RGB (Tanner Helland's fit), normalised to 6500K
// look at these numbers. 0.1332047592. 1.19625408914. TEN decimal places. somebody fit a curve to a chart and I am eternally grateful
vec3 blackbodyRGB(float kelvin) {
  float t = kelvin / 100.0;
  vec3 c;
  // 66 is the magic temperature where everything changes. why 66? ask Tanner, I just work here
  c.r = t <= 66.0 ? 1.0 : clamp01(1.292936 * pow(t - 60.0, -0.1332047592));
  c.g = t <= 66.0
    ? clamp01(0.3900815787 * log(t) - 0.6318414438)
    : clamp01(1.129890861 * pow(t - 60.0, -0.0755148492));
  c.b = t >= 66.0
    ? 1.0
    : (t <= 19.0 ? 0.0 : clamp01(0.5432067891 * log(t - 10.0) - 1.19625408914));
  return pow(c, vec3(2.2)); // 2.2 strikes again
```

## 2. replaces Glimmer lines 30-44 — in `whiteBalanceGain()`

```glsl
// divide by 6500K so "normal" stays normal, then divide by luminance so it doesn't get brighter. took 3 tries
vec3 whiteBalanceGain(float kelvin) {
  vec3 wb = blackbodyRGB(6500.0) / blackbodyRGB(kelvin);
  return wb / luminance(wb);
}

// the presets. I spent more time tweaking these than writing actual features. no regrets
#if GRADE_PROFILE == 1 // Natural (the "I touched grass once" preset)
  #define G_EV 0.0
  #define G_KELVIN 6500
  #define G_SAT 1.12
  #define G_CONTRAST 1.1
  #define G_VIB 1.1
  #define G_SPLIT 0.0
#elif GRADE_PROFILE == 2 // Vibrant, for people who think minecraft isn't saturated enough already
  #define G_EV 0.0
  #define G_KELVIN 6600
  #define G_SAT 1.25
  #define G_CONTRAST 1.15
  #define G_VIB 1.25
  #define G_SPLIT 0.4
#elif GRADE_PROFILE == 3 // Cinematic. teal and orange baby. michael bay would be proud
  #define G_EV -0.1
  #define G_KELVIN 6800
  #define G_SAT 1.12
  #define G_CONTRAST 1.28
  #define G_VIB 1.1
  #define G_SPLIT 1.0
#elif GRADE_PROFILE == 4 // Photorealistic (it's still blocks, calm down)
  #define G_EV 0.0
  #define G_KELVIN 6500
  #define G_SAT 1.05
  #define G_CONTRAST 1.08
  #define G_VIB 1.0
  #define G_SPLIT 0.0
#else // Off: just the sliders, you're on your own
  #define G_EV 0.0
  #define G_KELVIN 6500
  #define G_SAT 1.0
  #define G_CONTRAST 1.0
  #define G_VIB 1.0
  #define G_SPLIT 0.0
#endif

// contrast spins around this brightness. 0.32. it's middle gray-ish. someone said 0.18 but that looked like shit
const float GRADE_PIVOT = 0.32;

vec3 gradeLinear(vec3 c) {
  c *= exp2(G_EV); // exposure in "stops", which is a photographer word. I am not a photographer

  #if G_KELVIN != 6500 || WHITE_BALANCE != 6500
  c *= whiteBalanceGain(float(G_KELVIN)) * whiteBalanceGain(float(WHITE_BALANCE));
  #endif

  float l = max(luminance(c), 1e-6);
  float stops = log2(l / GRADE_PIVOT);

  // contrast in log space. clamped to +-4 stops because without it the sun went full supernova
  float k = G_CONTRAST * CONTRAST;
  c *= exp2(clamp(stops * (k - 1.0), -4.0, 4.0));

  #if GRADE_PROFILE == 2 || GRADE_PROFILE == 3
  // split toning: blue-ish shadows, orange-ish highlights. every movie since 2007 does this. now my blocks do too
  vec3 shadowTint = vec3(0.96, 1.0, 1.06);
  vec3 highlightTint = vec3(1.05, 1.0, 0.93);
  vec3 tint = mix(vec3(1.0), shadowTint, (1.0 - smoothstep(-3.0, 0.0, stops)) * G_SPLIT);
  tint *= mix(vec3(1.0), highlightTint, smoothstep(0.0, 3.0, stops) * G_SPLIT);
  c *= tint / luminance(tint);
  #endif

  // saturation: mix between gray and color. past 1 = extra color. it's literally that simple and it took me a week
  l = luminance(c);
  return max0(mix(vec3(l), c, G_SAT * SATURATION));
}

// vibrance = saturation but it leaves already-colorful stuff alone. like saturation with manners
vec3 vibrance(vec3 c, float amount) {
  float maxC = max3(c.r, c.g, c.b);
  float minC = min3(c.r, c.g, c.b);
  float sat = maxC > 1e-4 ? clamp01((maxC - minC) / maxC) : 0.0;
  // go easy on green. without this the grass turned into radioactive slime. ask me how I know
  float greenDominance = smoothstep(0.15, 0.5, (c.g - max(c.r, c.b)) / max(maxC, 1e-4));
  float l = luminance(c);
  float boost = (amount - 1.0) * (1.0 - sat) * (1.0 - 0.5 * greenDominance);
  return max0(mix(vec3(l), c, 1.0 + boost));
```

## 3. replaces Glimmer line 48 — in `postProcess()`

```glsl
  color.rgb = vibrance(color.rgb, G_VIB + (VIBRANCE - 1.0));
  color.a = 1.0;
  return color;
```

