# Halcyon changes to Glimmer file `shaders/lib/common/settings.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 6

```glsl
// debug crap. if you turn this on and the screen is rainbow vomit, that means it's working
// #define DEBUG_ENABLE
#define DEBUG_VIEW 0 // [0 1 2 3 4 5 6 7 8 9 10]
// #define FREEZE_TIME

// ===== EXPOSURE / COLOR GRADING =====
// the 'make it look like a movie' section. I just slide stuff until it looks cool
#define AUTO_EXPOSURE
```

## 2. inserted after Glimmer line 12

```glsl
#define EXPOSURE_SPEED 1.0 // [0.25 0.5 1.0 1.5 2.0 3.0 4.0]
#define EXPOSURE_MIN_EV -2 // [-4 -3 -2 -1 0]
#define EXPOSURE_MAX_EV 2 // [0 1 2 3 4]
// 6500 is 'normal white' because of some kelvin thing. kelvin is a temperature AND a color? ok sure
#define WHITE_BALANCE 6500 // [4500 5000 5500 6000 6500 7000 7500 8000 8500]
#define GRADE_PROFILE 2 // [0 1 2 3 4]
#define VIBRANCE 1.0 // [0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6]
```

## 3. inserted after Glimmer line 20

```glsl
// floodfill = colored torch light spreading through a giant voxel grid. 256x128x256 boxes of pain
#define FLOODFILL
```

## 4. inserted after Glimmer line 30

```glsl
#define LAVA_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0 3.0]
#define LAVA_EMISSION 1.0 // [0.0 0.5 1.0 1.5 2.0 3.0]
#define LAVA_BLOOM 0.4 // [0.0 0.2 0.4 0.6 0.8 1.0]
#define LAVA_LIGHT_STRENGTH 0.6 // [0.2 0.4 0.6 0.8 1.0 1.5 2.0]
#define NETHER_EXPOSURE 0.0 // [-2.0 -1.5 -1.0 -0.5 0.0 0.5 1.0 1.5 2.0]

// nether smoke settings. it's hot and foggy down there, like my room while this compiles
#define NETHER_SMOKE
#define NETHER_SMOKE_DENSITY 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define NETHER_SMOKE_QUALITY 6 // [4 6 8 12]
#define NETHER_VISIBILITY 256 // [96 128 160 192 256 320 384 512]
#define NETHER_FOG_TINT 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5]
#define NETHER_LAVA_GLOW 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define HEAT_HAZE
#define HEAT_HAZE_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0]

// ===== THE END: SPACE EDITION =====
// yes there is a fucking BLACK HOLE in the end sky. no I don't understand the doppler part. it just looks sick
// BH = black hole, not whatever you were thinking
#define COSMIC_SKY
#define BLACK_HOLE
#define BH_SIZE 6.0 // [3.0 4.0 5.0 6.0 7.0 8.0 10.0 12.0]
#define BH_DISK_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0 3.0]
#define BH_DISK_OUTER 16.0 // [10.0 12.0 14.0 16.0 20.0 24.0]
#define BH_DISK_TILT 9.0 // [0.0 3.0 6.0 9.0 12.0 15.0 20.0 30.0 45.0]
#define BH_DISK_ROLL 12.0 // [-30.0 -20.0 -12.0 -6.0 0.0 6.0 12.0 20.0 30.0]
#define BH_ROTATION_SPEED 1.0 // [0.0 0.25 0.5 1.0 1.5 2.0]
#define BH_DOPPLER 0.6 // [0.0 0.2 0.4 0.6 0.8 1.0]
#define BH_PHOTON_RING 1.0 // [0.0 0.5 1.0 1.5 2.0 3.0]
#define BH_QUALITY 2 // [0 1 2 3]
#define BH_LIGHT 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
// nebula stuff. space clouds. purple goo. 10/10
#define COSMIC_CLOUDS
#define NEBULA_DENSITY 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define NEBULA_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define END_STAR_DENSITY 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0]
#define END_STAR_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define END_AMBIENT 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define END_FOG_DENSITY 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define END_FOG_TINT 0.5 // [0.0 0.25 0.5 0.75 1.0]
#define END_AMBIENT_TINT 0.4 // [0.0 0.2 0.4 0.6 0.8 1.0]
#define COSMIC_SKY_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define END_PORTAL_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define NEBULA_SATURATION 0.6 // [0.0 0.2 0.4 0.6 0.8 1.0]
```

## 5. replaces Glimmer line 37

```glsl
const float shadowDistance = 160.0; // [16.0 32.0 48.0 64.0 80.0 96.0 112.0 128.0 144.0 160.0 176.0 192.0 208.0 224.0 240.0 256.0 272.0 288.0 304.0 320.0 336.0 352.0 368.0 384.0 400.0 416.0 432.0 448.0 464.0 480.0 496.0 512.0]
```

## 6. replaces Glimmer line 40

```glsl
const int shadowMapResolution = 2048; // [128 256 512 1024 2048 4096 8192]
```

## 7. replaces Glimmer line 44

```glsl
#define SHADOW_SAMPLES 8 // [1 2 4 8 16 32]

// ===== PBR / MISC =====
// PBR mode 0 = 'everything is matte', 1 = 'read the fancy resource pack data'
#define VANILLA_METALS
```

## 8. inserted after Glimmer line 55

```glsl
// depth of field. blurry background like phone portrait mode. 32 samples of blur, my fps is crying
// #define DOF
#define DOF_AUTOFOCUS
#define DOF_FOCUS_DISTANCE 16.0 // [2.0 4.0 8.0 16.0 32.0 64.0 128.0 256.0]
#define DOF_APERTURE 1.0 // [0.25 0.5 1.0 1.5 2.0 3.0 4.0 6.0]
#define DOF_MAX_RADIUS 16.0 // [8.0 12.0 16.0 24.0 32.0]
#define DOF_SAMPLES 32 // [16 24 32 48 64]
```

## 9. replaces Glimmer line 60

```glsl
#define FXAA_SUBPIXEL 0.50 //[0.00 0.25 0.50 0.75 1.00]
```

## 10. inserted after Glimmer line 65

```glsl
#define VOLUMETRIC_CLOUDS
#define VC_STEPS 32 // [16 24 32 48 64 96]
#define VC_LIGHT_STEPS 5 // [3 4 5 6 8]
#define VC_REFLECTION_STEPS 8 // [4 6 8 12 16]
#define VC_RESOLUTION 1 // [0 1 2]
#define CLOUD_QUALITY 2 // [0 1 2 3 4 5]
#define VC_ALTITUDE 640.0 // [400.0 500.0 640.0 800.0 1000.0 1200.0]
#define CLOUD_SHADOW_RANGE 1536.0 // [512.0 1024.0 1536.0 2048.0 3072.0]
#define CIRRUS_CLOUDS
#define CIRRUS_COVERAGE 0.35 // [0.0 0.1 0.2 0.35 0.5 0.65 0.8]
#define VC_WIND_SPEED 1.0 // [0.0 0.25 0.5 1.0 1.5 2.0 3.0]
```

## 11. inserted after Glimmer line 68

```glsl
#define CLOUD_SHADOW_VISIBILITY 0.8 // [0.0 0.2 0.4 0.6 0.7 0.8 0.9 1.0]
#define CLOUD_SHADOW_RES 256 // [256 512]
```

## 12. inserted after Glimmer line 71

```glsl
// quality presets. picks the step counts for you so you don't have to think. thinking is hard
// the last one (5) just uses whatever sliders you set above. custom mode for psychos
#if CLOUD_QUALITY == 0
  #define VC_STEPS_Q 16
  #define VC_LIGHT_STEPS_Q 3
  #define VC_REFLECTION_STEPS_Q 4
#elif CLOUD_QUALITY == 1
  #define VC_STEPS_Q 24
  #define VC_LIGHT_STEPS_Q 4
  #define VC_REFLECTION_STEPS_Q 4
#elif CLOUD_QUALITY == 2
  #define VC_STEPS_Q 32
  #define VC_LIGHT_STEPS_Q 5
  #define VC_REFLECTION_STEPS_Q 6
#elif CLOUD_QUALITY == 3
  #define VC_STEPS_Q 48
  #define VC_LIGHT_STEPS_Q 6
  #define VC_REFLECTION_STEPS_Q 8
#elif CLOUD_QUALITY == 4
  #define VC_STEPS_Q 48
  #define VC_LIGHT_STEPS_Q 8
  #define VC_REFLECTION_STEPS_Q 12
#else
  #define VC_STEPS_Q VC_STEPS
  #define VC_LIGHT_STEPS_Q VC_LIGHT_STEPS
  #define VC_REFLECTION_STEPS_Q VC_REFLECTION_STEPS
#endif

// ===== SUN, MOON, ECLIPSES =====
// custom moon texture AND the moon gets bumps. the moon has more detail than my player model
#define SUN_SIZE 1.0 // [0.5 0.75 1.0 1.5 2.0 3.0 4.0]
#define SUN_BRIGHTNESS 1.0 // [0.5 0.75 1.0 1.5 2.0]
#define CUSTOM_MOON
#define MOON_BUMP
#define MOON_TEXTURE_RES 2048 // [2048 4096]
#define MOON_SIZE 3.0 // [1.0 1.5 2.0 2.5 3.0 4.0 5.0 6.0]
#define MOON_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define ECLIPSES
#define ECLIPSE_FREQUENCY 40 // [16 24 40 64 96 160]
#define ECLIPSE_PREVIEW 0 // [0 1 2]

// northern lights. took forever. if it's flickering, no it isn't, you're imagining it
#define AURORA
#define AURORA_REFLECTIONS
#define AURORA_FREQUENCY 1 // [0 1 2 3 4]
#define AURORA_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define AURORA_QUALITY 16 // [8 12 16 24 32]

// ===== STARS =====
// REAL stars from REAL astronomers. I just copied their homework, credits right below
// real stars (Hipparcos + Yale) and Milky Way (NASA SVS
// 4851 / Gaia DR2), see lib/atmosphere/sky/stars.glsl
#define REALISTIC_STARS
// (the smart people did the data, I did the sliders. teamwork)
#define STAR_BRIGHTNESS 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define STAR_DENSITY 1.0 // [0.5 0.75 1.0 1.25 1.5 2.0]
#define STAR_TWINKLE
#define STAR_TWINKLE_STRENGTH 1.0 // [0.25 0.5 1.0 1.5 2.0]
#define STAR_BLOOM 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define MILKY_WAY
#define MILKY_WAY_INTENSITY 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0]
#define MILKY_WAY_CONTRAST 1.0 // [0.8 0.9 1.0 1.1 1.2 1.35 1.5]
#define MILKY_WAY_STYLE 0 // [0 1 2]
#define MILKY_WAY_TEXTURE_RES 8192 // [4096 8192]
#define MILKY_WAY_FILTER 1 // [0 1 2]
#define NIGHT_SKY_SEASON 0 // [0 1 2 3 4]
```

## 13. replaces Glimmer lines 76-78

```glsl
#define BASE_FOG_DENSITY 0.06 // [0.0 0.03 0.06 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

// ===== SSGI / SSAO =====
// screen space global illumination. bounces light around using only what's on screen. it lies a lot
// off by default because it eats frames like a hungry hungry hippo
// #define SSGI
#define SSGI_RAYS 1 // [1 2 4 8]
#define SSGI_STEPS 12 // [8 12 16 24 32]
#define SSGI_RADIUS 6.0 // [2.0 4.0 6.0 8.0 12.0 16.0]
#define SSGI_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define SSAO_STRENGTH 1.0 // [0.0 0.2 0.4 0.6 0.8 1.0]
#define SSGI_ACCUMULATION 16 // [4 8 16 24 32]
#define SSGI_CLAMP 8.0

// ===== GODRAYS =====
// sun beams. all these 1.0s are placeholders I never tuned. they work. leave them alone
#define GODRAYS 2 // [0 1 2]
```

## 14. replaces Glimmer line 85

```glsl
// ===== REFLECTIONS + RAIN =====
// screen space reflections. 8 steps of raymarching and a prayer
#define SSR_STEPS 8 // [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
```

## 15. inserted after Glimmer line 88

```glsl
#define SSR_OPAQUE
#define SSR_ROUGHNESS_CUTOFF 0.35 // [0.1 0.2 0.35 0.5 0.7]
```

## 16. inserted after Glimmer line 90

```glsl
#define WETNESS
#define WETNESS_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5]
#define PUDDLE_SIZE 1.0 // [0.5 0.75 1.0 1.25 1.5]

// ===== WATER (the beast) =====
// look how many water settings there are. water ate my entire summer
// boats leave wakes now. I am unreasonably proud of BOAT_WAKE_STRENGTH
#define WAVE_DEPTH 0.3 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define WAVE_SPEED 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define WAVE_SCALE 1.0 // [0.5 0.75 1.0 1.25 1.5 2.0]
#define WATER_SWELLS
#define WAVE_SWELL 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define WAVE_DETAIL 1.0 // [0.0 0.25 0.5 0.75 1.0 1.25 1.5]
#define WAVE_RIPPLES 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define WATER_BIOME_WAVES
#define INTERACTIVE_WATER
#define WATER_SIM_QUALITY 2 // [1 2 3 4]
#define WATER_SIM_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0]
#define PLAYER_RIPPLE_STRENGTH 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define BOAT_WAKE_STRENGTH 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define COASTAL_WAVES
#define RAIN_RIPPLES
#define RAINBOWS
#define RAINBOW_BRIGHTNESS 1.0 // [0.5 0.75 1.0 1.5 2.0 3.0]
#define RAIN_STREAK_OPACITY 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5]
#define RAIN_RIPPLE_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0]
#define REFRACTION_STRENGTH 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
// water looks. clarity, darkness, saturation. basically instagram filters for an ocean
#define WATER_COLOR_PRESET 0 // [0 1 2 3 4]
#define WATER_CLARITY 1.0 // [0.5 0.75 1.0 1.25 1.5 2.0]
#define WATER_DEEP_DARKNESS 0.5 // [0.0 0.25 0.5 0.75 1.0]
#define WATER_SATURATION 1.0 // [0.5 0.75 1.0 1.25 1.5]
#define WATER_REFLECTION_STRENGTH 1.0 // [0.5 0.75 1.0 1.25 1.5]
#define WATER_STORM_WAVES 1.0 // [0.0 0.5 1.0 1.5 2.0]
#define WATER_LOD_FILTERING
#define WATER_REFLECTION_MASKING
// caustics = the wobbly light lines on a pool floor. mode 1 vs 2? one of them is better. I forget which
#define CAUSTICS_MODE 2 // [1 2]
#define CAUSTICS_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5]
#define UNDERWATER_CLEAR
#define UNDERWATER_FOG 1.0 // [0.25 0.5 0.75 1.0 1.25 1.5 2.0 3.0]
#define UNDERWATER_HAZE 1.0 // [0.0 0.25 0.5 0.75 1.0 1.5 2.0]
#define UW_SUN_SHAFTS
#define UW_SHAFT_SAMPLES 8 // [4 6 8 12 16]
#define UW_SHAFT_STRENGTH 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0]
#define UNDERWATER_SURFACE_DISTORTION 0.3 // [0.1 0.2 0.3 0.45 0.6 0.8 1.0]
```

## 17. inserted after Glimmer line 93

```glsl
#define CAUSTICS
```

## 18. replaces Glimmer line 107

```glsl
#define DH_AO_SAMPLES 64 // [4 8 16 32 64]
```

