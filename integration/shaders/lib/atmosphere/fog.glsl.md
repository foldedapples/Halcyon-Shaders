# Halcyon changes to Glimmer file `shaders/lib/atmosphere/fog.glsl`

Only the Halcyon code is here; the Glimmer code around it was removed. Line numbers refer to
Glimmer at commit `6a59109` (github.com/jbritain/glimmer-shaders), so each change can be placed
back into that file, or recreated in a different base pipeline.

## 1. replaces Glimmer line 31 — in `atmosphericFog()`

```glsl
#define HEIGHT_FOG_TOP_HEIGHT mix(100, 260, wetness)
```

## 2. replaces Glimmer lines 56-57 — in `cloudyFog()`

```glsl
  // stack more fog on for rain and thunder. thunder gets 0.6 because thunderstorms should feel like the end of the world
  fogFactor += wetness * 0.12 * biomeCanPrecipitateSmooth;
  fogFactor += thunderStrength * 0.6;
```

## 3. inserted after Glimmer line 135 — in `cloudyFog()`

```glsl
  // keep fog off stuff right in front of your face (8 to 110 blocks) unless it's storming. this line is 200 characters long. I'm not wrapping it. fight me
  float nearRamp = mix(smoothstep(8.0, 110.0, length(playerPos)), 1.0, clamp01((wetness + thunderStrength) * biomeCanPrecipitateSmooth + (fogFactor - BASE_FOG_DENSITY)));
  opticalDepth *= depth >= 1.0 ? 1.0 : nearRamp;
```

## 4. replaces Glimmer line 154 — in `defaultFog()`

```glsl
  #if defined WORLD_OVERWORLD || defined WORLD_THE_NETHER
```

## 5. inserted after Glimmer line 182 — in `defaultFog()`

```glsl
#ifdef WORLD_THE_END
// purple End haze. the sky gets skipped (depth 1.0) because the black hole has enough going on already
vec3 endFog(vec3 color, vec3 viewPos, float depth) {
  if (depth >= 1.0) return color;
  vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
  float dist = length(playerPos);
  float sigma = 0.0009 * END_FOG_DENSITY;
  float T = exp(-sigma * max(dist - 32.0, 0.0)); // first 32 blocks are fog-free so you can still see the endermen coming to steal your blocks
  float phase = henyeyGreenstein(0.55, dot(playerPos / max(dist, 1e-4), worldLightDir));
  vec3 tint = mix(vec3(0.5), vec3(0.46, 0.42, 0.62), END_FOG_TINT);
  tint /= luminance(tint);
  // 0.00008 and 0.0008. one has 3 zeros and one has 4. I added zeros until the End stopped looking like a milk bath
  vec3 haze = tint * 0.00008 * END_AMBIENT * COSMIC_SKY_BRIGHTNESS + sunlightColor * phase * 0.0008;
  return color * T + haze * (1.0 - T);
}
```

## 6. inserted after Glimmer line 184 — in `endFog()`

```glsl
// ---- NETHER ZONE. hot. smoky. full of ghasts screaming at me while I debug ----
#if defined WORLD_THE_NETHER && !defined GBUFFERS_VOXY
// grabs block light from the floodfill voxel thing so the fog glows near lava and glowstone
vec3 netherBlocklight(vec3 playerPos) {
  #ifdef FLOODFILL
  vec3 p = (playerPos + cameraPositionFract + VOXEL_MAP_SIZE / 2) / VOXEL_MAP_SIZE;
  if (clamp01(p) != p) return vec3(0.0);
  // two voxel textures that swap every frame (ping pong). if you read the wrong one it flickers like a haunted house
  return frameCounter % 2 == 0
    ? texture(floodfillVoxelMapTex2, p).rgb
    : texture(floodfillVoxelMapTex1, p).rgb;
  #else
  return vec3(0.0);
  #endif
}

// rising smoke noise. it goes UP because hot air rises. see, I paid attention in school (that one day)
float netherSmoke(vec3 worldPos) {
  float t = frameTimeCounter;
  vec3 p = worldPos;
  p.y -= t * 0.9; // minus means the noise slides down so the smoke looks like it goes up. I flipped this sign 4 times
  vec2 swirl = texture(perlinNoiseTex, fract(worldPos.xz / 300.0 + t * 0.002)).rg - 0.5;
  p.xz += swirl * 30.0;
  // 72 and 23 block noise scales. 0.65 + 0.35 = 1. I'm getting better at this. slightly
  float n =
    texture(cloudNoiseTex, fract(p / 72.0)).r * 0.65 +
    texture(cloudNoiseTex, fract(p / 23.0 + 0.31)).g * 0.35;
  float sheets = 0.6 + 0.4 * sin(worldPos.y * 0.18 + n * 4.0); // horizontal layers of smoke. looks like a sad lasagna. a sad hot lasagna
  return smoothstep(0.42, 0.8, n) * sheets;
}

const vec3 lavaGlowColor = vec3(1.0, 0.35, 0.08); // lava orange. I literally color picked a screenshot of lava

// the whole nether air: raymarched smoke near you, cheap flat fog for everything past 128 blocks. two-tier fog. premium and economy class
vec3 netherAtmosphere(vec3 color, vec3 viewPos, float depth) {
  vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
  float len = length(playerPos);
  vec3 dir = playerPos / max(len, 1e-4);
  float dist = depth >= 1.0 ? max(far, 64.0) : len;

  float sigma = 3.0 / float(NETHER_VISIBILITY); // 3 / distance because exp(-3) is about 5% left. that's "can't see shit" territory
  // use the biome's fog color but desaturate it. tint > 1 goes full color. crimson forest goes RED red
  vec3 biome = pow(fogColor, vec3(2.2));
  vec3 fogBase = mix(vec3(luminance(biome)), biome, clamp01(NETHER_FOG_TINT * 0.8)) * 0.01;
  if (NETHER_FOG_TINT > 1.0) fogBase = mix(fogBase, biome * 0.01, NETHER_FOG_TINT - 1.0);

  float T = 1.0;
  vec3 scatter = vec3(0.0);
  float marchLen = 0.0;

  // the raymarch. step through the smoke, add light, lose light. repeat until GPU begs for mercy
  #ifdef NETHER_SMOKE
  marchLen = min(dist, 128.0);
  float stepLen = marchLen / float(NETHER_SMOKE_QUALITY);
  float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
  for (int i = 0; i < NETHER_SMOKE_QUALITY; i++) {
    vec3 p = dir * ((float(i) + jitter) * stepLen);
    vec3 wp = p + cameraPosition;
    float smoke = netherSmoke(wp) * NETHER_SMOKE_DENSITY;
    float sig = sigma * (0.6 + 2.4 * smoke);
    // glow from nearby blocks plus a lava glow layer centered at y=31, which is nether lava sea level. I had to look that up on the wiki
    vec3 glow =
      netherBlocklight(p) * 0.001 * BLOCKLIGHT_STRENGTH +
      lavaGlowColor * 0.0025 * exp(-abs(wp.y - 31.0) / 14.0);
    vec3 light = fogBase * (1.0 - 0.5 * smoke) + glow * NETHER_LAVA_GLOW * (0.6 + 0.8 * smoke);
    float stepT = exp(-sig * stepLen);
    scatter += T * light * (1.0 - stepT);
    T *= stepT;
  }
  #endif

  // everything past the march gets the economy fog. one exp() and done. cheap and cheerful
  float rest = max(dist - marchLen, 0.0);
  float restT = exp(-sigma * rest);
  scatter += T * (fogBase + lavaGlowColor * 0.0008 * NETHER_LAVA_GLOW) * (1.0 - restT);
  T *= restT;

  return color * T + scatter;
}
#endif

#endif
```

