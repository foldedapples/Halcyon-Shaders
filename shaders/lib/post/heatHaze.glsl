// wobbly hot air in the nether. makes the screen look like a mirage. or like I'm about to pass out (accurate)
#ifndef HEAT_HAZE_GLSL
#define HEAT_HAZE_GLSL

#ifdef WORLD_THE_NETHER
#include "/lib/voxel/voxelMap.glsl"

vec2 heatHazeOffset(vec2 uv) {
  #ifdef HEAT_HAZE
  // 0.56 depth cutoff stops your hand from wobbling. your hand is not hot. probably
  float depth = texture(depthtex0, uv).r;
  if (depth >= 1.0 || depth < 0.56) return vec2(0.0);
  vec3 viewPos = screenSpaceToViewSpace(vec3(uv, depth));
  vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  float dist = length(playerPos);
  vec3 worldPos = playerPos + cameraPosition;

  float heat = 0.0;
  #ifdef FLOODFILL
  // peek at the floodfill light voxels. if the light is red-ish, it's probably lava or fire, so it's hot. galaxy brain
  vec3 vp = mapVoxelPosInterp(playerPos + vec3(0.0, 1.0, 0.0));
  if (clamp01(vp) == vp) {
    vec3 bl = frameCounter % 2 == 0
      ? texture(floodfillVoxelMapTex2, vp).rgb
      : texture(floodfillVoxelMapTex1, vp).rgb;
    float warm = max(bl.r - max(bl.g, bl.b) * 0.8, 0.0);
    heat = clamp01(warm * 0.15);
  }
  #endif
  // y = 31 is nether lava ocean level. hardcoded. if mojang changes it I'm fucked
  heat = max(heat, exp(-abs(worldPos.y - 31.0) / 6.0) * 0.8);
  if (heat < 0.01) return vec2(0.0);

  // noise that scrolls upward at 1.6 speed because hot air rises. I paid attention in ONE science class
  float t = frameTimeCounter;
  vec3 q = vec3(worldPos.x, worldPos.y - t * 1.6, worldPos.z) / 5.0;
  vec2 n = texture(cloudNoiseTex, fract(q)).rg - 0.5;
  float px = 3.0 / viewHeight;
  // this strength line is the length of a CVS receipt. fades with distance, dies completely past 128 blocks
  float strength = heat * HEAT_HAZE_STRENGTH * px * clamp(8.0 / max(dist, 1.0), 0.15, 1.0) * (1.0 - smoothstep(64.0, 128.0, dist));
  return n * 2.0 * strength * vec2(1.0 / aspectRatio, 1.0);
  #else
  return vec2(0.0);
  #endif
}
#endif

#endif // HEAT_HAZE_GLSL
