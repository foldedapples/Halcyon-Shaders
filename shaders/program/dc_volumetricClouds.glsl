/*
    Licensed under the MIT license, like the rest of Glimmer.
    (clouds. fucking clouds. I have spent more time on clouds than on my actual job)
*/

#include "/lib/common.glsl"

#ifdef vsh

// vertex shader, nothing to see, the fun stuff is downstairs
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ======== CLOUD HELL BEGINS BELOW ==============================================================

#ifdef fsh
in vec2 texcoord;

#include "/lib/atmosphere/clouds.glsl"
#include "/lib/atmosphere/cloudComposite.glsl"

/* RENDERTARGETS: 10,9 */
layout(location = 0) out vec4 cloudData;
layout(location = 1) out vec4 cloudAux;

// are we inside the cloud layer? false if volumetric clouds are off, because then there's no layer, because there's no clouds. deep stuff
bool vcInLayer(float y) {
  #ifdef VOLUMETRIC_CLOUDS
  vec2 layer = vcLayer();
  return y > layer.x && y < layer.y;
  #else
  return false;
  #endif
}

// main: raymarch the clouds at low res, then blend with last frame so it doesn't flicker like crazy
void main() {
  float sceneDist = cloudSceneDistance(texcoord);
  vec3 viewDir = normalize(screenSpaceToViewSpace(vec3(texcoord, 1.0)));
  vec3 worldDir = mat3(gbufferModelViewInverse) * viewDir;

  const float g = 1.6180339887498948482; // the golden ratio!!! with like 20 digits!!! the GPU only keeps 7 of them but it makes me feel smart
  ivec2 frameOffset = ivec2(fract(vec2(1.0 / g, 1.0 / (g * g)) * float(frameCounter) + 0.5) * 1024.0); // shifts the blue noise every frame in a golden-ratio pattern so it looks random but evenly spread. someone on discord explained this to me and I nodded
  float jitter = texelFetch(blueNoiseTex, (ivec2(gl_FragCoord.xy) + frameOffset) % 1024, 0).r;

  #ifdef VOLUMETRIC_CLOUDS
  // where does the view ray enter and exit the cloud slab. if it doesn't hit before the scene, pretend the scene is at sky distance
  vec2 slab = vcSlab(cameraPosition, worldDir, vcLayer());
  if (!(slab.y > slab.x && slab.x < sceneDist)) sceneDist = CLOUD_SKY_DISTANCE;
  #endif

  vec3 transmittance = vec3(1.0);
  vec3 scatter = vec3(0.0);
  float cloudDepth = -1.0;
  #if defined CLOUDS && defined VOLUMETRIC_CLOUDS
  // the big boy. actually marches through the clouds. 1e9 = "infinity" because a real infinity would explode
  scatter = getVolumetricClouds(
    vec3(0.0), worldDir, VC_STEPS_Q, jitter,
    sceneDist >= CLOUD_SKY_DISTANCE ? 1e9 : sceneDist,
    transmittance, cloudDepth
  );
  #endif
  vec4 current = vec4(scatter, transmittance.r);
  if (any(isnan(current)) || any(isinf(current))) current = vec4(0.0, 0.0, 0.0, 1.0); // NaN or inf? reset to "no cloud". clouds love making NaNs, it's their hobby
  cloudAux = vec4(sceneDist, 0.0, 0.0, 1.0);

  // reproject to last frame. 20000 is a random far distance for when we didn't hit any cloud. reprojection makes me want to lie down
  float reprojectDist = cloudDepth > 0.0 ? cloudDepth : min(sceneDist, 20000.0);
  vec3 playerPos = worldDir * reprojectDist;
  vec3 cameraMove = cameraPosition - previousCameraPosition;
  vec3 prevView = (gbufferPreviousModelView * vec4(playerPos + cameraMove, 1.0)).xyz;
  float weight = 0.0;
  vec4 history = current;
  if (prevView.z < 0.0) {
    vec4 prevClip = gbufferPreviousProjection * vec4(prevView, 1.0);
    vec2 prevUV = prevClip.xy / prevClip.w * 0.5 + 0.5;
    if (clamp01(prevUV) == prevUV) {
      // manual bilinear filtering of the history, 4 taps, each weighted by whether the old depth matches. couldn't use texture() cuz it blends across edges and makes ghosts
      vec2 size = vec2(textureSize(colortex10, 0));
      vec2 p = prevUV * size - 0.5;
      ivec2 base = ivec2(floor(p));
      vec2 f = p - vec2(base);
      vec4 sum = vec4(0.0);
      float wsum = 0.0;
      for (int i = 0; i < 4; i++) {
        ivec2 o = ivec2(i & 1, i >> 1); // i & 1, i >> 1 = the 4 corners. bit tricks make me feel like a hacker
        ivec2 q = clamp(base + o, ivec2(0), ivec2(size) - 1);
        float bw = (o.x == 1 ? f.x : 1.0 - f.x) * (o.y == 1 ? f.y : 1.0 - f.y);
        float prevDist = texelFetch(colortex9, q, 0).r;
        float w = bw * cloudDistanceWeight(prevDist, sceneDist);
        sum += texelFetch(colortex10, q, 0) * w;
        wsum += w;
      }
      if (wsum > 0.05) {
        history = sum / wsum;
        weight = 0.88 * smoothstep(0.05, 0.4, wsum); // 0.88 max history. higher = smooth but smeary, lower = flickery. 0.88 is the least bad
      }
    }
  }
  float moved = length(cameraMove);
  if (moved > 64.0) weight = 0.0; // teleported more than 64 blocks? nuke the history
  if (vcInLayer(cameraPosition.y) != vcInLayer(previousCameraPosition.y)) weight *= 0.3; // entering or leaving the cloud layer changes everything so trust the old frame less
  float nearest = cloudDepth > 0.0 ? cloudDepth : 1e4;
  weight /= 1.0 + 25.0 * moved / max(nearest, 4.0); // moving fast near clouds = less history. 25.0 is pure trial and error, mostly error
  if (any(isnan(history)) || any(isinf(history))) {
    weight = 0.0;
    history = current;
  }

  float change = abs(current.a - history.a);
  weight *= mix(1.0, 0.65, smoothstep(0.5, 0.9, change)); // big change in transmittance = probably wrong history, back off a bit
  if (lightningBoltPosition.w > 0.5) weight = min(weight, 0.3); // lightning flash! don't let history drag the flash out

  cloudData = mix(current, history, weight); // blend the new with the old. temporal accumulation baby
}

#endif
