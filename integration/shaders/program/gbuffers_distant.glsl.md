# Halcyon changes to Glimmer file `shaders/program/gbuffers_distant.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 29 — in `main()`

```glsl
  // DH gives us its own block IDs so translate them to ours. 1001 water, 1022 lava, 1009 leaves. memorized these like my phone number
  materialID =
    dhMaterialId == DH_BLOCK_WATER ? 1001
    : dhMaterialId == DH_BLOCK_LAVA ? 1022
    : dhMaterialId == DH_BLOCK_LEAVES ? 1009
    : 0;
```

## 2. inserted after Glimmer line 49 — in `main()`

```glsl
#include "/lib/water/wetnessSimple.glsl"
#include "/lib/lighting/lava.glsl"
```

## 3. replaces Glimmer line 115 — in `main()`

```glsl
  material.f0 = vec3(0.04);
```

## 4. replaces Glimmer line 129 — in `main()`

```glsl
    material.albedo.rgb *= lavaPatchiness(playerPos + cameraPosition); // lava gets blotches and glows. lava is the most-commented substance in this entire pack
    material.emission = lavaEmission(material.albedo.rgb);
```

## 5. replaces Glimmer lines 132-144 — in `main()`

```glsl
  if (!isWater(materialID)) {
    applySurfaceWetnessSimple(material, worldNormal.y, lightmap.y);
```

## 6. Removed Glimmer code (replaces Glimmer line 146) — in `main()`

Halcyon deletes these Glimmer lines (no replacement).

