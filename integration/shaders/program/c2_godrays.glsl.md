# Halcyon changes to Glimmer file `shaders/program/c2_godrays.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 113 — in `main()`

```glsl
  // cloud shadow along the whole ray, sampled once at the halfway point. pow3 to make it more dramatic. cheating but whatever
  vec3 rayCloudShadow = vec3(1.0);
  #ifdef CLOUD_SHADOWS
  rayCloudShadow = pow3(getCloudShadow(feetPlayerPos * 0.5));
  #endif

  float marched = 0.0;
```

## 2. replaces Glimmer lines 122-126 — in `main()`

```glsl
    marched += length(sampleDelta);

    vec3 cloudShadow = rayCloudShadow;
```

## 3. replaces Glimmer line 139 — in `main()`

```glsl
  // divide by how far we actually went. if we didn't go anywhere, just use the cloud shadow. 1e-3 because zero is my enemy
  scattering = marched > 1e-3 ? scattering / marched : rayCloudShadow;
```

