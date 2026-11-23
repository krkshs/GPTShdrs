#include "/lib/atmosphere.glsl"
/* DRAWBUFFERS:0 */
void main() {
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
    vec3 ray = viewFromDepth(uv, 1.0);
    gl_FragData[0] = vec4(skyWithStars(worldDirection(ray)), 1.0);
}
