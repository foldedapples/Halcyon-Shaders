/*
    Licensed under the MIT license, like the rest of Glimmer.
    (cloud shadow map. clouds casting shadows on the ground. like real life but slower)
*/

#define PREPARE_CLOUD_SHADOW_MAP // tells clouds.glsl we're doing the shadow map so it skips stuff. must be before the include or it's ignored. ask me how many hours
#include "/lib/common.glsl"

#ifdef vsh

// vertex shader. if you've seen one you've seen this one
out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

// ======== the clouds cast shadows down here ======================================================

#ifdef fsh
in vec2 texcoord;

#include "/lib/atmosphere/clouds.glsl"

/* RENDERTARGETS: 15 */
layout(location = 0) out vec4 shadowOut;

void main() {
  shadowOut = vec4(1.0); // 1.0 = fully lit, no shadow. default for when cloud shadows are off
  #if defined VOLUMETRIC_CLOUDS && defined CLOUDS && defined CLOUD_SHADOWS
  vec2 worldXZ = cloudShadowMapOrigin() + (texcoord - 0.5) * CLOUD_SHADOW_RANGE; // map this pixel to a spot in the world around the shadow map center. (texcoord - 0.5) recenters it, times the range = how many blocks the map covers
  vec3 feetPlayerPos = vec3(worldXZ.x - cameraPosition.x, cloudShadowMapHeight(), worldXZ.y - cameraPosition.z); // build a position at cloud height, relative to the camera. y is cloud height and the rest is the world spot minus the camera. I mixed up .y and .z here once and the shadows went sideways
  shadowOut = vec4(getVolumetricCloudShadow(feetPlayerPos, 8), 1.0); // march 8 steps up through the cloud and see how much sun gets through. 8 is cheap. shadows don't need to be pretty, they're shadows
  #endif
}

#endif
