# Halcyon changes to Glimmer file `shaders/program/c49_computeAutoExposure.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 30 — in `main()`

```glsl
// only pull in the cloud code if every single cloud-shadow thing is on. four defines. FOUR. I hate this ifdef jungle
#if defined WORLD_OVERWORLD && defined CLOUDS && defined VOLUMETRIC_CLOUDS && defined CLOUD_SHADOWS
#include "/lib/atmosphere/clouds.glsl"
#endif
```

## 2. replaces Glimmer lines 44-47 — in `main()`

```glsl
    // exp2 to undo the log2 from the last pass. log then exp, the circle of life
    float averageLuminance = exp2(textureLod(colortex0, vec2(0.5), maxMipLevel).a);
    // cloud shadow compensation. without this the exposure freaks out every time a cloud goes over the sun. this block nearly killed me
    #if defined WORLD_OVERWORLD && defined CLOUDS && defined VOLUMETRIC_CLOUDS && defined CLOUD_SHADOWS
    {
      // which way the camera faces, flattened onto the ground. so we can peek at the cloud shadow ahead of us
      vec3 ahead = mat3(gbufferModelViewInverse) * vec3(0.0, 0.0, -1.0);
      ahead.y = 0.0;
      ahead = dot(ahead, ahead) > 1e-6 ? normalize(ahead) : vec3(0.0);
      // sample cloud shadow here, 24 blocks ahead, and 64 ahead. average. 24 and 64 are vibes, pure vibes
      float cs = (luminance(getCloudShadow(vec3(0.0))) +
                  luminance(getCloudShadow(ahead * 24.0)) +
                  luminance(getCloudShadow(ahead * 64.0))) / 3.0;
      // how much of the lighting is sun vs sky. divide by PI because lambert or something. physics people always divide by pi
      float sunPart = luminance(weatherSunlightColor) * max(worldLightDir.y, 0.0) / PI;
      float skyPart = luminance(weatherSkylightColor);
      float open = sunPart + skyPart;
      float shaded = sunPart * cs + skyPart;
      // ratio of shaded to unshaded light. 1e-7 check so we don't divide by zero at night like an idiot (I was that idiot)
      float r = open > 1e-7 ? shaded / open : 1.0;
      // clamp to 0.05 so a giant cloud doesn't make the exposure go to the moon
      r = mix(1.0, clamp(r, 0.05, 1.0), CLOUD_SHADOW_VISIBILITY * EBS.y);
      averageLuminance /= r;
    }
    #endif
    // NaN cleanup crew. if anything's broken, fall back to whatever's not broken. it's NaNs all the way down
    if (isnan(averageLuminance) || isinf(averageLuminance)) averageLuminance = averageLuminanceSmooth;
    if (isnan(averageLuminanceSmooth) || isinf(averageLuminanceSmooth)) averageLuminanceSmooth = averageLuminance;
    if (averageLuminanceSmooth <= 0.0) averageLuminanceSmooth = averageLuminance;
    // smooth out the exposure over time so it doesn't flicker. exp2 of negative speed times time = frame-rate independent fade. reddit taught me this
    averageLuminanceSmooth = mix(averageLuminance, averageLuminanceSmooth, clamp01(exp2(frameTime * -EXPOSURE_SPEED)));

    // never let it hit zero or the next pass divides by it and everything becomes white. a white screen. for days
    averageLuminanceSmooth = max(averageLuminanceSmooth, 1e-6);
```

