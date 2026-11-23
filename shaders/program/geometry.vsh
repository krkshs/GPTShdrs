#include "/lib/waving.glsl"
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
varying vec2 vTexCoord;
varying vec2 vLightmap;
varying vec4 vColor;
varying vec3 vViewPosition;
varying vec3 vNormal;
varying float vBlockId;

void main() {
    vTexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vec2 lightUV = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vLightmap = clamp((lightUV - vec2(0.03125)) / 0.9375, 0.0, 1.0);
    vColor = gl_Color;
    vNormal = normalize(gl_NormalMatrix * gl_Normal);
    vBlockId = 0.0;
    vec4 viewPosition = gl_ModelViewMatrix * gl_Vertex;
#if defined(GPT_TERRAIN) || defined(GPT_WATER)
    vBlockId = mc_Entity.x;
    vec3 relativeWorld = cameraRelativeWorld(viewPosition.xyz);
    vec3 absoluteWorld = relativeWorld + cameraPosition;
    // Sprite upper vertices move; roots remain fixed to the ground.
    float topVertex = gl_MultiTexCoord0.t < mc_midTexCoord.t ? 1.0 : 0.0;
    vec3 offset = wavingOffset(absoluteWorld, vBlockId, topVertex, vLightmap.y);
#if defined(GPT_WATER) && WATER_WAVES == 1
    vec3 normalWorld = worldDirection(vNormal);
    if (abs(vBlockId - 10000.0) < 0.5 && normalWorld.y > 0.5) {
        // Same height function as water normals; only horizontal water faces move.
        offset.y += waveHeight(absoluteWorld.xz);
    }
#endif
    viewPosition.xyz += mat3(gbufferModelView) * offset;
#endif
    vViewPosition = viewPosition.xyz;
    gl_Position = gl_ProjectionMatrix * viewPosition;
    gl_FogFragCoord = length(viewPosition.xyz);
}
