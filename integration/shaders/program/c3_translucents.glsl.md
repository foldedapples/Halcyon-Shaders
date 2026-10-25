# Halcyon changes to Glimmer file `shaders/program/c3_translucents.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 38 — in `main()`

```glsl
// interactive water only exists in the overworld. nested ifdefs because && apparently wasn't good enough for past me
#ifdef INTERACTIVE_WATER
#ifdef WORLD_OVERWORLD
#include "/lib/water/waterSim.glsl"
#endif
#endif
```

## 2. inserted after Glimmer line 43 — in `main()`

```glsl
#include "/lib/water/rainRipples.glsl"
#include "/lib/lighting/opaqueReflections.glsl"
#include "/lib/water/underwaterShafts.glsl"
```

## 3. inserted after Glimmer line 72 — in `main()`

```glsl
  bool floorIsDh = dhMask;
```

## 4. Removed Glimmer code (replaces Glimmer line 109) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 5. replaces Glimmer lines 120-122 — in `main()`

```glsl
    float viewDistance = length(translucentViewPos);
    vec2 waterWorldXZ = translucentFeetPlayerPos.xz + cameraPosition.xz;

    // coastal waves: waves get smaller in shallow water. 1.0 = full ocean, smaller = chill beach
    float coastalFactor = 1.0;
    #ifdef COASTAL_WAVES
    if (inWater) {
      // underwater it's 0.4. sideways water (waterfalls) gets 0.5. these numbers mean nothing, I just liked them
      coastalFactor = 0.4;
    } else if (worldNormal.y > 0.5 && opaqueDepth < 1.0 && !infiniteOceanMask) {
      float verticalDepth = translucentFeetPlayerPos.y - opaqueFeetPlayerPos.y;
      // shallow (0.3 blocks) = tiny waves, deep (10 blocks) = full waves
      coastalFactor = smoothstep(0.3, 10.0, verticalDepth);
    } else if (worldNormal.y <= 0.5) {
      coastalFactor = 0.5;
    }
    #endif

    // rain ripples only on top surfaces. ripples on the side of a waterfall would be insane
    vec2 rippleSlope = vec2(0.0);
    if (worldNormal.y > 0.5 && !inWater) {
      rippleSlope = rainRippleSlope(
        waterWorldXZ,
        rainRippleIntensity(skyLightmap),
        viewDistance
      );
    }

    #if defined INTERACTIVE_WATER && defined WORLD_OVERWORLD
    if (worldNormal.y > 0.5) {
      // boat wakes and splashes get added to the ripples. halved underwater because it looked like a seizure from below
      rippleSlope += waterSimSlope(translucentFeetPlayerPos) * (inWater ? 0.5 : 1.0);
    }
    #endif

    // parallax only on perfectly flat-up water (0.99). blue noise to hide the stepping. blue noise is just better noise, don't ask
    vec2 waveSamplePos = waterWorldXZ;
    if (worldNormal.y > 0.99 && !inWater) {
      waveSamplePos =
        getWaterParallaxPos(
```

## 6. Removed Glimmer code (replaces Glimmer line 124) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 7. inserted after Glimmer line 126 — in `main()`

```glsl
        ) +
        cameraPosition.xz;
    }

    float cosView = abs(dot(normal, viewDir));
    // LOD filtering version: fancy anti-aliasing for distant waves. the normal version: shimmery chaos. pick your poison
    #ifdef WATER_LOD_FILTERING
    float filteredSlopeVariance;
    worldWaveNormal = waveNormal(
      waveSamplePos,
      worldNormal,
      heightmapFactor,
      coastalFactor,
      viewDistance,
      rippleSlope,
      // the horizontal view direction, normalized. 1e-4 because looking straight down makes this zero and then it's NaN city
      worldDir.xz / max(length(worldDir.xz), 1e-4),
      waterFootprint(viewDistance, cosView),
      filteredSlopeVariance
```

## 8. replaces Glimmer line 128 — in `main()`

```glsl
    #else
```

## 9. replaces Glimmer line 130 — in `main()`

```glsl
      waveSamplePos,
```

## 10. replaces Glimmer line 132 — in `main()`

```glsl
      heightmapFactor,
      coastalFactor,
      viewDistance,
      rippleSlope
```

## 11. inserted after Glimmer line 133 — in `main()`

```glsl
    #endif
    // back to view space. we go world -> view -> world -> view so many times in this file I get motion sick
    vec3 waveNormal = mat3(gbufferModelView) * worldWaveNormal;
    material.roughness = waterRoughness(viewDistance, cosView);
    #ifdef WATER_LOD_FILTERING
    // add the variance we filtered out back into roughness. physics says roughness squared adds. I trust physics. sometimes
    material.roughness = sqrt(pow2(material.roughness) + filteredSlopeVariance);
    #endif

    // from underwater the surface distortion is turned down by a slider so you don't throw up
    if (inWater) {
      waveNormal = normalize(mix(normal, waveNormal, UNDERWATER_SURFACE_DISTORTION));
```

## 12. Removed Glimmer code (replaces Glimmer line 135) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 13. inserted after Glimmer line 140 — in `main()`

```glsl
    // underwater looking up? flip the normals because we're on the other side now. spatial reasoning is hard
    if (inWater && dot(normal, viewDir) > 0.0) {
      normal = -normal;
      waveNormal = -waveNormal;
    }
```

## 14. replaces Glimmer lines 148-151 — in `main()`

```glsl
    vec3 refractionNormal = inWater ? waveNormal : normal;

    vec3 refractedDir;
    // "clear underwater" mode: fake refraction, just nudge the view direction. 0.35 is a vibe
    #ifdef UNDERWATER_CLEAR
    if (inWater) {
      refractedDir = normalize(viewDir + (waveNormal - normal) * 0.35 * REFRACTION_STRENGTH);
    } else
    #endif
    if (inWater) {
      // water to air: index 1.33. refract() returns zero if the light can't get out (total internal reflection). that's the mirror effect when you look up at a steep angle underwater. SCIENCE
      vec3 rawRefract = refract(viewDir, waveNormal, 1.33);
      if (rawRefract == vec3(0.0)) {
        totalInternalReflection = true;
        refractedDir = viewDir;
      } else {
        refractedDir = normalize(rawRefract);
      }
    } else {
      // air to water: refract with the flat normal and the wavy normal and only use the difference. so flat water doesn't shift everything. took me so long to figure out
      vec3 flatRefract = refract(viewDir, normal, rcp(1.33));
      vec3 waveRefract = refract(viewDir, waveNormal, rcp(1.33));
      refractedDir = normalize(
        viewDir + (waveRefract - flatRefract) * REFRACTION_STRENGTH
```

## 15. inserted after Glimmer line 152 — in `main()`

```glsl
    }
```

## 16. replaces Glimmer line 157 — in `main()`

```glsl
      refractedDir * min(distance(translucentViewPos, opaqueViewPos), 12.0);
```

## 17. replaces Glimmer lines 165-170 — in `main()`

```glsl
    // dhOverrideAt returns a bool AND writes stuff. side effects, my favorite. not
    bool refractedDh = dhOverrideAt(refractedPos.xy, refractedDepth, refractedViewPos, true);

    bool refractedOnScreen = clamp01(refractedPos.xy) == refractedPos.xy;
    bool refractedThroughWater = infiniteOceanMask;
    // only accept the refracted pixel if it's ALSO underwater. otherwise you see the dry land behind the water through the water and it's a mess
    if (refractedOnScreen && !refractedThroughWater) {
      int refractedMaterial = int(texture(colortex1, refractedPos.xy).a * 255 + 0.5) + 1000;
      // 1001 is water. DH_BLOCK_WATER is DH water. hardcoded 1001 because I'm a monster
      refractedThroughWater = refractedMaterial == 1001 || refractedMaterial == DH_BLOCK_WATER;
```

## 18. replaces Glimmer lines 173-175 — in `main()`

```glsl
    bool transmits = !inWater;
    if (inWater) {
      #ifdef UNDERWATER_CLEAR
      transmits = true;
      #else
      transmits = refract(viewDir, refractionNormal, 1.33) != vec3(0.0);
      #endif
    }

    // can't transmit = mirror. otherwise check the refracted pixel is behind the surface and actually underwater. this if-statement has 3 lines of conditions and every one of them was a bug report
    if (!transmits) {
      totalInternalReflection = true;
    } else if (
      refractedOnScreen &&
      refractedThroughWater &&
      (refractedDepth == 1.0 ? !infiniteOceanMask : refractedViewPos.z < translucentViewPos.z)
```

## 19. replaces Glimmer lines 180-183 — in `main()`

```glsl
      floorIsDh = refractedDh;
    }
    #ifndef UNDERWATER_CLEAR
    // underwater looking up through the surface and the refracted ray left the screen? paint the sky in manually. clouds too. I'm exhausted
    else if (inWater && !refractedOnScreen) {
```

## 20. Removed Glimmer code (replaces Glimmer lines 192-193) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

## 21. replaces Glimmer lines 196-198 — in `main()`

```glsl
    #endif

    #endif
    // clear underwater mode never does total internal reflection. it's clear. that's the point. no mirrors
    #ifdef UNDERWATER_CLEAR
    totalInternalReflection = false;
```

## 22. replaces Glimmer line 223 — in `main()`

```glsl
      if (floorIsDh && worldNormal.y > 0.5) {
```

## 23. replaces Glimmer line 225 — in `main()`

```glsl
        // divide by the sun angle so low sun = longer path = more fog. 0.1 so the sunset doesn't divide by zero. there's ALWAYS a divide by zero
        dhFactor = (translucentFeetPlayerPos.y - opaqueFeetPlayerPos.y) / max(cost, 0.1);
```

## 24. inserted after Glimmer line 247 — in `main()`

```glsl
    // if the reflection points INTO the water, nudge it back up a bit (0.02). otherwise you get black reflections at grazing angles. this block saved my life
    {
      float side = dot(reflectedDir, normal);
      float viewSide = -sign(dot(viewDir, normal));
      if (side * viewSide < 0.02) {
        reflectedDir = normalize(reflectedDir + normal * viewSide * (0.02 - side * viewSide));
      }
    }
```

## 25. inserted after Glimmer line 254 — in `main()`

```glsl
    #ifdef UNDERWATER_CLEAR
    doReflections = doReflections && !inWater;
    #endif
```

## 26. inserted after Glimmer line 262 — in `main()`

```glsl
    vec3 sunGlint = vec3(0.0);
```

## 27. inserted after Glimmer line 320 — in `main()`

```glsl
      int hitMaterial = int(texture(colortex1, reflectedPos.xy).a * 255 + 0.5) + 1000;
      if ((hitMaterial == 1001 || hitMaterial == DH_BLOCK_WATER) && texture(depthtex0, reflectedPos.xy).r < texture(depthtex1, reflectedPos.xy).r) {
        reflectionHit = false;
      }
    }

    if (reflectionHit) {
```

## 28. inserted after Glimmer line 334 — in `main()`

```glsl
      // fog on the reflection too, otherwise reflected mountains look crisp and the real ones are foggy and it's obvious
      #ifdef WORLD_OVERWORLD
```

## 29. inserted after Glimmer line 347 — in `main()`

```glsl
      #endif
```

## 30. inserted after Glimmer line 354 — in `main()`

```glsl
      // also fade when the reflection points toward the camera (z > 0.15). screen space has nothing to show there anyway
      fadeFactor *= 1.0 - smoothstep(0.15, 0.6, reflectedDir.z);
```

## 31. replaces Glimmer line 357 — in `main()`

```glsl
    // underwater with a missed reflection? reflect murky water fog 256 blocks out. it's just blue nothing, but it's convincing blue nothing
    if (fadeFactor < 1.0 && inWater) {
      vec3 reflectedFar = translucentViewPos + reflectedDir * 256.0;
      vec3 waterReflection = underwaterFog(vec3(0.0), translucentViewPos, reflectedFar);
      reflectedColor = mix(waterReflection, reflectedColor, fadeFactor);
    } else if (fadeFactor < 1.0) {
```

## 32. inserted after Glimmer line 358 — in `main()`

```glsl
      #if defined ROUGH_SKY_REFLECTIONS && !defined WORLD_THE_END
      // rough sky reflections: pick a blurrier mip of the sky map for rough water. 163 is... a number. I tuned it. I don't remember how
      float skyMip = max(0.0, log2(max(material.roughness, 1e-4) * 163.0));
      vec3 skyReflection = textureLod(colortex7, mapSphere(reflectedDir), skyMip).rgb;
      #else
```

## 33. inserted after Glimmer line 367 — in `main()`

```glsl
      #endif
```

## 34. replaces Glimmer lines 378-379 — in `main()`

```glsl
      // sun glint! the sparkly sun on the water. the 0.05 check is because the brdf divides by NoV and at 0 it explodes into a white supernova
      if (minVec3(shadow) > 0.0 && dot(waveNormal, lightDir) > 0.0 && dot(waveNormal, -viewDir) > 0.05) {
        sunGlint = max0(
```

## 35. replaces Glimmer line 389 — in `main()`

```glsl
        // only where the sky reaches. smoothstep 0.1 to 1.0 on the sky light. caves don't sparkle
        ) * (1.0 - fadeFactor) * smoothstep(0.1, 1.0, skyLightmap);
```

## 36. replaces Glimmer line 391 — in `main()`

```glsl
      // this ifdef has a NOT inside parentheses inside a NOT. I had to read it 6 times
      #if defined CLOUDY_FOG && !(defined ROUGH_SKY_REFLECTIONS && !defined WORLD_THE_END)
```

## 37. replaces Glimmer lines 407-410 — in `main()`

```glsl
    // fresnel: how much is reflection vs see-through based on the angle. look straight down = see through. look along = mirror. nature is wild
    float cosI = clamp01(dot(waveNormal, normalize(-translucentViewPos)));
    vec3 waterFresnel;
    #ifdef UNDERWATER_CLEAR
    if (inWater) {
      // clear mode fake fresnel. 0.25 because 1.0 made it look like a mirror from below
      waterFresnel = vec3(0.02 + 0.25 * pow5(1.0 - cosI));
    } else
    #endif
    if (inWater) {
      // snell's law AGAIN to see if light can escape from underwater. if sin2T >= 1 it can't. total internal reflection. that's the shimmery mirror ceiling thing
      float sin2T = pow2(1.33) * (1.0 - cosI * cosI);
      if (sin2T >= 1.0) {
        waterFresnel = vec3(1.0);
      } else {
        float cosT = sqrt(1.0 - sin2T);
        // schlick's approximation. 0.02 + 0.98 * (1-cos)^5. every shader on earth has this line. it's the law
        waterFresnel = vec3(0.02 + 0.98 * pow5(1.0 - cosT));
      }
    } else {
      waterFresnel = fresnel(material, cosI);
      #ifdef WATER_REFLECTION_MASKING
      #ifndef VANILLA_WATER
      // rough water reflects a bit less at grazing angles (masking). the Heitz thing from waveNormals. I'm pretending I get it
      waterFresnel *= waterReflectionMasking(material.roughness, cosI);
      #endif
      #endif
    }
```

## 38. replaces Glimmer line 412 — in `main()`

```glsl
      waterFresnel = vec3(1.0);
```

## 39. replaces Glimmer line 415 — in `main()`

```glsl
    // finally mix the reflection in. 500 lines of setup for this one mix(). worth it? maybe
    color.rgb = mix(color.rgb, reflectedColor * WATER_REFLECTION_STRENGTH, waterFresnel);
    color.rgb += sunGlint * WATER_REFLECTION_STRENGTH;

    // debug view 9 shows the water sim. red = up, blue = down. times 20 so you can actually see it. times 3 for drama
    #if DEBUG_VIEW == 9 && defined INTERACTIVE_WATER && defined WORLD_OVERWORLD
    float simH = clamp(waterSimHeight(translucentFeetPlayerPos) * 20.0, -1.0, 1.0);
    color.rgb *= vec3(1.0 + max(simH, 0.0) * 3.0, 1.0 - abs(simH) * 0.5, 1.0 + max(-simH, 0.0) * 3.0);
    #endif
```

## 40. replaces Glimmer lines 419-422 — in `main()`

```glsl
  // opaque SSR: reflections on shiny non-water stuff. same ideas, different file, same suffering
  #ifdef SSR_OPAQUE
  // not water, nothing translucent in front, not sky, not your hand, not DH. five conditions to reflect one block
  if (
    !isWater &&
    translucentDepth == opaqueDepth &&
    opaqueDepth < 1.0 &&
    opaqueDepth > handDepth &&
    !dhMask
  ) {
    color.rgb = applyOpaqueReflections(
```

## 41. replaces Glimmer lines 424-431 — in `main()`

```glsl
      texcoord,
```

## 42. replaces Glimmer line 433 — in `main()`

```glsl
      normal,
      skyLightmap
```

## 43. inserted after Glimmer line 435 — in `main()`

```glsl
  #endif

  // underwater fog for the camera being underwater. cap at the render distance so it doesn't go forever
  if (inWater) {
    vec3 fogEnd = isWater ? translucentViewPos : opaqueViewPos;
    if (length(fogEnd) > far) fogEnd = normalize(fogEnd) * far;
    // god rays underwater if enabled. jitter so they don't band. pretty, slow, worth it
    #ifdef UW_SUN_SHAFTS
    color.rgb = underwaterFog(color.rgb, vec3(0.0), fogEnd, false);
    float shaftJitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
    color.rgb += underwaterSunShafts(fogEnd, shaftJitter);
    #else
    color.rgb = underwaterFog(color.rgb, vec3(0.0), fogEnd);
    #endif
```

