#version 120
#include "/lib/settings.glsl"
uniform sampler2D texture;
varying vec2 vTexCoord;
varying float vBlockId;

/* DRAWBUFFERS:0 */
void main() {
#if SHADOWS == 0
    discard;
#endif
    if (abs(vBlockId - 10000.0) < 0.5) discard;
    vec4 texel = texture2D(texture, vTexCoord);
    if (texel.a < 0.1) discard;
    gl_FragData[0] = vec4(1.0);
}
