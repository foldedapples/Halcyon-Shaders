/*
    Licensed under the MIT license, like the rest of Glimmer.
    (yes I'm still using this license, no I don't know what it means)
    temporal pass: blend the noisy GI with last frame so it stops looking like a TV with no signal
*/

#include "/lib/common.glsl"

#ifdef vsh

// vertex shader. same as always. I could write this one in my sleep. I probably have
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ======== the part where we time travel to the previous frame ===================================

#ifdef fsh
in vec2 texcoord;

/* RENDERTARGETS: 13,14 */
layout(location = 0) out vec4 history;
layout(location = 1) out vec4 historyInfo;

void main() {
  // start with this frame's raw GI. if anything fails below, we just use this and it looks like sand
  vec4 current = texture(colortex12, texcoord);
  history = current;
  historyInfo = vec4(0.0);

  #ifdef SSGI
  float depth = texture(depthtex0, texcoord).r;
  if (depth >= 1.0) return;
  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  float linearZ = -viewPos.z; // positive distance, because view space z is negative for some godforsaken reason

  // reprojection: figure out where this pixel was on screen LAST frame. player space, undo the camera movement, back through last frame's matrices. my brain hurts
  vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  playerPos += cameraPosition - previousCameraPosition;
  vec3 prevView = (gbufferPreviousModelView * vec4(playerPos, 1.0)).xyz;
  vec4 prevClip = gbufferPreviousProjection * vec4(prevView, 1.0);
  vec2 prevUV = prevClip.xy / prevClip.w * 0.5 + 0.5;

  float frames = 0.0;
  if (clamp01(prevUV) == prevUV) { // still on screen last frame? cool. otherwise no history, enjoy the noise
    vec4 prevInfo = texture(colortex14, prevUV);
    float expectedZ = -prevView.z;
    if (abs(prevInfo.r - expectedZ) < max(0.05, expectedZ * 0.03)) { // depth check so we don't smear GI across edges. 0.05 or 3% of distance, whichever's bigger. tweaked this like 30 times
      frames = min(prevInfo.g + 1.0, float(SSGI_ACCUMULATION)); // count frames up to the max so it doesn't average forever and lag behind
      vec4 prev = texture(colortex13, prevUV);
      if (!(any(isnan(prev)) || any(isinf(prev)))) { // NaN check. a NaN got in here once and turned the whole screen black. never again
        history = mix(prev, current, 1.0 / (frames + 1.0)); // running average. 1/(frames+1) is how you average without storing everything, I think. it works so it's right
      }
    }
  }
  historyInfo = vec4(linearZ, frames, 0.0, 1.0); // save depth + frame count for next frame's me to deal with
  #endif
}

#endif
