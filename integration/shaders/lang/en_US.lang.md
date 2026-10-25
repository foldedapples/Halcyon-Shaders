# Halcyon changes to Glimmer file `shaders/lang/en_US.lang`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 1-3

```properties
option.GLIMMER_SHADERS=Halcyon 1.0.0-alpha.22
option.GLIMMER_SHADERS.comment=Halcyon: a photorealism edit of Glimmer by jbritain (MIT), maintained by Freak4U.
value.GLIMMER_SHADERS.1=§dA Glimmer edit by Freak4U
value.GLIMMER_SHADERS.2=§dA Glimmer edit by Freak4U
```

## 2. replaces Glimmer line 9

```properties
screen.LIGHTING=Lighting
screen.GI=Global Illumination
```

## 3. replaces Glimmer line 11

```properties
screen.REFLECTIONS=Reflections
screen.ATMOSPHERICS=Atmosphere
```

## 4. inserted after Glimmer line 12

```properties
screen.WEATHER=Rain & Wetness
screen.CLOUDS=Clouds
screen.FOG=Fog
screen.CELESTIAL=Sun & Moon
screen.NIGHT_SKY=Night Sky
screen.AURORA=Aurora
screen.ECLIPSES=Eclipses
screen.CAMERA=Camera & Exposure
```

## 5. replaces Glimmer line 15

```properties
screen.MATERIALS=PBR Materials
```

## 6. inserted after Glimmer line 16

```properties
screen.LOD=Distant Horizons & Voxy
screen.PERFORMANCE=Performance (sample counts)
screen.EXPERIMENTAL=Experimental Features
```

## 7. replaces Glimmer lines 24-25

```properties
profile.low=§eLow
profile.balanced=§aBalanced
profile.high=§bHigh
profile.ultra=§dUltra
profile.cinematic=§5Cinematic
profile.comment=High is the default and the recommended everyday preset. Low targets integrated graphics, Balanced older gaming GPUs, Ultra high-end GPUs. Cinematic is tuned for screenshots on fast GPUs (depth of field is available in Camera but off by default).
```

## 8. replaces Glimmer line 34

```properties
option.CONTRAST.comment=Contrast on top of the Colour Profile, applied in linear light around mid-grey so colours keep their hue. 1.0 = the profile's own contrast. §9No performance impact!
```

## 9. replaces Glimmer line 36

```properties
option.SATURATION.comment=Saturation on top of the Colour Profile, applied in linear light. 1.0 = the profile's own saturation. §9No performance impact!
```

## 10. replaces Glimmer line 39

```properties
option.EXPOSURE.comment=Base brightness of the image. With §eAuto Exposure§f on, the eye adapts around this value within the Minimum/Maximum Exposure range. §9No performance impact!
```

## 11. replaces Glimmer line 42

```properties
option.AUTO_EXPOSURE.comment=Eye adaptation: brightens dark scenes (forests, caves) and darkens bright ones a little, metered like a camera (geometric mean). Limited to a few stops around Exposure so nights stay dark. §aMinimal performance impact.
```

## 12. Removed Glimmer code (replaces Glimmer lines 163-164)

Halcyon deletes these Glimmer lines (no replacement).

## 13. Removed Glimmer code (replaces Glimmer lines 177-181)

Halcyon deletes these Glimmer lines (no replacement).

## 14. replaces Glimmer lines 195-198

```properties
option.WATER_ABSORPTION_MOD=Water Absorption
option.WATER_ABSORPTION_MOD.comment=How fast water absorbs light with depth (red first, then green, then blue): higher = darker, bluer water and less visible bottom. §9No performance impact!
```

## 15. Removed Glimmer code (replaces Glimmer lines 212-213)

Halcyon deletes these Glimmer lines (no replacement).

## 16. replaces Glimmer line 225

```properties
option.PATCHY_LAVA.comment=Slow, large-scale brightness variation across lava lakes. §2Imperceptible performance impact.
```

## 17. Removed Glimmer code (replaces Glimmer line 258)

Halcyon deletes these Glimmer lines (no replacement).

## 18. inserted after Glimmer line 283

```properties
value.tonemap.tonyMcMapface=Tony McMapface (default)


option.WAVE_DEPTH=Wave Height
option.WAVE_DEPTH.comment=Height of the water waves. Also scales swells, ripples and caustics. §9No performance impact!
option.WAVE_SPEED=Wave Speed
option.WAVE_SPEED.comment=Animation speed of all water waves. §9No performance impact!
option.WAVE_SCALE=Wave Size
option.WAVE_SCALE.comment=Horizontal size of the waves. Higher = longer, broader waves. §9No performance impact!
option.WATER_SWELLS=Gerstner Swells
option.WATER_SWELLS.comment=Adds large, slow rolling swells (Gerstner waves) under the smaller detail waves. §2Imperceptible performance impact.
option.WAVE_SWELL=Swell Strength
option.WAVE_SWELL.comment=How pronounced the large swells are. §9No performance impact!
option.COASTAL_WAVES=Calmer Shallow Water
option.COASTAL_WAVES.comment=Waves get smaller in shallow water near the shore. §2Imperceptible performance impact.
option.REFRACTION_STRENGTH=Refraction Strength
option.REFRACTION_STRENGTH.comment=How strongly waves distort what is seen through the water. Distortion also grows with water depth. §9No performance impact!
option.CAUSTICS_MODE=Caustics Type
option.CAUSTICS_MODE.comment=§eTexture§f: Glimmer's original scrolling caustics. §eProcedural§f: computed from the wave field, so the light pattern moves with the waves. §aMinimal performance impact.
value.CAUSTICS_MODE.1=Texture
value.CAUSTICS_MODE.2=Procedural
option.WATER_COLOR_PRESET=Water Colour Profile
option.WATER_COLOR_PRESET.comment=How the water absorbs and scatters light. §eNatural Blue§f: turquoise shallows, blue to navy deep water (recommended). §eCrystal Clear§f: lagoon-clear, light turquoise. §eDeep Ocean§f: darker navy. §eMurky§f: swampy green-brown. §eCinematic§f: rich dark blue. §9No performance impact!
value.WATER_COLOR_PRESET.0=Natural Blue
value.WATER_COLOR_PRESET.1=Crystal Clear
value.WATER_COLOR_PRESET.2=Deep Ocean
value.WATER_COLOR_PRESET.3=Murky
value.WATER_COLOR_PRESET.4=Cinematic
option.WATER_CLARITY=Shallow Water Clarity
option.WATER_CLARITY.comment=How deep you can see the bottom. Higher = clearer. Keeps the water's hue; very deep water keeps its colour. §9No performance impact!
option.WATER_DEEP_DARKNESS=Deep Water Darkness
option.WATER_DEEP_DARKNESS.comment=Brightness of the light the water scatters back: the colour of water too deep to see the bottom, and of the underwater haze. 0.5 = physical. §9No performance impact!
option.WATER_SATURATION=Water Saturation
option.WATER_SATURATION.comment=How strongly the water tints light. Lower = greyer water, higher = more intensely blue. §9No performance impact!
option.WATER_REFLECTION_STRENGTH=Water Reflection Intensity
option.WATER_REFLECTION_STRENGTH.comment=Brightness of reflected sky, clouds, terrain and sun glint on water. 1.0 = physical. §9No performance impact!
option.WATER_STORM_WAVES=Weather Waves
option.WATER_STORM_WAVES.comment=How much rain and thunderstorms build up the waves (there is no wind data in Minecraft, so the weather stands in for it). Changes gradually with the weather. 0 = off. §9No performance impact!
option.WATER_LOD_FILTERING=Distant Water Filtering
option.WATER_LOD_FILTERING.comment=Waves too small to show at a distance are faded into a softer, wider sun path and sky reflection instead of shimmering. Also applies to Distant Horizons and Voxy water. §2Small performance impact (not measured).
option.WATER_REFLECTION_MASKING=Rough Water Reflection Loss
option.WATER_REFLECTION_MASKING.comment=Rough water seen at a low angle loses part of its reflection to the next wave, so distant water reflects less of the bright horizon and looks darker and bluer. Smooth near water is unaffected. §9No performance impact!

option.WETNESS=Wet Surfaces
option.WETNESS.comment=Rain makes exposed surfaces darker and glossier, then they slowly dry. Only in biomes where it rains. §2Imperceptible performance impact.
option.WETNESS_STRENGTH=Wetness Strength
option.WETNESS_STRENGTH.comment=§9No performance impact!
option.RAIN_PUDDLES=Rain Puddles
option.RAIN_PUDDLES.comment=Requires §eWet Surfaces§f. Puddles form on flat ground during sustained rain, grow over time and evaporate slowly after. Lower parts of LabPBR height maps fill first. §aMinimal performance impact.
option.PUDDLE_SIZE=Puddle Amount
option.PUDDLE_SIZE.comment=How much ground puddles can cover. §9No performance impact!
option.RAIN_RIPPLES=Raindrop Ripples
option.RAIN_RIPPLES.comment=Raindrops make expanding ripple rings on water and puddles. §aMinimal performance impact.
option.RAIN_RIPPLE_STRENGTH=Ripple Strength
option.RAIN_RIPPLE_STRENGTH.comment=§9No performance impact!

option.SSR_OPAQUE=Glossy Surface Reflections
option.SSR_OPAQUE.comment=Screen-space reflections outdoors (sky-lit) on puddles, wet ground and glossy LabPBR materials (water always has them). Off-screen objects fall back to the sky. §6Moderate performance impact.
option.SSR_ROUGHNESS_CUTOFF=Reflection Roughness Limit
option.SSR_ROUGHNESS_CUTOFF.comment=Surfaces rougher than this only reflect the sky. Higher values trace more pixels and rely more on temporal filtering. §6Moderate performance impact at high values.
option.SSR_STEPS=Reflection Quality
option.SSR_STEPS.comment=Ray-march steps for screen-space reflections. §cHigh performance impact!

option.SUN_SIZE=Sun Size
option.SUN_SIZE.comment=1.0 is the real angular size of the sun. §9No performance impact!
option.SUN_BRIGHTNESS=Sun Disk Brightness
option.SUN_BRIGHTNESS.comment=Brightness of the visible sun disk only (not the lighting). §9No performance impact!
option.CUSTOM_MOON=Detailed Moon
option.CUSTOM_MOON.comment=Replaces the vanilla moon with a real NASA lunar map (LRO, NASA SVS) with realistic phases, crater relief and earthshine. Disable to use a resource pack's moon. §2Imperceptible performance impact.
option.MOON_BUMP=Moon Crater Relief
option.MOON_BUMP.comment=Lights the moon's craters from the side, most visible near the terminator. §2Imperceptible performance impact.
option.MOON_SIZE=Moon Size
option.MOON_SIZE.comment=1.0 is the real angular size of the moon; vanilla's moon looks roughly 3x larger. §9No performance impact!
option.MOON_BRIGHTNESS=Moon Brightness
option.MOON_BRIGHTNESS.comment=Brightness of the moon disk and of moonlight. §9No performance impact!
option.MOON_TEXTURE_RES=Moon Texture Resolution
option.MOON_TEXTURE_RES.comment=Both are NASA LRO data; 4K is native resolution. 4K only helps when zooming in (e.g. spyglass) on high resolution screens, and uses more VRAM. §aMinimal performance impact.
value.MOON_TEXTURE_RES.2048=2K
value.MOON_TEXTURE_RES.4096=4K

option.ECLIPSES=Eclipses
option.ECLIPSES.comment=Occasional solar eclipses at noon on new-moon days and lunar eclipses at midnight on full-moon nights. Scheduled from the world time, so everyone on a server sees the same eclipse. §9No performance impact!
option.ECLIPSE_FREQUENCY=Eclipse Frequency
option.ECLIPSE_FREQUENCY.comment=Average number of in-game days between eclipses of each kind. §9No performance impact!
value.ECLIPSE_FREQUENCY.16=Every ~16 days
value.ECLIPSE_FREQUENCY.24=Every ~24 days
value.ECLIPSE_FREQUENCY.40=Every ~40 days
value.ECLIPSE_FREQUENCY.64=Every ~64 days
value.ECLIPSE_FREQUENCY.96=Every ~96 days
value.ECLIPSE_FREQUENCY.160=Every ~160 days
option.ECLIPSE_PREVIEW=Eclipse Preview
option.ECLIPSE_PREVIEW.comment=Forces a total eclipse every day so you can look at it: solar around noon, lunar around midnight. Turn off for normal play.
value.ECLIPSE_PREVIEW.0=Off
value.ECLIPSE_PREVIEW.1=Solar (daily at noon)
value.ECLIPSE_PREVIEW.2=Lunar (nightly at midnight)

option.AURORA=Aurora
option.AURORA.comment=Occasional northern lights on clear nights, mostly towards the north. Each display fades in, lasts part of the night and fades out; the same in every biome and for everyone on a server. §aMinimal performance impact.
option.AURORA_REFLECTIONS=Aurora in Reflections
option.AURORA_REFLECTIONS.comment=Show the aurora in water and sky reflections (and let it tint the night skylight). §2Imperceptible performance impact.
option.AURORA_FREQUENCY=Aurora Frequency
option.AURORA_FREQUENCY.comment=How many nights have an aurora. Normal events start some time after dusk and last part of the night; "Every night" keeps it on all night. Rain and thick clouds hide it.
value.AURORA_FREQUENCY.0=Rare (5% of nights)
value.AURORA_FREQUENCY.1=Occasional (8%)
value.AURORA_FREQUENCY.2=Sometimes (15%)
value.AURORA_FREQUENCY.3=Often (30%)
value.AURORA_FREQUENCY.4=Every night
option.AURORA_BRIGHTNESS=Aurora Brightness
option.AURORA_QUALITY=Aurora Quality
option.AURORA_QUALITY.comment=Number of layers marched through the curtains. §6Moderate performance impact at high values.

option.VOLUMETRIC_CLOUDS=Volumetric Clouds
option.VOLUMETRIC_CLOUDS.comment=Ray-marched 3D cumulus clouds with self-shadowing, silver linings and weather-driven coverage. Turn off to use the cheaper 2D clouds. §cHigh performance impact!
option.VC_STEPS=Cloud Samples (Custom)
option.VC_STEPS.comment=Ray-march samples through the cloud layer. Only used when Cloud Quality is Custom. §cHigh performance impact!
option.VC_LIGHT_STEPS=Cloud Lighting Quality
option.VC_LIGHT_STEPS.comment=Samples towards the sun for cloud self-shadowing (Custom Cloud Quality only). §6Moderate performance impact.
option.VC_REFLECTION_STEPS=Cloud Reflection Quality
option.VC_REFLECTION_STEPS.comment=Samples used for clouds seen in water reflections (Custom Cloud Quality only). §6Moderate performance impact.
option.VC_RESOLUTION=Volumetric Cloud Resolution (Custom)
option.VC_RESOLUTION.comment=Resolution clouds are traced at when Cloud Quality is Custom (Quarter = 1/4 width and height). Temporal accumulation fills in detail. §cHigh performance impact!
value.VC_RESOLUTION.0=Quarter
value.VC_RESOLUTION.1=Half
value.VC_RESOLUTION.2=Full
option.VC_WIND_SPEED=Cloud Movement Speed

option.SSGI=Screen-Space GI §e(Experimental)
option.SSGI.comment=Indirect light bouncing off surfaces visible on screen, including light from emissive blocks, plus ambient occlusion. Screen-space only: things off-screen can't bounce light. This is not path tracing. §cHigh performance impact!
option.SSGI_STRENGTH=GI Strength
option.SSAO_STRENGTH=Ambient Occlusion Strength
option.SSAO_STRENGTH.comment=How much nearby geometry darkens the sky light (only with Screen-Space GI).
option.SSGI_RADIUS=GI Ray Length
option.SSGI_RAYS=GI Rays per Pixel
option.SSGI_RAYS.comment=§cHigh performance impact!
option.SSGI_STEPS=GI Ray Steps
option.SSGI_ACCUMULATION=GI Temporal Accumulation
option.SSGI_ACCUMULATION.comment=Frames averaged. Higher is smoother but reacts slower to changing light.

option.EXPOSURE_SPEED=Eye Adaptation Speed
option.EXPOSURE_SPEED.comment=How quickly auto exposure adapts. §9No performance impact!
option.EXPOSURE_MIN_EV=Minimum Exposure
option.EXPOSURE_MIN_EV.comment=How much auto exposure may darken bright scenes, in stops below Exposure. §9No performance impact!
option.EXPOSURE_MAX_EV=Maximum Exposure
option.EXPOSURE_MAX_EV.comment=How much auto exposure may brighten dark scenes, in stops above Exposure. §9No performance impact!
option.WHITE_BALANCE=White Balance
option.WHITE_BALANCE.comment=Like a camera's white balance: higher values make the image warmer, lower values cooler. 6500K is neutral. §9No performance impact!
value.WHITE_BALANCE.4500=4500K (cool)
value.WHITE_BALANCE.6500=6500K (neutral)
value.WHITE_BALANCE.8500=8500K (warm)

option.DOF=Depth of Field
option.DOF.comment=Blurs things outside the focus distance, like a camera lens. Meant for screenshots/cinematics. §6Moderate performance impact.
option.DOF_AUTOFOCUS=Autofocus
option.DOF_AUTOFOCUS.comment=Focus on whatever is in the centre of the screen. Otherwise uses Focus Distance.
option.DOF_FOCUS_DISTANCE=Focus Distance
option.DOF_APERTURE=Aperture
option.DOF_APERTURE.comment=Higher = stronger blur (a wider lens opening).
option.DOF_MAX_RADIUS=Maximum Blur
option.DOF_SAMPLES=Depth of Field Quality

option.WATER_PARALLAX.comment=Adds depth to water waves by ray-marching the wave height field. Rewritten in Halcyon; still experimental. §6Moderate performance impact.


option.CLOUD_COVERAGE=Cloud Coverage
option.CLOUD_COVERAGE.comment=Base sky coverage in clear weather; rain and thunder add more. §9No performance impact!
option.CLOUD_DENSITY=Cloud Density
option.CLOUD_DENSITY.comment=Thicker clouds are darker underneath. §9No performance impact!
option.BIOME_CLOUDS=Biome-Based Coverage
option.BIOME_CLOUDS.comment=2D clouds only (no effect with Volumetric Clouds): coverage follows the biome's humidity.
option.ANIME_CLOUDS=Anime Clouds
option.ANIME_CLOUDS.comment=2D clouds only (no effect with Volumetric Clouds): posterised, cel-shaded clouds.

option.GRADE_PROFILE=Colour Profile
option.GRADE_PROFILE.comment=Overall look. §eNatural§f: balanced, neutral contrast. §eVibrant§f: richer greens and skies, warm sun against cool shade. §eCinematic§f: deeper contrast, filmic highlights, warm/cool split toning. §ePhotorealistic§f: restrained, camera-like colour. The Saturation, Contrast, Vibrance and White Balance sliders adjust on top of the profile. §9No performance impact!
value.GRADE_PROFILE.0=Off (sliders only)
value.GRADE_PROFILE.1=Natural
value.GRADE_PROFILE.2=Vibrant
value.GRADE_PROFILE.3=Cinematic
value.GRADE_PROFILE.4=Photorealistic
option.VIBRANCE=Vibrance
option.VIBRANCE.comment=Boosts muted colours (grass, overcast skies, shallow water) more than already vivid ones, for a richer but still natural image. §9No performance impact!
option.UNDERWATER_CLEAR=Clear Underwater View
option.UNDERWATER_CLEAR.comment=ON: looking up from under water shows the sky and terrain above across the whole view, with only gentle wave distortion. OFF: physically accurate - the sky is squeezed into a circle (Snell's window) and the rest of the surface mirrors the water below. §9No performance impact!
option.UNDERWATER_FOG=Underwater Fog Density
option.UNDERWATER_FOG.comment=How murky water looks while you are in it. Lower = clearer; light still loses red with distance. §9No performance impact!
option.UNDERWATER_SURFACE_DISTORTION=Surface Distortion From Below
option.UNDERWATER_SURFACE_DISTORTION.comment=How strongly waves distort the sky seen from underwater (Snell's window). §9No performance impact!
option.RAIN_STREAK_OPACITY=Rain Streak Visibility
option.RAIN_STREAK_OPACITY.comment=How visible falling rain is. §9No performance impact!
option.CLOUD_SHADOW_RANGE=Cloud Shadow Range
option.CLOUD_SHADOW_RANGE.comment=Area around you covered by the pre-computed cloud shadow map (beyond it shadows are computed per pixel). §aMinimal performance impact.

option.REALISTIC_STARS=Realistic Stars
option.REALISTIC_STARS.comment=The real sky: 41,000 stars from the Hipparcos catalogue (ESA) with their true positions, brightness and colours, drawn as tiny sharp points that turn with the sky. They appear one by one after sunset, brightest first. §aMinimal performance impact.
option.STAR_BRIGHTNESS=Star Brightness
option.STAR_DENSITY=Star Density
option.STAR_DENSITY.comment=How faint the stars go. 0.5 = what the naked eye sees from a dark site (magnitude 6.5); 1.0 = every catalogue star (magnitude 8). Above 1.0 the faint stars are brightened, like a long exposure. §9No performance impact!
option.STAR_TWINKLE=Star Twinkling
option.STAR_TWINKLE.comment=Gentle, independent scintillation per star: almost none overhead, stronger and slightly coloured near the horizon. Not in the End (no air there).
option.STAR_TWINKLE_STRENGTH=Twinkle Strength
option.STAR_BLOOM=Bright Star Bloom
option.STAR_BLOOM.comment=A faint glow around only the brightest stars (Sirius, Vega...). 0 = points only. §9No performance impact!
option.MILKY_WAY=Milky Way
option.MILKY_WAY.comment=The real Milky Way from NASA's Deep Star Maps (Gaia data): star clouds, dark dust lanes, the galactic centre and the Magellanic Clouds. Washed out by a bright moon, hidden by clouds. §aMinimal performance impact.
option.MILKY_WAY_INTENSITY=Milky Way Brightness
option.MILKY_WAY_CONTRAST=Milky Way Contrast
option.MILKY_WAY_CONTRAST.comment=Separation between the bright star clouds and the dark lanes. §9No performance impact!
option.MILKY_WAY_STYLE=Night Sky Colour Style
option.MILKY_WAY_STYLE.comment=Natural Astronomy keeps the survey's own colours and near-white stars. Astrophotography adds a deeper black point, more contrast and colour, like a processed long exposure. Cinematic is richer still, with warm star clouds over cooler dust. §9No performance impact!
value.MILKY_WAY_STYLE.0=Natural Astronomy
value.MILKY_WAY_STYLE.1=Astrophotography
value.MILKY_WAY_STYLE.2=Cinematic
option.MILKY_WAY_TEXTURE_RES=Milky Way Texture Quality
option.MILKY_WAY_TEXTURE_RES.comment=8K is as sharp as the NASA map's detail allows along the galactic plane (64 MB of VRAM); 4K uses 16 MB and looks the same at 1080p with a normal field of view. §aMinimal performance impact.
value.MILKY_WAY_TEXTURE_RES.4096=4K
value.MILKY_WAY_TEXTURE_RES.8192=8K
option.MILKY_WAY_FILTER=Milky Way Filtering
option.MILKY_WAY_FILTER.comment=Footprint filtering stops faint stars in the Milky Way shimmering as the sky turns. Sharp also uses a bicubic filter when the texture is magnified (4K screens, zooming). §aMinimal performance impact.
value.MILKY_WAY_FILTER.0=Bilinear
value.MILKY_WAY_FILTER.1=Filtered
value.MILKY_WAY_FILTER.2=Filtered + Sharp
option.NIGHT_SKY_SEASON=Night Sky Season
option.NIGHT_SKY_SEASON.comment=Which part of the real sky is up at midnight. Summer: the galactic centre and the Cygnus Milky Way. Winter: Orion. Year Cycle drifts through all of them over 365 Minecraft days. Your latitude follows the Sun Path Rotation (-40 = 40° north).
value.NIGHT_SKY_SEASON.0=Summer
value.NIGHT_SKY_SEASON.1=Autumn
value.NIGHT_SKY_SEASON.2=Winter
value.NIGHT_SKY_SEASON.3=Spring
value.NIGHT_SKY_SEASON.4=Year Cycle
option.RAINBOWS=Rainbows
option.RAINBOWS.comment=Primary and secondary rainbows (with the dark band between them) opposite the sun as rain ends, while drops are still in the air. §2Imperceptible performance impact.
option.RAINBOW_BRIGHTNESS=Rainbow Brightness
option.CIRRUS_CLOUDS=Cirrus Clouds
option.CIRRUS_CLOUDS.comment=Thin, high, wind-streaked ice clouds behind the main clouds, with a faint 22° halo around the sun and moon. §2Low performance impact.
option.CIRRUS_COVERAGE=Cirrus Coverage
option.CLOUD_QUALITY=Cloud Quality
option.CLOUD_QUALITY.comment=Low/Medium: quarter resolution, 16/24 samples. High: half resolution, 32 samples (recommended for 1440p on a fast GPU). Ultra: half resolution, 48 samples. Cinematic: 75% resolution, 48 samples with longer light marches. Flying into clouds is handled at every quality. Custom: use the sample and resolution sliders. §cHigh performance impact!
value.CLOUD_QUALITY.0=Low
value.CLOUD_QUALITY.1=Medium
value.CLOUD_QUALITY.2=High
value.CLOUD_QUALITY.3=Ultra
value.CLOUD_QUALITY.4=Cinematic
value.CLOUD_QUALITY.5=Custom
option.VC_ALTITUDE=Cloud Height
option.VC_ALTITUDE.comment=Height of the cloud base (blocks). Storms lower it a little.
option.UNDERWATER_HAZE=Underwater Haze
option.UNDERWATER_HAZE.comment=Suspended particles in the water: makes distant things fade into a blue-green haze (and gives sun shafts something to light up). 0 = perfectly clear water. §9No performance impact!
option.UW_SUN_SHAFTS=Underwater Sun Shafts
option.UW_SUN_SHAFTS.comment=Beams of sunlight in the water, shaped by the waves and shadowed by terrain. Follow the time of day, clouds and rain. §6Moderate performance impact (only while under water).
option.UW_SHAFT_STRENGTH=Sun Shaft Strength
option.UW_SHAFT_SAMPLES=Underwater Sun Shaft Quality
option.UW_SHAFT_SAMPLES.comment=Samples along each view ray for the underwater sun shafts. §6Moderate performance impact (only while under water).
option.LAVA_BRIGHTNESS=Lava Brightness
option.LAVA_BRIGHTNESS.comment=How bright the lava surface itself is. §9No performance impact!
option.LAVA_EMISSION=Lava Emission Strength
option.LAVA_EMISSION.comment=Extra glow of the hottest (yellow) streaks; the dark crust stays dark, so the flow pattern stays visible. §9No performance impact!
option.LAVA_BLOOM=Lava Bloom
option.LAVA_BLOOM.comment=How much lava contributes to bloom (the glow around bright things). Other bloom is unaffected. §9No performance impact!
option.LAVA_LIGHT_STRENGTH=Lava Coloured Lighting
option.LAVA_LIGHT_STRENGTH.comment=How strongly lava lights its surroundings with Coloured Blocklight (floodfill). §9No performance impact!
option.NETHER_EXPOSURE=Nether Exposure
option.NETHER_EXPOSURE.comment=Brightness offset for the Nether, in stops. Auto exposure also brightens dark Nether views by at most 1 stop there, so looking away from lava doesn't make the exposure pump. §9No performance impact!
option.CAUSTICS_STRENGTH=Caustics Strength
option.CAUSTICS_STRENGTH.comment=Contrast of the moving light patterns on underwater surfaces (procedural caustics). Weaker automatically in overcast and rain. §9No performance impact!

screen.NETHER=Nether
screen.NETHER.comment=Smoke, haze, heat shimmer and lava.
screen.END=The End
screen.END.comment=The cosmic sky: black hole, stars and nebulae.

option.NETHER_SMOKE=Nether Smoke
option.NETHER_SMOKE.comment=Thin layers of rising, slowly swirling smoke, lit by lava and fire. Off leaves a plain distance haze. §6Moderate performance impact (Nether only).
option.NETHER_SMOKE_DENSITY=Smoke Density
option.NETHER_SMOKE_DENSITY.comment=How thick the smoke layers are. 0 keeps only the haze. §9No performance impact!
option.NETHER_SMOKE_QUALITY=Smoke Quality
option.NETHER_SMOKE_QUALITY.comment=Samples along each view ray (first 128 blocks). More = smoother smoke with less noise. §6Moderate performance impact.
option.NETHER_VISIBILITY=Nether Visibility
option.NETHER_VISIBILITY.comment=Distance in blocks at which the haze hides almost everything (5% left). Nearby blocks always stay clear. §9No performance impact!
option.NETHER_FOG_TINT=Nether Fog Colour
option.NETHER_FOG_TINT.comment=How much of the biome's fog colour the haze takes: 0 = neutral smoky grey, 1 = biome colour (slightly toned down), above 1 = stronger. §9No performance impact!
option.NETHER_LAVA_GLOW=Smoke Lava Glow
option.NETHER_LAVA_GLOW.comment=How strongly lava and fire light up the smoke and haze around them. §9No performance impact!
option.HEAT_HAZE=Heat Haze
option.HEAT_HAZE.comment=Gentle shimmer above lava and fire, rising with the heat. §2Imperceptible performance impact.
option.HEAT_HAZE_STRENGTH=Heat Haze Strength
option.HEAT_HAZE_STRENGTH.comment=How far the shimmer bends the image (at most a few pixels). §9No performance impact!

option.COSMIC_SKY=Cosmic Sky
option.COSMIC_SKY.comment=Replaces the End sky with deep space: stars, nebulae and (optionally) a black hole. Off gives the old dark sky. §6Moderate performance impact (End only).
option.BLACK_HOLE=Black Hole
option.BLACK_HOLE.comment=A black hole with a glowing accretion disk and real gravitational lensing of the stars behind it. It sits where the End's light comes from (move it with Sun Path Rotation) and its disk lights the islands. §6Moderate performance impact.
option.BH_SIZE=Black Hole Size
option.BH_SIZE.comment=Angular radius of the black shadow, in degrees. The disk and lensing scale with it. §9No performance impact!
option.BH_DISK_BRIGHTNESS=Accretion Disk Brightness
option.BH_DISK_BRIGHTNESS.comment=Brightness of the disk, its glow, and the light it casts on the islands. §9No performance impact!
option.BH_PHOTON_RING=Photon Ring Intensity
option.BH_PHOTON_RING.comment=Brightness of the thin rings of light that circled the hole before reaching you (the disk's secondary images). §9No performance impact!
option.BH_QUALITY=Lensing Quality
option.BH_QUALITY.comment=Integration steps for the light paths around the hole. Higher = cleaner photon ring and lensed star field. §6Moderate performance impact.
value.BH_QUALITY.0=Low
value.BH_QUALITY.1=Medium
value.BH_QUALITY.2=High
value.BH_QUALITY.3=Cinematic
option.BH_DISK_TILT=Disk Tilt
option.BH_DISK_TILT.comment=How far the disk is tilted towards you, in degrees. 0 = exactly edge-on. §9No performance impact!
option.BH_DISK_ROLL=Disk Roll
option.BH_DISK_ROLL.comment=Rotates the disk around the line of sight, in degrees. §9No performance impact!
option.BH_DISK_OUTER=Disk Size
option.BH_DISK_OUTER.comment=Outer radius of the disk, in units of the hole's mass (the inner edge is fixed at 6, the innermost stable orbit). §9No performance impact!
option.BH_ROTATION_SPEED=Disk Rotation Speed
option.BH_ROTATION_SPEED.comment=How fast the disk's structure swirls (inner parts orbit faster). §9No performance impact!
option.BH_DOPPLER=Doppler Beaming
option.BH_DOPPLER.comment=How much brighter and bluer the side of the disk moving towards you is. 1 = physically full strength (very lopsided), 0 = none (like the film Interstellar). §9No performance impact!
option.BH_LIGHT=Disk Light on Islands
option.BH_LIGHT.comment=Strength of the warm light the disk casts on End terrain. §9No performance impact!
option.COSMIC_CLOUDS=Nebulae
option.COSMIC_CLOUDS.comment=Distant clouds of glowing gas and dark dust lanes. §2Imperceptible performance impact.
option.NEBULA_DENSITY=Nebula Density
option.NEBULA_DENSITY.comment=How much gas and dust there is. §9No performance impact!
option.NEBULA_BRIGHTNESS=Nebula Brightness
option.NEBULA_BRIGHTNESS.comment=§9No performance impact!
option.END_STAR_DENSITY=Star Density
option.END_STAR_DENSITY.comment=Number of stars in the End sky. §9No performance impact!
option.END_STAR_BRIGHTNESS=Star Brightness
option.END_STAR_BRIGHTNESS.comment=§9No performance impact!
option.END_AMBIENT=End Ambient Light
option.END_AMBIENT.comment=The soft violet light from the whole sky that fills shadows in the End. §9No performance impact!
option.END_FOG_DENSITY=End Fog Density
option.END_FOG_DENSITY.comment=Thin dust between the islands; far islands fade into the dark of space. Nothing within 32 blocks is affected. 1 = about a quarter of the light lost at 350 blocks. §9No performance impact!

option.WAVE_DETAIL=Detail Waves
option.WAVE_DETAIL.comment=Strength of the medium-size waves on top of the long swells. §9No performance impact!
option.WAVE_RIPPLES=Small Ripples
option.WAVE_RIPPLES.comment=Strength of the tiny close-up ripples that break up the sun's reflection. §9No performance impact!
option.WATER_BIOME_WAVES=Waves by Biome
option.WATER_BIOME_WAVES.comment=Oceans get bigger swells, rivers calmer drifting water, based on the biome you're in. Shallow water is always calmer. §9No performance impact!

option.END_AMBIENT_TINT=End Ambient Tint
option.END_AMBIENT_TINT.comment=Colour of the soft sky light on End terrain: 0 = neutral grey, 1 = violet. §9No performance impact!
option.END_FOG_TINT=End Fog Colour
option.END_FOG_TINT.comment=0 = grey dust, 1 = violet. §9No performance impact!
option.COSMIC_SKY_BRIGHTNESS=Cosmic Sky Brightness
option.COSMIC_SKY_BRIGHTNESS.comment=Brightness of the stars, nebulae and galaxies (not the black hole's disk). §9No performance impact!
option.NEBULA_SATURATION=Nebula Saturation
option.NEBULA_SATURATION.comment=0 = grey gas, 1 = full colour. §9No performance impact!
option.DEBUG_VIEW=Debug View
option.DEBUG_VIEW.comment=Turns single parts of the image off to find where a look comes from. Leave Off for normal play.
value.DEBUG_VIEW.0=Off
value.DEBUG_VIEW.1=No aerial perspective
value.DEBUG_VIEW.2=No height fog
value.DEBUG_VIEW.3=No fog at all
value.DEBUG_VIEW.4=Fixed exposure
value.DEBUG_VIEW.5=No colour grading
value.DEBUG_VIEW.6=Direct sunlight only
value.DEBUG_VIEW.7=Sky light only
value.DEBUG_VIEW.8=Raw HDR (no tone map)
value.DEBUG_VIEW.9=Water simulation height
value.DEBUG_VIEW.10=Cloud shadows (blue = shaded)

option.INTERACTIVE_WATER=Interactive Water
option.INTERACTIVE_WATER.comment=A real-time wave simulation around you: ripples when you wade, swim or drop into water, and V-shaped wakes behind your boat. It sleeps when you are away from water. Only your own player and boat (Iris doesn't expose other entities). §eSmall performance impact.
option.WATER_SIM_QUALITY=Simulation Quality
option.WATER_SIM_QUALITY.comment=How far around you the waves show, and how fine they are. Balanced: ~17 blocks, 30 Hz. High: ~25 blocks, 60 Hz. Ultra: ~40 blocks, finer. Cinematic: ~66 blocks (whole boat trails), finest.
value.WATER_SIM_QUALITY.1=Balanced
value.WATER_SIM_QUALITY.2=High
value.WATER_SIM_QUALITY.3=Ultra
value.WATER_SIM_QUALITY.4=Cinematic
option.WATER_SIM_STRENGTH=Interactive Wave Strength
option.WATER_SIM_STRENGTH.comment=How strongly the simulated waves bend the water's reflections and refraction. §9No performance impact!
option.PLAYER_RIPPLE_STRENGTH=Player Ripples
option.PLAYER_RIPPLE_STRENGTH.comment=Strength of the ripples from wading, swimming and splashing in. §9No performance impact!
option.BOAT_WAKE_STRENGTH=Boat Wakes
option.BOAT_WAKE_STRENGTH.comment=Strength of your boat's wake. §9No performance impact!

option.CLOUD_SHADOW_VISIBILITY=Cloud Shadow Visibility
option.CLOUD_SHADOW_VISIBILITY.comment=How much darker the world stays when a cloud covers the sun, after your eyes adapt. 0 = auto exposure cancels the shadow (old behaviour), 1 = exposure ignores clouds. §9No performance impact!
option.CLOUD_SHADOW_RES=Cloud Shadow Resolution
option.CLOUD_SHADOW_RES.comment=Detail of the cloud shadows on the ground: 256 = soft (6 blocks per texel at the default range), 512 = sharper edges. §eSmall performance impact.

option.END_PORTAL_BRIGHTNESS=End Portal Brightness
option.END_PORTAL_BRIGHTNESS.comment=Glow of End portals and gateways, which show the End's deep space: stars, nebulae, drifting motes and a small lensed black hole. §9No performance impact!
option.VANILLA_METALS=Vanilla Metals
option.VANILLA_METALS.comment=Without a LabPBR resource pack, iron, gold, copper and netherite blocks shade as metal (reflective, tinted by their texture). A LabPBR pack's own materials always take priority. §9No performance impact!
```

