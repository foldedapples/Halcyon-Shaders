# Halcyon changes to Glimmer file `shaders/lib/voxel/voxelData.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 15 — in `encodeVoxelData()`

```glsl
    uint(clamp01(data.emission) * 15.0 + 0.5),
```

