# Halcyon changes to Glimmer file `shaders/lib/lighting/brdf.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer lines 97-99 — in `fresnel()`

```glsl
    // https://naos-be.zcu.cz/server/api/core/bitstreams/c2d8b0a7-9947-4458-98e3-d3f8df920153/content
    // real metals have "complex IOR" which is two numbers n and k. imaginary numbers in my minecraft. wtf
    mat2x3 N_K = getMetalN_K(material.metalID);
    vec3 n = N_K[0];
    vec3 k = N_K[1];
```

## 2. replaces Glimmer line 141 — in `brdf()`

```glsl
  float NoV = max(dot(N, V), 1e-4);
```

## 3. replaces Glimmer lines 163-169 — in `brdf()`

```glsl
  // height-correlated smith visibility (Heitz 2014)
  // no idea what "height correlated" means but the paper had nice graphs so I trust it
  float a2 = pow2(alpha);
  float visL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
  float visV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
  float Vis = 0.5 / max(visL + visV, 1e-6);

  // F * D * Vis. the holy trinity. specular is born
  vec3 Rs = F * D * Vis * NoL;
```

## 4. replaces Glimmer lines 180-186 — in `brdf()`

```glsl
  float lightRadius = isDay ? sunAngularRadius : moonAngularRadius;
  // glue everything together and pray
  return (Rs * areaLightNormalization(max(0.001, material.roughness), dot(L, H), lightRadius) + Rd) *
    shadow +
```

