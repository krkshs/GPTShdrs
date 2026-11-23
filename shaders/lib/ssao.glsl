#ifndef GPT_SSAO
#define GPT_SSAO
#include "/lib/common.glsl"

float contactAO(vec2 uv, vec3 position, vec3 normal, sampler2D depthBuffer) {
#if SSAO == 1
    // Do not sample the differently projected first-person hand.
    if (-position.z < 0.65 || -position.z > 96.0) return 1.0;
    float radius = clamp(1.15 * gbufferProjection[1][1] / max(-position.z, 1.0), 0.002, 0.08);
    float angle = hash12(floor(gl_FragCoord.xy / 2.0)) * 2.0 * GPT_PI;
    float occlusion = 0.0;
    for (int i = 0; i < 8; ++i) {
        float fi = float(i);
        float theta = angle + fi * 2.39996323;
        vec2 offset = vec2(cos(theta) / (viewWidth / viewHeight), sin(theta));
        vec2 sampleUV = uv + offset * radius * sqrt((fi + 1.0) / 8.0);
        if (any(lessThan(sampleUV, vec2(0.0))) || any(greaterThan(sampleUV, vec2(1.0)))) continue;
        float depth = texture2D(depthBuffer, sampleUV).r;
        if (depth >= 0.999999) continue;
        vec3 delta = viewFromDepth(sampleUV, depth) - position;
        float distanceToSample = length(delta);
        float facing = max(dot(normal, delta / max(distanceToSample, 0.001)) - 0.12, 0.0);
        float rangeWeight = 1.0 - smoothstep(0.2, 1.8, distanceToSample);
        occlusion += facing * rangeWeight * step(0.03, distanceToSample);
    }
    return 1.0 - saturate(occlusion / 8.0 * 2.0) * SSAO_STRENGTH;
#else
    return 1.0;
#endif
}
#endif
