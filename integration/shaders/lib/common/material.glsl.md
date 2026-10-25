# Halcyon changes to Glimmer file `shaders/lib/common/material.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 30 — in `getMetalN_K()`

```glsl
// "column by column and scrambles n/k"?? past me wrote this and I have NO clue what it means
// returns some n and k thing per metal. n is refraction? k is... spiciness? idk
// all these numbers came off some physics website, I copy pasted them and prayed
mat2x3 getMetalN_K(uint metalID) {
```

## 2. replaces Glimmer line 33 — in `getMetalN_K()`

```glsl
      return mat2x3(vec3(2.9114, 2.9497, 2.5845), vec3(3.0893, 2.9318, 2.767));
```

## 3. replaces Glimmer line 35 — in `getMetalN_K()`

```glsl
      return mat2x3(
```

## 4. replaces Glimmer line 40 — in `getMetalN_K()`

```glsl
      return mat2x3(
```

## 5. replaces Glimmer line 45 — in `getMetalN_K()`

```glsl
      return mat2x3(vec3(3.1071, 3.1812, 2.323), vec3(3.3314, 3.3291, 3.135));
```

## 6. replaces Glimmer line 47 — in `getMetalN_K()`

```glsl
      return mat2x3(
```

## 7. replaces Glimmer line 52 — in `getMetalN_K()`

```glsl
      return mat2x3(vec3(1.91, 1.83, 1.44), vec3(3.51, 3.4, 3.18));
```

## 8. replaces Glimmer line 54 — in `getMetalN_K()`

```glsl
      return mat2x3(vec3(2.3757, 2.0847, 1.8453), vec3(4.2655, 3.7153, 3.1365));
```

## 9. replaces Glimmer line 56 — in `getMetalN_K()`

```glsl
      return mat2x3(
```

## 10. replaces Glimmer line 61 — in `getMetalN_K()`

```glsl
  return mat2x3(0.0); // not a metal? zeros. congrats, you're plastic now
```

## 11. replaces Glimmer line 68 — in `getMetalN_K()`

```glsl
  mat2x3 N_K;
```

## 12. replaces Glimmer line 80 — in `getMetalN_K()`

```glsl
  mat2x3(0.0),
```

## 13. replaces Glimmer line 106 — in `materialFromSpecularMap()`

```glsl
  // green channel: under 229 = normal stuff, above = METAL. 229 is the magic cursed number
  int g = int(specularData.g * 255.0 + 0.5);
  if (g <= 229) {
```

## 14. replaces Glimmer line 111 — in `materialFromSpecularMap()`

```glsl
    material.metalID = g <= 237 ? uint(g - 229) : uint(OTHER_METAL);
```

## 15. replaces Glimmer lines 114-115 — in `materialFromSpecularMap()`

```glsl
  // blue channel is TWO things at once?? below 64 it's porosity, above it's subsurface. who designed this
  float b = specularData.b * 255.0;
  if (b < 64.5) {
    material.porosity = b / 64.0;
```

## 16. replaces Glimmer lines 118-119 — in `materialFromSpecularMap()`

```glsl
    material.porosity = 0.0;
    material.sss = (b - 65.0) / 190.0;
```

## 17. replaces Glimmer line 122 — in `materialFromSpecularMap()`

```glsl
  // alpha = glow, except 255 means NO glow. 255/254 makes it fine somehow. don't ask me
  material.emission = specularData.a < 1.0 ? specularData.a * (255.0 / 254.0) : 0.0;
```

