#ifndef END_AMBIENT_GLSL
#define END_AMBIENT_GLSL

// the End is supposed to be dark and purple and spooky so here's some dark purple spooky light
vec3 endAmbientSky(vec3 dir) {
  vec3 tint = mix(vec3(0.5), vec3(0.42, 0.40, 0.75), END_AMBIENT_TINT); // purple-ish. I picked these in a color picker at 3am
  vec3 base = tint / luminance(tint) * 0.45 * 0.0028; // 0.45 * 0.0028 = "small number". why didn't I just multiply them. too scared now
  #ifdef BLACK_HOLE
  // if there's a black hole, the sky glows orange-ish toward it. space is weird man
  float toward = max(dot(dir, worldLightDir), 0.0);
  base += vec3(1.0, 0.66, 0.38) * 0.006 * pow(toward, 6.0) * BH_DISK_BRIGHTNESS; // pow 6 because pow 5 looked wrong and pow 7 looked wronger
  #endif
  return base * END_AMBIENT;
}

#endif // END_AMBIENT_GLSL
