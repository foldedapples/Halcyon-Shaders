# Halcyon changes to Glimmer file `shaders/program/voxy.json`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 48

```json
    "nightVision",
    "moonPhase",
    "rainStrength",
    "humiditySmooth",
    "oceanBiomeSmooth",
    "riverBiomeSmooth"
```

## 2. replaces Glimmer line 62

```json
    "colortex7": "sampler2D",
    "moonTex": "sampler2D",
    "cloudNoiseTex": "sampler3D",
    "colortex15": "sampler2D"
```

