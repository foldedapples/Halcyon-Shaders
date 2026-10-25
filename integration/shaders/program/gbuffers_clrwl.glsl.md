# Halcyon changes to Glimmer file `shaders/program/gbuffers_clrwl.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 84-86 — in `getMappedNormal()`

```glsl
  mappedNormal.z = sqrt(max0(1.0 - dot(mappedNormal.xy, mappedNormal.xy))); // rebuild z from x and y because the texture only stores two channels. pythagoras finally paying off

  return normalize(tbnMatrix * mappedNormal);
```

## 2. inserted after Glimmer line 127 — in `main()`

```glsl
  #if PBR_MODE != 0
```

## 3. inserted after Glimmer line 128 — in `main()`

```glsl
  #endif
```

## 4. inserted after Glimmer line 130 — in `main()`

```glsl
  material.metalID = NO_METAL;
```

