# Halcyon changes to Glimmer file `shaders/program/c4_fog.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 72 — in `main()`

```glsl
// the include guards in here are a nightmare. debug view 10 OR volumetric clouds. I drew a truth table on paper for this
#if (DEBUG_VIEW == 10 && defined CLOUDS && defined CLOUD_SHADOWS) || (defined VOLUMETRIC_CLOUDS && defined CLOUDS)
#include "/lib/atmosphere/clouds.glsl"
#endif
#if defined VOLUMETRIC_CLOUDS && defined CLOUDS
#include "/lib/atmosphere/cloudComposite.glsl"
#endif
```

## 2. inserted after Glimmer line 77 — in `main()`

```glsl
#if defined VOLUMETRIC_CLOUDS && defined CLOUDS
// draw clouds on top of the terrain. if the clouds are behind the ground, skip. if you're looking at the sky, skip. it's a lot of skipping
vec3 applyCloudsToGeometry(vec3 color, float opaqueDepth, vec3 opaqueViewPos, bool oceanPlane, vec3 viewPos) {
  if (opaqueDepth >= 1.0 && !oceanPlane) return color;
  vec3 v = oceanPlane ? viewPos : opaqueViewPos;
  float sceneDist = length(v);
  vec3 cloudDir = normalize(mat3(gbufferModelViewInverse) * v);
  // vcSlab = where the ray enters and leaves the cloud layer. x is in, y is out. or the other way around. no, it's that way. I checked
  vec2 cloudSlab = vcSlab(cameraPosition, cloudDir, vcLayer());
  if (!(cloudSlab.y > cloudSlab.x && cloudSlab.x < sceneDist)) return color;
  // CLOUD_SKY_DISTANCE - 1.0 because at exactly the sky distance it flickered. one block. ONE BLOCK of difference
  float lookupDist = oceanPlane ? CLOUD_SKY_DISTANCE : min(sceneDist, CLOUD_SKY_DISTANCE - 1.0);
  vec4 cloud = sampleCloudsUpsampled(texcoord, lookupDist);
  // alpha is how much shows through, rgb is the cloud light. premultiplied alpha or whatever the kids call it
  return color * cloud.a + cloud.rgb;
}
#endif
```

## 3. inserted after Glimmer line 113 — in `main()`

```glsl
  // the end and the nether get their own special fog. debug view 3 turns them off. I don't remember why that's view 3
  #if defined WORLD_THE_END && DEBUG_VIEW != 3
  color.rgb = endFog(color.rgb, viewPos, depth);
  #endif
  #if defined WORLD_THE_NETHER && DEBUG_VIEW != 3
  color.rgb = netherAtmosphere(color.rgb, viewPos, depth);
  #endif
```

## 4. replaces Glimmer line 116 — in `main()`

```glsl
  #if defined VOLUMETRIC_CLOUDS && defined CLOUDS
  // if you're below the clouds, draw them before the fog so the fog covers them. above the clouds? after. this was a whole saga
  bool cloudsBeforeFog = cameraPosition.y < vcLayer().x;
  if (cloudsBeforeFog) color.rgb = applyCloudsToGeometry(color.rgb, opaqueDepth, opaqueViewPos, infiniteOceanMask, viewPos);
  #endif
  // atmospheric fog, unless debug view 1 or 3 is on. so many debug views. I have no idea which is which anymore
  #if defined ATMOSPHERIC_FOG && DEBUG_VIEW != 1 && DEBUG_VIEW != 3
```

## 5. inserted after Glimmer line 123 — in `main()`

```glsl
  #if DEBUG_VIEW != 2 && DEBUG_VIEW != 3
```

## 6. inserted after Glimmer line 125 — in `main()`

```glsl
  #endif

  // debug view 10: paints cloud shadows blue. 0.2 0.35 1.0 is "debug blue". I made it up. it's ugly on purpose
  #if DEBUG_VIEW == 10 && defined CLOUDS && defined CLOUD_SHADOWS
  if (depth < 1.0) {
    float cs = luminance(getCloudShadow((gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz));
    color.rgb = mix(color.rgb, luminance(color.rgb) * vec3(0.2, 0.35, 1.0), 1.0 - cs);
  }
  #endif
  #endif

  // above the clouds? draw them now, after the fog. see the saga above
  #if defined VOLUMETRIC_CLOUDS && defined CLOUDS
  if (!cloudsBeforeFog) color.rgb = applyCloudsToGeometry(color.rgb, opaqueDepth, opaqueViewPos, infiniteOceanMask, viewPos);
```

