#version 120
#include "/lib/waving.glsl"
#include "/lib/shadows.glsl"
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
uniform mat4 shadowModelViewInverse;
varying vec2 vTexCoord;
varying float vBlockId;

void main() {
    vTexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vBlockId = mc_Entity.x;
    vec4 shadowView = gl_ModelViewMatrix * gl_Vertex;
    vec3 relativeWorld = (shadowModelViewInverse * shadowView).xyz;
    vec2 lightUV = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    float skyLight = saturate((lightUV.y - 0.03125) / 0.9375);
    float topVertex = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;
    vec3 offset = wavingOffset(relativeWorld + cameraPosition, vBlockId, topVertex, skyLight);
    shadowView.xyz += mat3(shadowModelView) * offset;
    vec4 clip = gl_ProjectionMatrix * shadowView;
    clip.xyz = distortShadow(clip.xyz / clip.w) * clip.w;
    gl_Position = clip;
}
