# Halcyon changes to Glimmer file `shaders/program/prepare.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 78 — in `main()`

```glsl
  #if defined COSMIC_SKY && defined BLACK_HOLE
  sunlightColor = vec3(1.0, 0.70, 0.42) * 0.06 * BH_LIGHT * BH_DISK_BRIGHTNESS; // black hole mode: warm orange sunlight from the accretion disk. yes there's a black hole option. yes I'm proud of it. no I didn't understand the math
  #else
```

## 2. inserted after Glimmer line 79 — in `main()`

```glsl
  #endif
```

## 3. replaces Glimmer lines 148-149 — in `main()`

```glsl
      moonPhaseBrightness() *
      MOON_BRIGHTNESS;

    // eclipse support. EclipseState. this shader pack has eclipses. I did not ask for eclipses. we have eclipses now
    EclipseState eclipse = getEclipseState();
    sunlightColor *= isDay ? vec3(eclipseSunlightFactor(eclipse))
                           : eclipseMoonlightFactor(eclipse);
```

## 4. replaces Glimmer lines 153-155 — in `main()`

```glsl
    sunlightColor *= clamp01(1.0 - darknessLightFactor * 2.5); // the Darkness effect (warden) kills the light. 2.5x so it gets dark fast and scares you
```

