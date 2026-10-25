// shiny floors. this file is why my gpu fan sounds like a jet engine
#ifndef OPAQUE_REFLECTIONS_GLSL
#define OPAQUE_REFLECTIONS_GLSL

#include "/lib/util/ggx.glsl"
#include "/lib/util/spheremap.glsl"
#ifdef WORLD_THE_END
#include "/lib/atmosphere/sky/endAmbient.glsl"
#endif

// screen space reflections for solid blocks. "screen space" = if it's not on screen it doesn't exist. like my problems
vec3 applyOpaqueReflections(
  vec3 color,
  vec2 texcoord,
  vec3 viewPos,
  vec3 viewNormal,
  float skyLightmap
) {
  #if !defined SSR_OPAQUE || REFLECTION_MODE == 0
  return color; // reflections off, nothing to see here, go home
  #else
  vec4 reflData = texelFetch(colortex8, ivec2(gl_FragCoord.xy), 0);
  float smoothness = reflData.a;
  if (smoothness <= 0.0) return color;
  float roughness = 1.0 - smoothness;

  // fade out rough stuff so dirt doesn't try to be a mirror. dirt is not a mirror. dirt knows this
  float roughFade =
    1.0 - smoothstep(SSR_ROUGHNESS_CUTOFF * 0.6, SSR_ROUGHNESS_CUTOFF, roughness);
  if (roughFade <= 0.0) return color;

  // building a fake material out of spare parts because fresnelRoughness wants one. frankenstein shit
  Material material;
  material.albedo = reflData.rgb;
  material.f0 = reflData.rgb;
  material.roughness = roughness;
  material.metalID = NO_METAL;

  vec3 V = -normalize(viewPos);
  vec3 N = viewNormal;
  float NoV = clamp01(dot(N, V));

  vec3 fresnel = fresnelRoughness(material, NoV);
  // 13.5 / 15.0 = only reflect when you can basically see the sky, otherwise caves get shiny and it's creepy
  fresnel *= clamp01(smoothstep(13.5 / 15.0, 1.0, skyLightmap));
  fresnel *= 1.0 - max0(dot(N, -normalize(upPosition)));
  if (maxVec3(fresnel) < 1e-3) return color;

  vec3 R = reflect(-V, N);
  // rough surfaces get a randomly wobbled reflection direction. the blue noise makes it look less like garbage
  if (roughness > 0.02) {
    mat3 basis = basisFromNormal(N);
    vec3 Ve = transpose(basis) * V;
    vec2 u = blueNoise(texcoord, frameCounter).rg;
    vec3 H = basis * sampleGGXVNDF(Ve, roughness, u);
    vec3 Rs = reflect(-V, H);
    if (dot(Rs, N) > 0.0) R = Rs; // if it points into the floor, nah, keep the old one
  }

  float jitter = interleavedGradientNoise(floor(gl_FragCoord.xy), frameCounter);
  vec3 hitPos;
  bool hit;
  // the exact same function call twice with different textures because distant horizons has to be special
  #if defined DISTANT_HORIZONS || defined VOXY
  hit = rayIntersects(
    viewPos + N * 0.02,
    R,
    SSR_STEPS,
    jitter,
    true,
    hitPos,
    colortex6,
    combinedProjection
  );
  #else
  // the N * 0.02 pushes the ray off the surface so it doesn't hit itself. self-own prevention
  hit = rayIntersects(
    viewPos + N * 0.02,
    R,
    SSR_STEPS,
    jitter,
    true,
    hitPos,
    depthtex0,
    gbufferProjection
  );
  #endif

  if (!hit) return color;
  {
    // the +1000 and the 255.0 + 0.5 thing unpacks the material id. if water reflects water it gets weird so skip
    int hitMaterial = int(texture(colortex1, hitPos.xy).a * 255.0 + 0.5) + 1000;
    if (isWater(hitMaterial)) return color;
  }

  // fade near the screen edges because the reflection just... ends there. like falling off the map
  float edgeFade =
    1.0 - smoothstep(0.85, 1.0, maxVec2(abs(hitPos.xy - 0.5)) * 2.0);
  float w = edgeFade * roughFade;
  if (w <= 0.0) return color;

  vec3 reflected = texture(colortex0, hitPos.xy).rgb;

  #if defined DISTANT_HORIZONS || defined VOXY
  vec3 hitViewPos = screenSpaceToViewSpace(hitPos, combinedProjectionInverse);
  #else
  vec3 hitViewPos = screenSpaceToViewSpace(hitPos);
  #endif
  vec3 hitPlayerPos = mat3(gbufferModelViewInverse) * hitViewPos;

  // fog the reflection too, otherwise reflections are crystal clear and the real world is foggy. uncanny as hell
  #ifdef WORLD_OVERWORLD
  #ifdef ATMOSPHERIC_FOG
  reflected = atmosphericFog(reflected, hitViewPos);
  #endif
  #ifdef CLOUDY_FOG
  reflected = cloudyFog(reflected, hitPlayerPos, hitPos.z, vec3(sunVisibilitySmooth));
  #endif
  #endif
  #ifdef WORLD_THE_END
  reflected = endFog(reflected, hitViewPos, hitPos.z);
  #endif

  #ifdef ROUGH_SKY_REFLECTIONS
  // rougher = blurrier mip of the sky probe. log2 shit. it works, I checked like twice
  float mipLevel = log2(
    1.0 + roughness * (maxVec2(textureSize(colortex7, 0)) - 1.0)
  );
  #ifdef WORLD_THE_END
  vec3 probe = endAmbientSky(mat3(gbufferModelViewInverse) * reflect(normalize(viewPos), N));
  #else
  vec3 probe = textureLod(
    colortex7,
    mapSphere(reflect(normalize(viewPos), N)),
    mipLevel
  ).rgb;
  #endif
  // subtract the sky that's already there and add the real hit. I think. it stopped double-brightening at least
  color += fresnel * w * (reflected - probe);
  #else
  color += fresnel * w * reflected;
  #endif

  return max0(color); // max0 because negative light is a thing I accidentally invented once
  #endif
}

#endif // OPAQUE_REFLECTIONS_GLSL
