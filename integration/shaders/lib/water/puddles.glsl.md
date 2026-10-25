# Halcyon changes to Glimmer file `shaders/lib/water/puddles.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. inserted after Glimmer line 2

```glsl
#include "/lib/water/rainRipples.glsl"

// how much water a block soaks up if the resource pack doesn't tell us. 0.45, felt spongy enough
#define DEFAULT_POROSITY 0.45
```

## 2. replaces Glimmer line 6 — in `overlayBlend()`

```glsl
    ? 2.0 * a * b
    : 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
```

## 3. replaces Glimmer line 9 — in `puddleNoise()`

```glsl
// two noise textures smushed together so the puddles don't look like a repeating grid. 96 and 23 are random, don't read into it
float puddleNoise(vec2 worldXZ) {
  float n = texture(perlinNoiseTex, fract(worldXZ / 96.0)).r;
  n = n * 0.7 + texture(perlinNoiseTex, fract(worldXZ / 23.0 + 0.37)).r * 0.3;
  // times 5 makes the noise way more contrasty so puddles have actual edges instead of being gray fog
  return clamp01((n - 0.5) * 5.0 + 0.5);
}

// the big wetness function. turns everything shiny and dark when it rains. returns how puddle-y the spot is
float applyWetness(
```

## 4. replaces Glimmer line 15 — in `applyWetness()`

```glsl
  float skyLightmap,
  float viewDistance,
  bool foliage
```

## 5. replaces Glimmer lines 17-33 — in `applyWetness()`

```glsl
  #ifndef WETNESS
  return 0.0;
  #else
  // only get wet where the sky can see you. 13.5/15 and 14.5/15 are lightmap levels, I found them by standing under a tree
  float rainArea = smoothstep(13.5 / 15.0, 14.5 / 15.0, skyLightmap);
  if (rainArea <= 0.0 || surfaceWetness <= 1e-3) return 0.0;
  // the "up" vector in view space. stole it out of the model view matrix like a little goblin
  vec3 upView = gbufferModelView[1].xyz;
  float upness = dot(geometryNormal, upView);
  // ceilings don't get wet. revolutionary
  if (upness < -0.5) return 0.0;

  float porosity = material.porosity;
  // empty ifdef lol. if it's labPBR we use the real porosity, otherwise the fake one. yes the empty branch is on purpose. I think
  #ifdef MC_TEXTURE_FORMAT_LAB_PBR
  #else
  porosity = DEFAULT_POROSITY;
  #endif
  // leaves are half as soaky. I don't know if that's true about leaves
  if (foliage) porosity *= 0.5;
  // metal doesn't absorb water. this is the one physics fact I'm 100% sure about
  if (material.metalID != NO_METAL) porosity = 0.0;

  float wet = surfaceWetness * rainArea * mix(0.55, 1.0, clamp01(upness));
  wet *= WETNESS_STRENGTH;
  wet = clamp01(wet);

  // wet stuff gets darker, roughly albedo squared. some smart guy figured this out (Lagarde 2013, "Water drop 2b"), I just copied it
  vec3 wetAlbedo = material.albedo * mix(vec3(1.0), material.albedo, 0.5) * 0.85;
  material.albedo = mix(material.albedo, wetAlbedo, wet * porosity);
  // wet = shinier. smaller roughness = shinier. took me an embarrassingly long time to learn that
  float filmRoughness = material.roughness * mix(0.25, 0.6, porosity);
  if (foliage) filmRoughness = material.roughness * 0.75;
  material.roughness = mix(material.roughness, filmRoughness, wet);

  // puddle time baby
  float puddle = 0.0;

  #ifdef RAIN_PUDDLES
  // only flat ground gets puddles, otherwise water would be sticking to walls like a cartoon
  if (upness > 0.9 && !foliage) {
    float flatness = smoothstep(0.9, 0.98, upness);
    float n = puddleNoise(worldPos.xz);
    // mixing noise with the heightmap so puddles collect in the low cracks. this felt so smart when I wrote it
    float h = mix(n, n * 0.6 + (1.0 - heightMap) * 0.8, 0.5);
    // more rain = lower threshold = bigger puddles. math!
    float threshold = mix(0.8, 0.5, puddleAmount * PUDDLE_SIZE);
    puddle = smoothstep(threshold, threshold + 0.12, h) * flatness * rainArea;
    puddle *= mix(1.0, 0.6, porosity);
    // times 1.4 then clamp because the puddles were too shy
    puddle = clamp01(puddle * 1.4);

    if (puddle > 0.0) {
      // puddles are basically mirrors. roughness zero. go wild
      material.roughness = mix(material.roughness, 0.0, puddle);
      // if it's metal, kill the metal and pretend it's water now. this was a nightmare to debug, the gold blocks were glowing
      if (material.metalID != NO_METAL) {
        material.f0 = mix(material.albedo, vec3(0.02), puddle);
        material.albedo *= puddle * 0.6;
        material.metalID = NO_METAL;
      } else {
        material.albedo *= mix(1.0, 0.6, puddle);
        // 0.02 is how reflective water is head-on. every tutorial says 0.02 so I said 0.02
        material.f0 = mix(material.f0, vec3(0.02), puddle);
```

## 6. replaces Glimmer lines 37-44 — in `applyWetness()`

```glsl
      material.porosity = 0.0;

      // rain ripples on top of the puddle!! I'm so proud of this one
      vec2 ripple = rainRippleSlope(
        worldPos.xz,
        rainRippleIntensity(skyLightmap),
        viewDistance
      );
      // turn the ripple slope into a normal. the minus signs are there because without them the ripples went the wrong way and it looked cursed
      vec3 rippleNormal =
        mat3(gbufferModelView) * normalize(vec3(-ripple.x, 1.0, -ripple.y));
      mappedNormal = normalize(mix(mappedNormal, rippleNormal, puddle));
    }
```

## 7. inserted after Glimmer line 47 — in `applyWetness()`

```glsl
  return puddle;
  #endif
}

#endif // PUDDLES_GLSL, goodbye forever
```

