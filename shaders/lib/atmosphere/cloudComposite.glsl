#ifndef CLOUD_COMPOSITE_GLSL
#define CLOUD_COMPOSITE_GLSL

/*
    ok so the clouds get rendered at potato resolution because my GPU was crying,
    and then every full-res pixel looks at the 4 closest cloud pixels and goes
    "which of you losers matches my depth best" and blends them. it works. i think
*/

// 65 km. that's where the sky lives now. I measured it with noodles
#define CLOUD_SKY_DISTANCE 65000.0

// figures out how far away the thing behind this pixel is. terrain, DH terrain, or "the sky lol"
float cloudSceneDistance(vec2 uv) {
  ivec2 px = clamp(ivec2(uv * vec2(viewWidth, viewHeight)), ivec2(0), ivec2(viewWidth, viewHeight) - 1);
  float depth = texelFetch(depthtex0, px, 0).r;
  vec2 centre = (vec2(px) + 0.5) / vec2(viewWidth, viewHeight); // +0.5 because pixel centers are a thing apparently. took me a whole day to learn that
  if (depth < 1.0) {
    return min(length(screenSpaceToViewSpace(vec3(centre, depth))), CLOUD_SKY_DISTANCE - 1.0);
  }
  // distant horizons has its OWN depth buffer because of course it fucking does
  #if defined DISTANT_HORIZONS || defined VOXY
  float dhDepth = texelFetch(dhDepthTex0, px, 0).r;
  if (dhDepth < 1.0) {
    vec4 hom = dhProjectionInverse * vec4(vec3(centre, dhDepth) * 2.0 - 1.0, 1.0); // the *2-1 thing. I copy paste this everywhere and pray
    return min(length(hom.xyz / hom.w), CLOUD_SKY_DISTANCE - 1.0);
  }
  #endif
  return CLOUD_SKY_DISTANCE; // nothing hit, it's sky, go home
}

// how similar are two distances. 12.0 is the "how picky" knob, I turned it until the halos around trees went away
float cloudDistanceWeight(float a, float b) {
  float rel = abs(a - b) / max(min(a, b), 1.0);
  return exp(-rel * 12.0);
}

// the actual upsampler. bilinear filtering but with trust issues
vec4 sampleCloudsUpsampled(vec2 uv, float sceneDist) {
  vec2 size = vec2(textureSize(colortex10, 0));
  vec2 p = uv * size - 0.5;
  ivec2 base = ivec2(floor(p));
  vec2 f = p - vec2(base);
  vec4 sum = vec4(0.0);
  float wsum = 0.0;
  vec4 best = vec4(0.0, 0.0, 0.0, 1.0);
  float bestW = -1.0;
  // loop over the 4 neighbors. i & 1 and i >> 1 is bit wizard shit that turns 0123 into corners, some stackoverflow guy said to do this
  for (int i = 0; i < 4; i++) {
    ivec2 o = ivec2(i & 1, i >> 1);
    ivec2 q = clamp(base + o, ivec2(0), ivec2(size) - 1);
    float bw = (o.x == 1 ? f.x : 1.0 - f.x) * (o.y == 1 ? f.y : 1.0 - f.y); // hand-rolled bilinear weight because I'm a masochist
    float dw = cloudDistanceWeight(texelFetch(colortex9, q, 0).r, sceneDist);
    vec4 c = texelFetch(colortex10, q, 0);
    float w = bw * dw;
    sum += c * w;
    wsum += w;
    // keep track of the least-wrong neighbor in case everyone sucks
    if (dw > bestW) {
      bestW = dw;
      best = c;
    }
  }
  return wsum > 1e-3 ? sum / wsum : best; // if all weights are ~zero just take the best one instead of dividing by zero and summoning NaN demons
}

#endif // CLOUD_COMPOSITE_GLSL
