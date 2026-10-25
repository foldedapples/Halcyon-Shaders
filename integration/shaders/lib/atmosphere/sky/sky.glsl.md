# Halcyon changes to Glimmer file `shaders/lib/atmosphere/sky/sky.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 4

```glsl
#include "/lib/atmosphere/sky/aurora.glsl"
#include "/lib/atmosphere/sky/stars.glsl"
#include "/lib/atmosphere/sky/rainbow.glsl"
#include "/lib/atmosphere/sky/cirrus.glsl"
#include "/lib/atmosphere/sky/blackHole.glsl"
```

## 2. inserted after Glimmer line 53 — in `endSky()`

```glsl
#ifdef COSMIC_SKY
  return cosmicSky(dir, includeSun);
#endif
```

## 3. inserted after Glimmer line 69 — in `getSky()`

```glsl
  EclipseState eclipse = getEclipseState(); // yes there are eclipses. I spent a whole weekend on eclipses. nobody will ever see one
```

## 4. inserted after Glimmer line 71 — in `getSky()`

```glsl
  lum *= eclipseSkyFactor(eclipse);

  // if the ray hits the planet we're looking at ground, so no sun gets through. black. like my soul
  bool belowHorizon =
      rayIntersectSphere(atmospherePos, rayDir, groundRadiusMM) >= 0.0;
  vec3 viewTransmittance =
      belowHorizon ? vec3(0.0)
                   : getValFromTLUT(sunTransmittanceLUTTex, tLUTRes,
                                    atmospherePos, rayDir);

  float aurora = 0.0;
// #ifdef inside an #ifndef inside an #ifdef wrapped around an if with NO BRACES. this is the jungle. welcome
#ifdef AURORA
  aurora = auroraActivity();
#ifndef AURORA_REFLECTIONS
  if (includeSun)
#endif
  {
    lum += getAurora(rayDir, aurora) * viewTransmittance;
  }
#endif

  // no sun = this is for reflections/ambient, bail early before the fancy stuff
  if (!includeSun) {
```

## 5. Removed Glimmer code (replaces Glimmer line 75) — in `getSky()`

Halcyon deletes these Glimmer lines (no replacement).

## 6. Removed Glimmer code (replaces Glimmer lines 78-87) — in `getSky()`

Halcyon deletes these Glimmer lines (no replacement).

## 7. replaces Glimmer lines 89-92 — in `getSky()`

```glsl
  float moonCoverage;
  vec3 moonLum = moonDiskRadiance(rayDir, eclipse, moonCoverage);
  color *= 1.0 - moonCoverage; // moon blocks stuff behind it. moon is solid. this took me embarrassingly long to realize
  vec3 catalogStarLum = vec3(0.0);
#if defined REALISTIC_STARS || defined MILKY_WAY
  {
    vec3 stars;
    vec3 milkyWay = nightSky(rayDir, aurora, smoothstep(0.97, 1.0, eclipse.solarCoverage), stars);
    float visible = 1.0 - moonCoverage;
    lum += milkyWay * visible * viewTransmittance;
    catalogStarLum = stars * visible * viewTransmittance; // stars saved for later so they go on top of the clouds. wait no, behind. ugh, see below
```

## 8. inserted after Glimmer line 93 — in `getSky()`

```glsl
#endif
  lum += (color + moonLum + moonGlow(rayDir, eclipse)) * viewTransmittance;

  float cirrusTrans = 1.0;
#ifdef CIRRUS_CLOUDS
  lum = applyCirrus(lum, rayDir, viewTransmittance, cirrusTrans);
#endif

  lum = mix(lum, weatherSkylightColor, wetness); // rain makes everything grey. like mondays

#ifdef RAINBOWS
  {
    vec4 bow = rainbow(rayDir);
    lum = lum * bow.a + luminance(lum) * bow.rgb * viewTransmittance;
```

## 9. replaces Glimmer lines 96-98 — in `getSky()`

```glsl
#endif

  vec3 sunLum = sunDiskRadiance(rayDir, eclipse);
  lum += sunLum * viewTransmittance * cirrusTrans;
```

## 10. inserted after Glimmer line 103 — in `getSky()`

```glsl
  lum += catalogStarLum * cirrusTrans * (1.0 - wetness);
```

## 11. replaces Glimmer line 107 — in `getSky()`

```glsl
  return lum * clamp01(1.0 - darknessLightFactor * 2.5); // warden darkness effect kills the sky. 2.5 because 2 wasn't scary enough
```

