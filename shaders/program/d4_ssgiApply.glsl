/*
    Licensed under the MIT license, like the rest of Glimmer.
    (please don't sue me I'm just a guy)
    this pass blurs the GI and actually slaps it onto the image. the grand finale of jank
*/

#include "/lib/common.glsl"

#ifdef vsh

// you know what this is by now
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ======== the denoiser lives below. it's held together with exp() and hope ======================

#ifdef fsh
in vec2 texcoord;

#include "/lib/util/packing.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  color = texture(colortex0, texcoord);

  #ifdef SSGI
  float depth = texture(depthtex0, texcoord).r;
  if (depth >= 1.0 || depth < MC_HAND_DEPTH * 0.5 + 0.5) return; // no sky, no hand. same rules as the trace pass, I copy pasted it lol
  vec4 albedoData = texture(colortex11, texcoord);
  if (albedoData.a <= 0.0) return;
  vec3 albedo = pow2(albedoData.rgb); // pow2 = cheap srgb to linear. real gamma is 2.2 but 2.0 is close enough and I'm lazy

  float centerZ = screenSpaceToViewSpace(depth);
  vec4 data1 = texture(colortex1, texcoord);
  vec3 centerN = decodeNormal(data1.xy);

  // 5x5 blur that knows about edges ("bilateral" filter, I learned that word today). spacing 1.5 pixels because 1.0 was too blotchy
  vec2 pixel = 1.0 / vec2(viewWidth, viewHeight);
  vec4 sum = vec4(0.0);
  float wsum = 0.0;
  for (int y = -2; y <= 2; y++) {
    for (int x = -2; x <= 2; x++) {
      vec2 uv = texcoord + vec2(x, y) * pixel * 1.5;
      float d = texture(depthtex0, uv).r;
      if (d >= 1.0) continue;
      float z = screenSpaceToViewSpace(d);
      vec3 n = decodeNormal(texture(colortex1, uv).xy);
      float wz = exp(-abs(z - centerZ) / (abs(centerZ) * 0.02 + 0.05)); // depth weight: neighbor at a different depth = basically ignored. the numbers are vibes
      float wn = max(dot(n, centerN), 0.0);
      wn *= wn; wn *= wn; wn *= wn; wn *= wn; // this is pow(wn, 16) written by someone who doesn't trust pow(). that someone is me
      float wk = exp(-float(x * x + y * y) / 4.5); // gaussian-ish falloff. 4.5 is just a number that looked good
      float w = wz * wn * wk;
      sum += texture(colortex13, uv) * w;
      wsum += w;
    }
  }
  vec4 gi = wsum > 1e-4 ? sum / wsum : texture(colortex13, texcoord); // if every weight was 0 (lonely pixel), take the unblurred value and move on with our lives

  // gi.a = how much sky the pixel saw. darken the ambient where it didn't (AO), then add the bounced light. subtracting light feels illegal but whatever
  float skyLight = data1.z;
  vec3 ambient = albedo * weatherSkylightColor * pow2(skyLight) * albedoData.a;
  color.rgb -= ambient * (1.0 - gi.a) * SSAO_STRENGTH;
  color.rgb += albedo * gi.rgb * SSGI_STRENGTH;
  color.rgb = max0(color.rgb); // clamp to zero because subtracting light made negative colors once and the screen turned into a crime scene
  #endif
}

#endif
