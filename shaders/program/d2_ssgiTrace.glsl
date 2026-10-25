/*
    Licensed under the MIT license, like the rest of Glimmer.
    (glimmer? halcyon? I've renamed this project so many times I forgot what it's called)
    SSGI = "screen space global illumination" = light bouncing off shit. took me a WEEK. a WEEK.
*/

#include "/lib/common.glsl"

#ifdef vsh

// vertex shader #47 that does the exact same thing as the other 46
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ======== vertex nonsense done, here comes the ray tracing (fake ray tracing, don't tell anyone) ===

#ifdef fsh
in vec2 texcoord;

#include "/lib/util/packing.glsl"
#include "/lib/util/ggx.glsl"

/* RENDERTARGETS: 12 */
layout(location = 0) out vec4 giOut;

// hand depth remapped from -1..1 to 0..1 so we can skip your own hand. nobody needs light bouncing off steve's sausage fingers
const float handDepthGI = MC_HAND_DEPTH * 0.5 + 0.5;

// march a ray across the screen and pray it hits something. returns (uv, 1) on hit, zeros if it missed like my aim in bedwars
vec3 traceGIRay(vec3 origin, vec3 dir, float jitter) {
  float rayLength = SSGI_RADIUS;
  // if the ray would go BEHIND the camera, chop it short. the 0.99 is there because 1.0 did something cursed
  if (origin.z + dir.z * rayLength > -near) {
    rayLength = (-near - origin.z) / dir.z * 0.99;
  }
  vec3 endPos = origin + dir * rayLength;
  vec3 s0 = viewSpaceToScreenSpace(origin);
  vec3 s1 = viewSpaceToScreenSpace(endPos);
  // 1/z because depth isn't linear on screen and you have to interpolate the reciprocal. I read this in a paper. I did not read the rest of the paper
  float iz0 = 1.0 / origin.z;
  float iz1 = 1.0 / endPos.z;

  for (int i = 0; i < SSGI_STEPS; i++) {
    float t = (float(i) + jitter) / float(SSGI_STEPS);
    t *= t; // squaring t = small steps up close, big steps far away. stolen trick, works great
    vec2 uv = mix(s0.xy, s1.xy, t);
    if (clamp01(uv) != uv) return vec3(0.0); // ray left the screen, give up, go home
    float rayZ = 1.0 / mix(iz0, iz1, t);
    float sceneDepth = texelFetch(depthtex0, ivec2(uv * vec2(viewWidth, viewHeight)), 0).r;
    if (sceneDepth >= 1.0) continue;
    float sceneZ = screenSpaceToViewSpace(sceneDepth);
    float behind = sceneZ - rayZ;
    float thickness = 0.35 + abs(rayZ) * 0.02; // how thick we pretend every surface is. 0.35 + a bit more with distance. pulled these numbers straight out of my ass and they look fine
    if (behind > 0.0 && behind < thickness && sceneDepth > handDepthGI) {
      return vec3(uv, 1.0);
    }
  }
  return vec3(0.0);
}

// main: shoot SSGI_RAYS random rays out of every pixel. yes every pixel. yes it's slow. that's why it's off by default
void main() {
  giOut = vec4(0.0, 0.0, 0.0, 1.0);

  #ifdef SSGI
  float depth = texture(depthtex0, texcoord).r;
  if (depth >= 1.0 || depth < handDepthGI) return; // skip sky and skip the hand. sky doesn't bounce, hand is cursed
  if (texture(colortex11, texcoord).a <= 0.0) return; // alpha 0 in colortex11 means "don't GI this". no idea who writes that, some other pass, it's fine

  vec3 viewPos = screenSpaceToViewSpace(vec3(texcoord, depth));
  vec3 normal = mat3(gbufferModelView) * decodeNormal(texture(colortex1, texcoord).xy);
  mat3 basis = basisFromNormal(normal);

  vec3 radianceSum = vec3(0.0);
  float unoccluded = 0.0;
  for (int r = 0; r < SSGI_RAYS; r++) {
    vec4 noise = blueNoise(texcoord, frameCounter * SSGI_RAYS + r);
    // cosine weighted hemisphere sampling. sqrt(1-y) and sqrt(y)... formula from the internet, makes more rays go straight up. DO NOT TOUCH
    float phi = 2.0 * PI * noise.x;
    float cosTheta = sqrt(1.0 - noise.y);
    float sinTheta = sqrt(noise.y);
    vec3 dir = basis * vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);

    vec3 hit = traceGIRay(viewPos + normal * 0.03, dir, noise.z); // nudge the start a tiny bit off the surface or the ray hits itself instantly and everything goes black. the 0.03 cost me an evening
    if (hit.z > 0.0) {
      vec3 L = texture(colortex0, hit.xy).rgb;
      L = min(L, vec3(SSGI_CLAMP)); // clamp so one super bright pixel doesn't spray fireflies all over the screen
      radianceSum += L;
    } else {
      unoccluded += 1.0; // ray escaped = sky can see this pixel. that's free AO, baby
    }
  }
  giOut = vec4(radianceSum / float(SSGI_RAYS), unoccluded / float(SSGI_RAYS));
  #endif
}

#endif
