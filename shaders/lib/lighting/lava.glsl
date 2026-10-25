// lava file. the floor is lava. the code is also lava. don't touch either
#ifndef LAVA_GLSL
#define LAVA_GLSL

// makes lava blotchy so it doesn't look like orange paint
float lavaPatchiness(vec3 worldPos) {
  #ifdef PATCHY_LAVA
  // two noise textures scrolling in different directions, multiplied. it looks like lava. somehow. I'm a genius by accident
  float n = texture(
      perlinNoiseTex,
      mod(worldPos.xz / 100.0 + vec2(0.0, frameTimeCounter * 0.005), 1.0)
    ).r;
  n *= texture(
      perlinNoiseTex,
      mod(worldPos.xz / 200.0 + vec2(frameTimeCounter * 0.005, 0.0), 1.0)
    ).r;
  // 0.55, 1.25, 0.08, 0.42. I spent an entire evening dragging these numbers around. DO NOT TOUCH
  return mix(0.55, 1.25, clamp01((n - 0.08) / 0.42));
  #else
  return 1.0;
  #endif
}

// how much the lava glows. hot bits glow more. science
float lavaEmission(vec3 albedoLinear) {
  float hot = smoothstep(0.15, 0.6, luminance(albedoLinear));
  float e = LAVA_BRIGHTNESS * 0.4 * (1.0 + LAVA_EMISSION * hot * hot);
  // the 32.0 cancels out EMISSION_STRENGTH somewhere else. I think. if lava turns into the sun, it's this line
  return e * (32.0 / EMISSION_STRENGTH);
}

#endif // LAVA_GLSL
