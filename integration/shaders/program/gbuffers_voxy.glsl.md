# Halcyon changes to Glimmer file `shaders/program/gbuffers_voxy.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 22

```glsl
#define gbufferPreviousModelView vxModelViewPrev // this used to say "#define vxModelView vxModelViewPrev" which quietly made gbufferModelView LAST frame's matrix. everything lagged one frame behind and I lost my entire mind for two days
```

## 2. inserted after Glimmer line 29

```glsl
#include "/lib/lighting/lava.glsl"
```

## 3. replaces Glimmer line 72 — in `voxy_emitFragment()`

```glsl
  material.f0 = vec3(0.04);
```

## 4. replaces Glimmer line 86 — in `voxy_emitFragment()`

```glsl
    material.albedo.rgb *= lavaPatchiness(playerPos + cameraPosition);
    material.emission = lavaEmission(material.albedo.rgb);
```

## 5. Removed Glimmer code (replaces Glimmer lines 89-103) — in `voxy_emitFragment()`

Halcyon deletes these Glimmer lines (no replacement).

