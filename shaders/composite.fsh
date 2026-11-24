#version 120
#include "/lib/formats.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0;
varying vec2 vTexCoord;
const int colortex2Format = RGBA16F;
/* DRAWBUFFERS:2 */

vec3 brightColor(vec2 uv) {
    vec3 color = texture2D(colortex0, clamp(uv, vec2(0.0), vec2(1.0))).rgb;
    float bright = max(max(color.r, color.g), color.b);
    return color * max(bright - 1.0, 0.0) / max(bright, 0.001);
}
void main() {
    vec3 bloom = vec3(0.0);
#if BLOOM == 1
    vec2 stepUV = vec2(2.0 / viewWidth, 0.0);
    bloom = brightColor(vTexCoord) * 0.227027;
    bloom += (brightColor(vTexCoord + stepUV * 1.384615) + brightColor(vTexCoord - stepUV * 1.384615)) * 0.316216;
    bloom += (brightColor(vTexCoord + stepUV * 3.230769) + brightColor(vTexCoord - stepUV * 3.230769)) * 0.070270;
#endif
    gl_FragData[0] = vec4(bloom, 1.0);
}
