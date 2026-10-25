# Halcyon changes to Glimmer file `shaders/program/gbuffers_main.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 110 — in `main()`

```glsl
#include "/lib/lighting/lava.glsl"
```

## 2. inserted after Glimmer line 111 — in `main()`

```glsl
#ifdef GBUFFERS_BLOCK
```

## 3. inserted after Glimmer line 112 — in `main()`

```glsl
#endif
```

## 4. replaces Glimmer lines 143-145 — in `getMappedNormal()`

```glsl
  mappedNormal.z = sqrt(max0(1.0 - dot(mappedNormal.xy, mappedNormal.xy))); // recover z from x and y. x^2 + y^2 + z^2 = 1. pythagoras, the GOAT

  return normalize(tbnMatrix * mappedNormal);
```

## 5. inserted after Glimmer line 146 — in `getMappedNormal()`

```glsl
// which buffers we write depends on SSR and SSGI. four combos, four lists. the LOC_ numbers shuffle around so the locations line up. touch one and the whole thing shits itself
#if defined SSR_OPAQUE && defined SSGI
/* RENDERTARGETS: 0,1,5,8,11 */
#define LOC_REFLECTIVITY 3
#define LOC_ALBEDO 4
#elif defined SSR_OPAQUE
/* RENDERTARGETS: 0,1,5,8 */
#define LOC_REFLECTIVITY 3
#elif defined SSGI
/* RENDERTARGETS: 0,1,5,11 */
#define LOC_ALBEDO 3
#else
/* RENDERTARGETS: 0,1,5 */
#endif
```

## 6. inserted after Glimmer line 152 — in `getMappedNormal()`

```glsl
#ifdef LOC_REFLECTIVITY
layout(location = LOC_REFLECTIVITY) out vec4 outReflectivity;
#endif
#ifdef LOC_ALBEDO
layout(location = LOC_ALBEDO) out vec4 outAlbedo;
#endif
```

## 7. Removed Glimmer code (replaces Glimmer line 229) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 8. replaces Glimmer lines 231-241 — in `main()`

```glsl
    albedo.rgb *= lavaPatchiness(playerPos + cameraPosition); // lava blotches. lava, again. I think about lava more than anyone should
```

## 9. Removed Glimmer code (replaces Glimmer line 243) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 10. Removed Glimmer code (replaces Glimmer lines 246-248) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 11. inserted after Glimmer line 255 — in `main()`

```glsl
  #if PBR_MODE != 0
```

## 12. inserted after Glimmer line 256 — in `main()`

```glsl
  #endif
```

## 13. inserted after Glimmer line 258 — in `main()`

```glsl
  material.metalID = NO_METAL;
```

## 14. inserted after Glimmer line 268 — in `main()`

```glsl
  #if !defined MC_TEXTURE_FORMAT_LAB_PBR || PBR_MODE == 0
  // obsidian gets a little shiny. except in the End, where it would look weird next to all the end stone. design!
  #ifndef WORLD_THE_END
  if (isObsidian(materialID)) {
    material.f0 = vec3(0.04);
    material.roughness = 0.3;
  }
  #endif
  #ifdef VANILLA_METALS
  // vanilla metal blocks (iron, gold, etc) get to be actually metal. f0 = albedo is how metals work, the color IS the reflection. roughness mix(0.45, 0.22, ...) means brighter = shinier. I made that rule up
  if (isMetalBlock(materialID)) {
    material.metalID = OTHER_METAL;
    material.f0 = albedo.rgb;
    material.roughness = mix(0.45, 0.22, clamp01(luminance(albedo.rgb) * 1.6));
  }
  #endif
  #endif
```

## 15. inserted after Glimmer line 270 — in `main()`

```glsl
    #ifdef MC_TEXTURE_FORMAT_LAB_PBR
    if (material.sss <= 0.0) material.sss = 1.0;
    #else
```

## 16. inserted after Glimmer line 273 — in `main()`

```glsl
    #endif
```

## 17. replaces Glimmer lines 288-289 — in `main()`

```glsl
  if (isLava(materialID)) {
    material.emission = lavaEmission(albedo.rgb);
  }

  // things that can get rained on. not water (already wet lol), not lava (would boil), not particles, not translucent, not your hand. your hand is waterproof apparently
  bool canGetWet =
    !isWater(materialID) &&
      !isLava(materialID) &&
      renderStage != MC_RENDER_STAGE_PARTICLES &&
      renderStage != MC_RENDER_STAGE_TERRAIN_TRANSLUCENT &&
      renderStage != MC_RENDER_STAGE_HAND_SOLID &&
      renderStage != MC_RENDER_STAGE_HAND_TRANSLUCENT;
  if (canGetWet) {
    applyWetness(
```

## 18. replaces Glimmer line 295 — in `main()`

```glsl
        lightmap.y,
        length(playerPos),
        isPlant(materialID) || isLeaves(materialID)
```

## 19. replaces Glimmer line 297 — in `main()`

```glsl
  }
```

## 20. inserted after Glimmer line 418 — in `main()`

```glsl
  // end portal block gets its own trippy starfield effect. gbufferModelViewInverse[3] is the camera position or something. I just know it makes the stars work
  #ifdef GBUFFERS_BLOCK
```

## 21. inserted after Glimmer line 426 — in `main()`

```glsl
  #endif
```

## 22. inserted after Glimmer line 434 — in `main()`

```glsl
  // save albedo for SSGI. sqrt to pack it a bit better in 8 bits (poor man's gamma). alpha = AO, with a minimum of 4/255 because 0 means "skip me" to the SSGI pass
  #ifdef SSGI
  outAlbedo = vec4(0.0);
  if (
    !isWater(materialID) &&
      renderStage != MC_RENDER_STAGE_PARTICLES &&
      material.metalID == NO_METAL
  ) {
    outAlbedo = vec4(
        sqrt(clamp01(material.albedo)),
        max((material.ao * 0.5 + 0.5) * ambientOcclusion, 4.0 / 255.0)
      );
  }
  #endif

  // opaque SSR reads this later (in c3). it's the reflectivity buffer. if it's wrong, every block becomes a mirror and it looks like the inside of a disco ball
  #ifdef SSR_OPAQUE
  outReflectivity = vec4(0.0);
  if ( // only smooth enough stuff gets SSR. rough stuff can go fuck itself (it uses the sky reflection instead)
    !isWater(materialID) &&
      renderStage != MC_RENDER_STAGE_PARTICLES &&
      material.roughness < SSR_ROUGHNESS_CUTOFF
  ) {
    outReflectivity = vec4(clamp01(material.f0), 1.0 - material.roughness);
  }
  #endif
```

