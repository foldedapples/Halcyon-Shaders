# Halcyon changes to Glimmer file `shaders/lib/ipbr/blocklightColors.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 13 — in `getBlocklightColor()`

```glsl
  }

  if (isLanternLightColor(ID)) {
    return vec3(1.0, 0.45, 0.12);
```

## 2. inserted after Glimmer line 34 — in `getBlocklightColor()`

```glsl
  // copper lights are GREEN?? oh right, oxidized. statue of liberty vibes
  if (isCopperLightColor(ID)) {
    return vec3(0.35, 1.0, 0.45);
  }

  if (isNetherPortalLight(ID)) {
    return vec3(0.62, 0.28, 1.0);
  }

  if (isWarmYellowLight(ID)) {
    return vec3(1.0, 0.72, 0.35);
  }

  if (isCyanWhiteLight(ID)) {
    return vec3(0.72, 0.92, 1.0);
  }

  if (isPurpleLight(ID)) {
    return vec3(0.6, 0.3, 1.0);
  }

  // literally the same color as lanterns. copy pasted. don't tell anyone
  if (isOrangeLight(ID)) {
    return vec3(1.0, 0.45, 0.12);
  }

  if (isLightBlock(ID)) {
    return vec3(1.0, 0.82, 0.62);
  }
```

## 3. replaces Glimmer line 37 — in `getBlocklightColor()`

```glsl
    return vec3(0.25, 0.45, 0.85);
```

