// GGX sampling. it picks random directions for rough reflections. randomly. on purpose
#ifndef GGX_GLSL
#define GGX_GLSL

// Eric Heitz, JCGT 2018, "Sampling the GGX Distribution of Visible Normals"
// https://jcgt.org/published/0007/04/01/
// copied this straight out of the paper. I tried reading the paper. there were integrals. I closed it
vec3 sampleGGXVNDF(vec3 Ve, float alpha, vec2 u) {
  // stretch the view vector by roughness. "hemisphere configuration" or something. I just copy
  vec3 Vh = normalize(vec3(alpha * Ve.x, alpha * Ve.y, Ve.z));
  float lensq = Vh.x * Vh.x + Vh.y * Vh.y;
  // build two tangent vectors. if lensq is 0 just pick (1,0,0) and pray
  vec3 T1 =
    lensq > 0.0
      ? vec3(-Vh.y, Vh.x, 0.0) * inversesqrt(lensq)
      : vec3(1.0, 0.0, 0.0);
  vec3 T2 = cross(Vh, T1);
  // random point on a disk. sqrt(u.x) so they don't all clump in the middle. learned that from a stackoverflow answer
  float r = sqrt(u.x);
  float phi = 2.0 * PI * u.y;
  float t1 = r * cos(phi);
  float t2 = r * sin(phi);
  // squish the disk based on viewing angle. this line is pure black magic to me
  float s = 0.5 * (1.0 + Vh.z);
  t2 = (1.0 - s) * sqrt(1.0 - t1 * t1) + s * t2;
  vec3 Nh =
    t1 * T1 + t2 * T2 + sqrt(max(0.0, 1.0 - t1 * t1 - t2 * t2)) * Vh;
  // unstretch. done. I have no idea what just happened but reflections are blurry now
  return normalize(vec3(alpha * Nh.x, alpha * Nh.y, max(0.0, Nh.z)));
}

// make a whole coordinate system out of one normal with no cross products. some genius figured this out. not me
mat3 basisFromNormal(vec3 n) {
  float s = n.z >= 0.0 ? 1.0 : -1.0; // sign flip so it doesn't divide by zero when n points down. the -1 / (s + n.z) would explode
  float a = -1.0 / (s + n.z);
  float b = n.x * n.y * a;
  vec3 t = vec3(1.0 + s * n.x * n.x * a, s * b, -s * n.x);
  vec3 bt = vec3(b, s + n.y * n.y * a, -n.y);
  return mat3(t, bt, n);
}

#endif // GGX_GLSL
