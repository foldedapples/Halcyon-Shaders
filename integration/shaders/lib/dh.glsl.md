# Halcyon changes to Glimmer file `shaders/lib/dh.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 43 — in `dhOverrideAt()`

```glsl
// same thing but you pick the uv, and it's crammed into 6 lines because I got tired of typing
bool dhOverrideAt(vec2 uv, inout float depth, inout vec3 viewPos, bool opaque) {
  if (depth != 1.0) return false;
  depth = opaque ? texture(dhDepthTex1, uv).r : texture(dhDepthTex0, uv).r;
  if (depth == 1.0) return false;
  vec4 homPos = dhProjectionInverse * vec4(vec3(uv, depth) * 2.0 - 1.0, 1.0);
  viewPos = homPos.xyz / homPos.w;
  return true;
}
```

## 2. inserted after Glimmer line 49 — in `dhOverrideAt()`

```glsl
bool dhOverrideAt(vec2 uv, inout float depth, inout vec3 viewPos, bool opaque) {
  return false;
}
```

