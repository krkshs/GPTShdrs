#ifndef GPT_WAVING
#define GPT_WAVING
#include "/lib/common.glsl"

vec2 waveSlope(vec2 position) {
    float t = frameTimeCounter;
    float a = dot(position, vec2(0.75, 0.30)) + t * 1.2;
    float b = dot(position, vec2(-0.40, 0.85)) + t * 0.85;
    float c = dot(position, vec2(1.6, -0.7)) - t * 1.6;
    return cos(a) * vec2(0.75, 0.30) * 0.035 +
           cos(b) * vec2(-0.40, 0.85) * 0.025 +
           cos(c) * vec2(1.6, -0.7) * 0.009;
}
float waveHeight(vec2 position) {
    float t = frameTimeCounter;
    return sin(dot(position, vec2(0.75, 0.30)) + t * 1.2) * 0.035 +
           sin(dot(position, vec2(-0.40, 0.85)) + t * 0.85) * 0.025 +
           sin(dot(position, vec2(1.6, -0.7)) - t * 1.6) * 0.009;
}
vec3 wavingOffset(vec3 absolutePosition, float blockId, float topVertex, float skyLight) {
    vec3 offset = vec3(0.0);
#if WAVING_FOLIAGE == 1
    bool plant = blockId > 10000.5 && blockId < 10001.5;
    bool leaves = blockId > 10001.5 && blockId < 10002.5;
    if (plant || leaves) {
        float t = frameTimeCounter;
        float phase = dot(absolutePosition.xz, vec2(0.6, 0.37));
        float wind = sin(t * 1.7 + phase) * 0.65 + sin(t * 2.6 + phase * 1.9) * 0.35;
        float amount = (plant ? topVertex * 0.065 : 0.025) * WIND_STRENGTH;
        amount *= smoothstep(0.25, 0.9, skyLight) * (1.0 + rainStrength * 0.45);
        offset.xz += vec2(wind, sin(t * 1.4 + phase)) * amount;
    }
#endif
    return offset;
}
#endif
