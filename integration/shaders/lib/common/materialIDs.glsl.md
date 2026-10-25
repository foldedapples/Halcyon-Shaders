# Halcyon changes to Glimmer file `shaders/lib/common/materialIDs.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 67 — in `sway()`

```glsl
    } else if (id == 1007 || id == 1008 || id == 1014 || id == 1016 || id == 1031) {
```

## 2. replaces Glimmer line 90 — in `isTorchLightColor()`

```glsl
    return id == 1013;
}


bool isLanternLightColor(int id) {
    return id == 1014 || id == 1032;
```

## 3. replaces Glimmer line 125 — in `isLetsLightThrough()`

```glsl
    return id == 1023 || id == 1024 || id == 1025 || id == 1026 || id == 1027 || id == 1028 || id == 1037;
}


bool isLightBlock(int id) {
    return id == 1037;
```

## 4. inserted after Glimmer line 131 — in `isNetherPortalLight()`

```glsl
bool isNetherPortalLight(int id) {
    return id == 1021;
}


bool isWarmYellowLight(int id) {
    return id == 1033;
}


bool isCyanWhiteLight(int id) {
    return id == 1034;
}


bool isPurpleLight(int id) {
    return id == 1035;
}


bool isOrangeLight(int id) {
    return id == 1036;
}


bool isCopperLightColor(int id) {
    return id == 1030 || id == 1031;
}


// why does obsidian need its own check. what is obsidian doing. I'm afraid to find out
bool isObsidian(int id) {
    return id == 1038;
}


bool isMetalBlock(int id) {
    return id == 1039;
}
```

