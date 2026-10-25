# HALCYON — FEATURES ONLY (read this first, Claude)

This folder holds **only the code Halcyon added** on top of Glimmer (github.com/jbritain/glimmer-shaders,
MIT, by jbritain). All Glimmer code has been taken out. It was produced from Halcyon `1.0.0-alpha.22`
(github.com/foldedapples/Halcyon-Shaders) by `tools/extract.py`, which compares every file against
Glimmer commit `6a59109` with comments and whitespace ignored.

**This folder is not a working shader pack by itself.** Iris needs a full pipeline: gbuffers, lighting,
atmosphere LUTs, shadows, tonemapping, the program stubs in `world*/` and the base textures. That
pipeline was Glimmer's, and it is the part that was removed. To run Halcyon's features again, either:
1. put them back into Glimmer commit `6a59109` using the integration notes below; or
2. (the long-term plan) write a new base pipeline and port the features into it.
   `glimmer_dependencies.json` lists what such a base has to provide.

## How the folder is organised
| Path | Contents |
|---|---|
| `shaders/` | Files that are **100% Halcyon**: new libraries, new programs, new `world*/` program stubs, and Halcyon's own textures. They are kept whole, with the author's comments. |
| `integration/<glimmer path>.md` | For every Glimmer file Halcyon **edited**: only the Halcyon code blocks. Each block says *where* it went: a Glimmer line number at commit 6a59109 (replace / insert-after) and the enclosing function. No Glimmer code is reproduced. |
| `glimmer_dependencies.json` | For each Glimmer file, the functions, macros, uniforms and constants the kept code still uses. |
| `extraction_report.json` | Lists of new, Glimmer-only (removed), comment-only (removed) and mixed files. |
| `tools/` | Halcyon's asset scripts (night sky, cloud previews), plus `extract.py` / `deps.py` that produced this folder. |
| `CHANGELOG.md`, `README_original.md`, `LICENSE` | From the Halcyon repo. |

### What was removed
- **Glimmer files Halcyon never changed:** 265 files.
- **Glimmer files where Halcyon only added comments:** 30 files. The comments explained Glimmer code, so they
  went with it. Examples: `TAA.glsl`, `spaceConversions.glsl`, `FXAA.glsl`, `bloom.glsl`, `textRenderer.glsl`, `setup.csh`.
- **The Glimmer code inside the 54 files Halcyon edited.** Only Halcyon's blocks remain, in `integration/`.

### Notes on accuracy
- The comparison is line-based. Where Halcyon *moved* a Glimmer line, it shows up as a short Halcyon block. A few of
  the new program files share boilerplate lines with Glimmer, such as `gl_Position = ftransform();`. These are
  generic Iris lines, not real copied logic.
- Some new files still say "Licensed under the MIT license, like the rest of Glimmer." The pack started as a Glimmer
  fork, and keeping the MIT `LICENSE` with jbritain's notice is required while any part of it stays derived.
- Line numbers in `integration/` are **Glimmer's**, not Halcyon's, so changes can be re-applied to a fresh
  Glimmer checkout: `git clone https://github.com/jbritain/glimmer-shaders && git checkout 6a59109`.

## Feature map
### Volumetric clouds (cumulus, stratocumulus, cumulonimbus, overcast; fly-through, cloud shadows)
- Halcyon files: `shaders/lib/atmosphere/volumetricClouds.glsl`, `shaders/lib/atmosphere/cloudComposite.glsl`, `shaders/program/dc_volumetricClouds.glsl`, `shaders/program/prepare5.glsl`, `shaders/textures/cloudNoise.bin`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/clouds.glsl.md` (5 blocks), `integration/shaders/program/d0_sky.glsl.md` (3 blocks), `integration/shaders/program/c4_fog.glsl.md` (6 blocks), `integration/shaders/lib/lighting/shadows.glsl.md` (7 blocks), `integration/shaders/world0/deferred.fsh.md` (1 blocks)

### Cirrus layer and 22° halo
- Halcyon files: `shaders/lib/atmosphere/sky/cirrus.glsl`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks)

### NASA moon (2K/4K), phases, earthshine; solar and lunar eclipses (orbital model)
- Halcyon files: `shaders/lib/atmosphere/sky/celestial.glsl`, `shaders/textures/moon_2k.png`, `shaders/textures/moon_4k.png`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks), `integration/shaders/program/prepare.glsl.md` (4 blocks), `integration/shaders/program/gbuffers_skytextured.glsl.md` (1 blocks)

### Real stars (Hipparcos + Yale BSC) and NASA Milky Way (4K/8K)
- Halcyon files: `shaders/lib/atmosphere/sky/stars.glsl`, `shaders/textures/starCatalog.bin`, `shaders/textures/milkyway_4k.png`, `shaders/textures/milkyway_8k.png`, `shaders/textures/CREDITS-night-sky.md`, `tools/nasa_night_sky.py`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks), `integration/shaders/program/gbuffers_skybasic.glsl.md` (1 blocks)

### Aurora
- Halcyon files: `shaders/lib/atmosphere/sky/aurora.glsl`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks)

### Rainbows
- Halcyon files: `shaders/lib/atmosphere/sky/rainbow.glsl`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks)

### The End as deep space, black hole, End portal space view
- Halcyon files: `shaders/lib/atmosphere/sky/blackHole.glsl`, `shaders/lib/atmosphere/sky/endAmbient.glsl`
- Hooks into Glimmer: `integration/shaders/lib/atmosphere/sky/sky.glsl.md` (11 blocks), `integration/shaders/lib/endPortal.glsl.md` (2 blocks), `integration/shaders/lib/lighting/shading.glsl.md` (7 blocks), `integration/shaders/lib/atmosphere/fog.glsl.md` (6 blocks)

### Water: big waves, caustics, underwater fog, sun shafts, rain ripples
- Halcyon files: `shaders/lib/water/caustics.glsl`, `shaders/lib/water/underwaterShafts.glsl`, `shaders/lib/water/rainRipples.glsl`
- Hooks into Glimmer: `integration/shaders/lib/water/waveNormals.glsl.md` (9 blocks), `integration/shaders/lib/water/waterFog.glsl.md` (8 blocks), `integration/shaders/lib/water/waterParallax.glsl.md` (6 blocks), `integration/shaders/program/c3_translucents.glsl.md` (43 blocks)

### Interactive water simulation (player ripples, boat wakes)
- Halcyon files: `shaders/lib/water/waterSim.glsl`, `shaders/program/waterSim.glsl`
- Hooks into Glimmer: `integration/shaders/program/c3_translucents.glsl.md` (43 blocks), `integration/shaders/shaders.properties.md` (24 blocks)

### Wet surfaces and puddles
- Halcyon files: `shaders/lib/water/wetnessSimple.glsl`
- Hooks into Glimmer: `integration/shaders/lib/water/puddles.glsl.md` (7 blocks), `integration/shaders/program/gbuffers_main.glsl.md` (22 blocks), `integration/shaders/program/gbuffers_distant.glsl.md` (6 blocks), `integration/shaders/program/gbuffers_voxy.glsl.md` (5 blocks)

### Screen-space reflections on solid blocks (GGX)
- Halcyon files: `shaders/lib/lighting/opaqueReflections.glsl`, `shaders/lib/util/ggx.glsl`
- Hooks into Glimmer: `integration/shaders/program/c3_translucents.glsl.md` (43 blocks)

### Lava model, Nether heat haze and smoke
- Halcyon files: `shaders/lib/lighting/lava.glsl`, `shaders/lib/post/heatHaze.glsl`
- Hooks into Glimmer: `integration/shaders/program/gbuffers_main.glsl.md` (22 blocks), `integration/shaders/program/bloomDownsample.glsl.md` (1 blocks), `integration/shaders/program/final.glsl.md` (7 blocks), `integration/shaders/lib/atmosphere/fog.glsl.md` (6 blocks)

### Screen-space GI
- Halcyon files: `shaders/program/d2_ssgiTrace.glsl`, `shaders/program/d3_ssgiTemporal.glsl`, `shaders/program/d4_ssgiApply.glsl`
- Hooks into Glimmer: `integration/shaders/shaders.properties.md` (24 blocks)

### Depth of field
- Halcyon files: `shaders/program/c52_depthOfField.glsl`
- Hooks into Glimmer: `integration/shaders/shaders.properties.md` (24 blocks)

### Exposure / colour (log metering, vibrance, white balance)
- Hooks into Glimmer: `integration/shaders/program/c48_writeLuminance.glsl.md` (2 blocks), `integration/shaders/program/c49_computeAutoExposure.glsl.md` (2 blocks), `integration/shaders/program/c50_applyAutoExposure.glsl.md` (6 blocks), `integration/shaders/lib/post/processing.glsl.md` (3 blocks)

### Coloured block light additions
- Hooks into Glimmer: `integration/shaders/block.properties.md` (5 blocks), `integration/shaders/lib/ipbr/blocklightColors.glsl.md` (3 blocks), `integration/shaders/lib/common/materialIDs.glsl.md` (4 blocks), `integration/shaders/program/shadow.glsl.md` (2 blocks)

### Options, menus, presets, translations
- Hooks into Glimmer: `integration/shaders/lib/common/settings.glsl.md` (18 blocks), `integration/shaders/shaders.properties.md` (24 blocks), `integration/shaders/lang/en_US.lang.md` (18 blocks)

## All Halcyon code files kept whole

- `shaders/lib/atmosphere/cloudComposite.glsl`
- `shaders/lib/atmosphere/sky/aurora.glsl`
- `shaders/lib/atmosphere/sky/blackHole.glsl`
- `shaders/lib/atmosphere/sky/celestial.glsl`
- `shaders/lib/atmosphere/sky/cirrus.glsl`
- `shaders/lib/atmosphere/sky/endAmbient.glsl`
- `shaders/lib/atmosphere/sky/rainbow.glsl`
- `shaders/lib/atmosphere/sky/stars.glsl`
- `shaders/lib/atmosphere/volumetricClouds.glsl`
- `shaders/lib/lighting/lava.glsl`
- `shaders/lib/lighting/opaqueReflections.glsl`
- `shaders/lib/post/heatHaze.glsl`
- `shaders/lib/util/ggx.glsl`
- `shaders/lib/water/caustics.glsl`
- `shaders/lib/water/rainRipples.glsl`
- `shaders/lib/water/underwaterShafts.glsl`
- `shaders/lib/water/waterSim.glsl`
- `shaders/lib/water/wetnessSimple.glsl`
- `shaders/program/c52_depthOfField.glsl`
- `shaders/program/d2_ssgiTrace.glsl`
- `shaders/program/d3_ssgiTemporal.glsl`
- `shaders/program/d4_ssgiApply.glsl`
- `shaders/program/dc_volumetricClouds.glsl`
- `shaders/program/prepare5.glsl`
- `shaders/program/waterSim.glsl`
- `shaders/world-1/composite4.fsh`
- `shaders/world-1/composite4.vsh`
- `shaders/world-1/composite52.fsh`
- `shaders/world-1/composite52.vsh`
- `shaders/world-1/deferred2.fsh`
- `shaders/world-1/deferred2.vsh`
- `shaders/world-1/deferred3.fsh`
- `shaders/world-1/deferred3.vsh`
- `shaders/world-1/deferred4.fsh`
- `shaders/world-1/deferred4.vsh`
- `shaders/world-1/gbuffers_block.fsh`
- `shaders/world-1/gbuffers_block.vsh`
- `shaders/world0/composite52.fsh`
- `shaders/world0/composite52.vsh`
- `shaders/world0/deferred2.fsh`
- `shaders/world0/deferred2.vsh`
- `shaders/world0/deferred3.fsh`
- `shaders/world0/deferred3.vsh`
- `shaders/world0/deferred4.fsh`
- `shaders/world0/deferred4.vsh`
- `shaders/world0/deferred5.fsh`
- `shaders/world0/deferred5.vsh`
- `shaders/world0/gbuffers_block.fsh`
- `shaders/world0/gbuffers_block.vsh`
- `shaders/world0/prepare5.fsh`
- `shaders/world0/prepare5.vsh`
- `shaders/world0/prepare6.csh`
- `shaders/world0/prepare7.csh`
- `shaders/world0/prepare8.csh`
- `shaders/world0/prepare9.csh`
- `shaders/world1/composite4.fsh`
- `shaders/world1/composite4.vsh`
- `shaders/world1/composite52.fsh`
- `shaders/world1/composite52.vsh`
- `shaders/world1/deferred2.fsh`
- `shaders/world1/deferred2.vsh`
- `shaders/world1/deferred3.fsh`
- `shaders/world1/deferred3.vsh`
- `shaders/world1/deferred4.fsh`
- `shaders/world1/deferred4.vsh`
- `shaders/world1/gbuffers_block.fsh`
- `shaders/world1/gbuffers_block.vsh`

## Halcyon assets kept

- `shaders/textures/CREDITS-night-sky.md`
- `shaders/textures/cloudNoise.bin`
- `shaders/textures/milkyway_4k.png`
- `shaders/textures/milkyway_4k.png.mcmeta`
- `shaders/textures/milkyway_8k.png`
- `shaders/textures/milkyway_8k.png.mcmeta`
- `shaders/textures/moon_2k.png`
- `shaders/textures/moon_2k.png.mcmeta`
- `shaders/textures/moon_4k.png`
- `shaders/textures/moon_4k.png.mcmeta`
- `shaders/textures/starCatalog.bin`

## Integration notes (Glimmer files Halcyon edited)

| Glimmer file | Halcyon blocks |
|---|---|
| `shaders/block.properties` | 5 |
| `shaders/entity.properties` | 1 |
| `shaders/lang/en_US.lang` | 18 |
| `shaders/lib/atmosphere/clouds.glsl` | 5 |
| `shaders/lib/atmosphere/fog.glsl` | 6 |
| `shaders/lib/atmosphere/sky/hillaireCommon.glsl` | 3 |
| `shaders/lib/atmosphere/sky/sky.glsl` | 11 |
| `shaders/lib/common.glsl` | 2 |
| `shaders/lib/common/material.glsl` | 17 |
| `shaders/lib/common/materialIDs.glsl` | 4 |
| `shaders/lib/common/settings.glsl` | 18 |
| `shaders/lib/common/uniforms.glsl` | 2 |
| `shaders/lib/common/util.glsl` | 1 |
| `shaders/lib/dh.glsl` | 2 |
| `shaders/lib/endPortal.glsl` | 2 |
| `shaders/lib/ipbr/blocklightColors.glsl` | 3 |
| `shaders/lib/lighting/brdf.glsl` | 4 |
| `shaders/lib/lighting/shading.glsl` | 7 |
| `shaders/lib/lighting/shadows.glsl` | 7 |
| `shaders/lib/post/processing.glsl` | 3 |
| `shaders/lib/post/tonemap.glsl` | 2 |
| `shaders/lib/util/screenSpaceRayTrace.glsl` | 1 |
| `shaders/lib/voxel/voxelData.glsl` | 1 |
| `shaders/lib/water/puddles.glsl` | 7 |
| `shaders/lib/water/waterFog.glsl` | 8 |
| `shaders/lib/water/waterParallax.glsl` | 6 |
| `shaders/lib/water/waveNormals.glsl` | 9 |
| `shaders/program/bloomDownsample.glsl` | 1 |
| `shaders/program/c2_godrays.glsl` | 3 |
| `shaders/program/c3_translucents.glsl` | 43 |
| `shaders/program/c48_writeLuminance.glsl` | 2 |
| `shaders/program/c49_computeAutoExposure.glsl` | 2 |
| `shaders/program/c4_fog.glsl` | 6 |
| `shaders/program/c50_applyAutoExposure.glsl` | 6 |
| `shaders/program/d0_sky.glsl` | 3 |
| `shaders/program/final.glsl` | 7 |
| `shaders/program/gbuffers_clrwl.glsl` | 4 |
| `shaders/program/gbuffers_distant.glsl` | 6 |
| `shaders/program/gbuffers_main.glsl` | 22 |
| `shaders/program/gbuffers_skybasic.glsl` | 1 |
| `shaders/program/gbuffers_skytextured.glsl` | 1 |
| `shaders/program/gbuffers_voxy.glsl` | 5 |
| `shaders/program/prepare.glsl` | 4 |
| `shaders/program/prepare1.glsl` | 1 |
| `shaders/program/prepare2.glsl` | 4 |
| `shaders/program/prepare3.glsl` | 1 |
| `shaders/program/shadow.glsl` | 2 |
| `shaders/program/voxy.json` | 2 |
| `shaders/shaders.properties` | 24 |
| `shaders/textures/LICENSE-MIT_tony_mc_mapface` | 1 |
| `shaders/world0/deferred.fsh` | 1 |
| `shaders/world0/deferred.vsh` | 1 |
| `shaders/world0/deferred1.fsh` | 1 |
| `shaders/world0/deferred1.vsh` | 1 |

## What a new base pipeline must provide
These come from `glimmer_dependencies.json`.

- **Iris uniforms and samplers.** 67 names, such as `cameraPosition`, `gbufferModelViewInverse`, `frameTimeCounter`,
  `colortex*`, `depthtex*` and `shadowtex*`. Glimmer only *declared* these; Iris provides them, so any base
  declares the same set. See `lib/common/uniforms.glsl` in Glimmer for the full list.
- **Shared helpers and macros Halcyon calls.** These must be rewritten or re-implemented in a new base. Main ones:
  - `shaders/lib/common/settings.glsl` (58): AMBIENT_STRENGTH, ATMOSPHERIC_FOG, BASE_FOG_DENSITY, BLOCKLIGHT_STRENGTH, BLOCK_OUTLINE_B, BLOCK_OUTLINE_G, BLOCK_OUTLINE_R, BLOOM, BLOOM_RADIUS, BLOOM_STRENGTH, CAVE_SKY_DARKENING, CLOUDS, CLOUDY_FOG, CLOUD_COVERAGE, CLOUD_DENSITY, CLOUD_SHADOWS, CONTRAST, DH_AO …
  - `shaders/lib/common.glsl` (14): EBS, dhDepthTex0, dhDepthTex1, dhProjectionInverse, isDay, lightDir, resolution, skyMultiplier, sunDir, weatherSkylightColor, weatherSunlightColor, worldLightDir, worldSunDir, worldTimeCounter
  - `shaders/lib/common/syntax.glsl` (14): GREEN, PI, RED, clamp01, max0, max3, maxVec2, maxVec3, min3, minVec3, pow2, pow3, pow5, rcp
  - `shaders/lib/atmosphere/sky/hillaireCommon.glsl` (12): CLOUD_EXTINCTION_COLOR, atmospherePos, getValFromTLUT, groundRadiusMM, moonAngularRadius, moonIrradiance, rayIntersectSphere, sunAngularRadius, sunIrradiance, sunRadiance, tLUTRes, unmapAerialPerspectivePos
  - `shaders/lib/common/util.glsl` (12): blueNoise, dualHenyeyGreenstein, goldenAngle, henyeyGreenstein, interleavedGradientNoise, luminance, rgb, rotate, scale, sincos, vec2, vogelDiscSample
  - `shaders/lib/common/materialIDs.glsl` (10): DH_BLOCK_LAVA, DH_BLOCK_LEAVES, DH_BLOCK_WATER, isLava, isLeaves, isLetsLightThrough, isPlant, isTorchLightColor, isWater, sway
  - `shaders/program/gbuffers_voxy.glsl` (8): GBUFFERS_VOXY, fogColor, gbufferModelView, gbufferModelViewInverse, gbufferPreviousProjection, gbufferProjection, voxy_emitFragment, vxModelView
  - `shaders/lib/post/tonemap.glsl` (7): a, b, c, d, tonemap, tonyMcMapface, tonyMcMapfaceTex
  - `shaders/lib/atmosphere/clouds.glsl` (6): clamp01, getCloudDensity, getCloudShadow, getClouds, multipleScattering, remap
  - `shaders/lib/common/material.glsl` (5): Material, NO_METAL, OTHER_METAL, getMetalN_K, materialFromSpecularMap
  - `shaders/lib/lighting/brdf.glsl` (5): areaLightNormalization, brdf, fresnel, fresnelRoughness, n
  - `shaders/lib/water/waterFog.glsl` (5): WATER_ABSORPTION, WATER_DENSITY, WATER_SCATTERING, waterExtinction, waterFog
  - `shaders/lib/water/waveNormals.glsl` (5): WAVE_DEPTH, WAVE_E, waveHeight, waveNormal, wavedx
  - `shaders/lib/atmosphere/fog.glsl` (4): HEIGHT_FOG_TOP_HEIGHT, atmosphericFog, cloudyFog, defaultFog
  - `shaders/lib/shadowSpace.glsl` (4): distort, getShadowClipPos, getShadowScreenPos, mat3
  - `shaders/program/gbuffers_line.glsl` (4): alphaTestRef, renderStage, viewHeight, viewWidth
  - `shaders/lib/atmosphere/sky/sky.glsl` (3): endSky, getSky, sun
  - `shaders/lib/util/screenSpaceRayTrace.glsl` (3): clamp01, handDepth, rayIntersects
  - `shaders/lib/TAA.glsl` (2): a1, a2
  - `shaders/lib/common/spaceConversions.glsl` (2): screenSpaceToViewSpace, viewSpaceToScreenSpace
  - `shaders/lib/lighting/shadows.glsl` (2): getShadowing, sampleShadow
  - `shaders/lib/water/puddles.glsl` (2): PUDDLES_GLSL, overlayBlend
  - `shaders/lib/water/waterParallax.glsl` (2): WATER_PARALLAX_SAMPLES, waveNormal
  - `shaders/lib/common/debug.glsl` (1): show
  - `shaders/lib/dh.glsl` (1): dhMask
  - `shaders/lib/endPortal.glsl` (1): endPortal
  - `shaders/lib/ipbr/blocklightColors.glsl` (1): getBlocklightColor
  - `shaders/lib/lighting/shading.glsl` (1): getShadedColor
  - `shaders/lib/post/processing.glsl` (1): postProcess
  - `shaders/lib/util/packing.glsl` (1): decodeNormal
  - `shaders/lib/util/spheremap.glsl` (1): mapSphere
  - `shaders/lib/voxel/voxelData.glsl` (1): encodeVoxelData
  - `shaders/lib/voxel/voxelMap.glsl` (1): mapVoxelPosInterp
  - `shaders/program/gbuffers_clrwl.glsl` (1): getMappedNormal
  - `shaders/program/gbuffers_main.glsl` (1): getMappedNormal
  - `shaders/program/prepare2.glsl` (1): SKYLIGHT_SAMPLES
- **Glimmer textures the features sample.** Examples: `perlinNoiseTex` for cloud weather, cirrus, aurora and puddles,
  `blueNoiseTex` for jitter, the atmosphere LUTs `sunTransmittanceLUTTex` / sky view for sun colour and the sky,
  and the Tony McMapface LUT for tonemapping. A new base needs equivalents: tileable Perlin noise, blue noise and a
  sky model.
- **SSBO values from Glimmer's prepare passes:** `sunlightColor`, `skylightColor`, `sunVisibilitySmooth`.
  Halcyon's sky, cloud and underwater code reads them as "light reaching the scene".

## Rules the owner gave (carry these forward)
- Bump the version on every change, and add a changelog entry.
- Don't claim untested results. FPS was never measured by the assistant; only the owner tests in game.
- Keep the NASA, ESA and Hipparcos credits (`shaders/textures/CREDITS-night-sky.md`, README).
- Don't copy Eclipse or Bliss code (All Rights Reserved).
- Keep the MIT licence notice while any Glimmer-derived code remains.
