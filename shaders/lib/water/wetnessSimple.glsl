// baby version of puddles.glsl for stuff that can't afford the full thing. no puddles, just "a bit wet"
#ifndef WETNESS_SIMPLE_GLSL
#define WETNESS_SIMPLE_GLSL

void applySurfaceWetnessSimple(
  inout Material material,
  float upness,
  float skyLightmap
) {
  #ifdef WETNESS
  // same sky lightmap check copy-pasted from puddles.glsl. DRY is for nerds
  float rainArea = smoothstep(13.5 / 15.0, 14.5 / 15.0, skyLightmap);
  if (upness < -0.5) return;
  float wet = clamp01(surfaceWetness * rainArea * mix(0.55, 1.0, clamp01(upness)) * WETNESS_STRENGTH);
  if (wet <= 0.0) return;
  // hardcoded 0.45, same as DEFAULT_POROSITY. yes I should use the define. no I'm not going to
  const float porosity = 0.45;
  // albedo times kinda-albedo = darker. wet things are darker. thanks science
  vec3 wetAlbedo = material.albedo * mix(vec3(1.0), material.albedo, 0.5) * 0.85;
  material.albedo = mix(material.albedo, wetAlbedo, wet * porosity);
  // sss > 0 means leaves and stuff, they get a different shine. I don't fully remember why 0.75
  float film = material.sss > 0.0 ? 0.75 : mix(0.25, 0.6, porosity);
  material.roughness = mix(material.roughness, material.roughness * film, wet);
  #endif
}

#endif // WETNESS_SIMPLE_GLSL
