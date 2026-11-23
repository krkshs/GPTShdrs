#version 120
#include "/lib/common.glsl"
uniform sampler2D colortex0;
uniform sampler2D colortex2;
varying vec2 vTexCoord;
/* DRAWBUFFERS:0 */

vec3 readBloom(vec2 uv) {
    return texture2D(colortex2, clamp(uv, vec2(0.0), vec2(1.0))).rgb;
}
void main() {
    vec3 color = texture2D(colortex0, vTexCoord).rgb;
#if BLOOM == 1
    vec2 stepUV = vec2(0.0, 2.0 / viewHeight);
    vec3 bloom = readBloom(vTexCoord) * 0.227027;
    bloom += (readBloom(vTexCoord + stepUV * 1.384615) + readBloom(vTexCoord - stepUV * 1.384615)) * 0.316216;
    bloom += (readBloom(vTexCoord + stepUV * 3.230769) + readBloom(vTexCoord - stepUV * 3.230769)) * 0.070270;
    color += bloom * BLOOM_STRENGTH;
#endif
    gl_FragData[0] = vec4(color, 1.0);
}
