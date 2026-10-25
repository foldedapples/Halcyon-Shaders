/*
    Licensed under the MIT license, like the rest of Glimmer.
    (depth of field. makes the background blurry like you're filming a sad indie movie)
*/

#include "/lib/common.glsl"

// vertex shader, copy number 9000
#ifdef vsh

out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ==================================== blur zone below ====================================

#ifdef fsh
in vec2 texcoord;

// iris gives us the depth at the center of the screen, smoothed. halflife 1.0 means it takes about a second to refocus. like my eyes in the morning
uniform float centerDepthSmooth;
const float centerDepthHalflife = 1.0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

// turn the weird nonlinear depth buffer value into actual blocks. 1e5 for sky because the sky is infinitely far and also I needed a number
float linearDepth(float depth) {
  if (depth >= 1.0) return 1e5;
  return -screenSpaceToViewSpace(vec3(0.5, 0.5, depth)).z;
}

// circle of confusion. that's the real name, I didn't make it up. it's how blurry a pixel should be. my whole life is a circle of confusion
float circleOfConfusion(float depth) {
  // hand never gets blurred, you'd get motion sick
  if (depth < MC_HAND_DEPTH * 0.5 + 0.5) return 0.0;
  float z = linearDepth(depth);
  // autofocus = focus on whatever's in the middle of the screen. otherwise use the slider
  #ifdef DOF_AUTOFOCUS
  float focus = linearDepth(centerDepthSmooth);
  #else
  float focus = DOF_FOCUS_DISTANCE;
  #endif
  // clamp focus between 0.3 and 256 blocks. focusing on 0 blocks divides by zero and I don't want to talk about it
  focus = clamp(focus, 0.3, 256.0);
  // the thin lens formula, mangled beyond recognition. 16.0 and 0.006 are fudge numbers I typed until it looked like a real camera. negative = in front of focus
  float coc = (1.0 / focus - 1.0 / z) * 16.0 * DOF_APERTURE * viewHeight * 0.006;
  return clamp(coc, -DOF_MAX_RADIUS, DOF_MAX_RADIUS);
}

void main() {
  color = texture(colortex0, texcoord);

  #ifdef DOF
  float centerCoC = circleOfConfusion(texture(depthtex0, texcoord).r);
  float radius = abs(centerCoC);

  // always search at least 35% of the max radius, so blurry foreground stuff can bleed over sharp pixels. otherwise you get crispy edges around blurry things, gross
  float searchRadius = max(radius, DOF_MAX_RADIUS * 0.35);
  vec2 pixel = 1.0 / vec2(viewWidth, viewHeight);
  float noise = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);

  // start with the center pixel at weight 1. no divide-by-zero today, satan
  vec3 sum = color.rgb;
  float weightSum = 1.0;
  for (int i = 0; i < DOF_SAMPLES; i++) {
    // vogel disc = sunflower seed pattern. the golden angle again. that number is everywhere, it's like a cult
    vec2 offset = vogelDiscSample(i, DOF_SAMPLES, noise) * searchRadius;
    vec2 uv = texcoord + offset * pixel;
    float sampleCoC = circleOfConfusion(texture(depthtex0, uv).r);
    float dist = length(offset);
    // foreground (negative CoC) samples spread by their own size, background ones get capped so they don't bleed over the focused stuff. this took forever to stop looking like vaseline on the lens
    float reach =
      sampleCoC < centerCoC ? abs(sampleCoC) : min(abs(sampleCoC), radius);
    // how much this sample actually reaches us. +1 so the edge is soft-ish. it's a disc, it covers us or it doesn't
    float w = clamp01(reach - dist + 1.0);
    sum += texture(colortex0, uv).rgb * w;
    weightSum += w;
  }
  color.rgb = sum / weightSum;
  #endif
}

#endif
