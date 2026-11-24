#version 120
#include "/lib/formats.glsl"
#include "/lib/atmosphere.glsl"
#include "/lib/ssao.glsl"
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
varying vec2 vTexCoord;

const int colortex0Format = RGBA16F;
const int colortex1Format = RGBA16F;
const bool colortex1Nearest = true;
const vec4 colortex1ClearColor = vec4(0.5, 0.5, 1.0, 1.0);
/* DRAWBUFFERS:0 */

void main() {
    float depth = texture2D(depthtex0, vTexCoord).r;
    vec3 position = viewFromDepth(vTexCoord, depth);
    vec3 color;
    if (depth >= 0.999999) {
        color = skyWithStars(worldDirection(position));
        if (isEyeInWater != 0) color = applyFog(color, position, 1.0);
    } else {
        vec4 normalData = texture2D(colortex1, vTexCoord);
        vec3 normal = normalize(normalData.rgb * 2.0 - 1.0);
        color = texture2D(colortex0, vTexCoord).rgb;
        color *= contactAO(vTexCoord, position, normal, depthtex0);
        color = applyFog(color, position, normalData.a);
    }
    color *= 1.0 - saturate(blindness);
    gl_FragData[0] = vec4(color, 1.0);
}
