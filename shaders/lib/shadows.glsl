#ifndef GPT_SHADOWS
#define GPT_SHADOWS
#include "/lib/common.glsl"
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform sampler2D shadowtex0;

// The same distortion is applied by the shadow writer and the receiver.
vec3 distortShadow(vec3 clipPosition) {
    float distortion = length(clipPosition.xy) * 0.85 + 0.15;
    return vec3(clipPosition.xy / distortion, clipPosition.z * 0.2);
}
float shadowVisibility(vec3 relativeWorld, vec3 normalWorld) {
#if SHADOWS == 1
    float ndotl = saturate(dot(normalWorld, lightDirection()));
    // World-space normal offset limits self-shadowing before projection.
    vec3 biased = relativeWorld + normalWorld * (0.025 + (1.0 - ndotl) * 0.065);
    vec4 clip = shadowProjection * shadowModelView * vec4(biased, 1.0);
    vec3 coord = distortShadow(clip.xyz / clip.w) * 0.5 + 0.5;
    if (coord.z <= 0.0 || coord.z >= 1.0 || any(lessThan(coord.xy, vec2(0.005))) ||
        any(greaterThan(coord.xy, vec2(0.995)))) return 1.0;

    float angle = hash12(floor((relativeWorld + cameraPosition).xz * 4.0)) * 2.0 * GPT_PI;
    mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    float radius = SHADOW_SOFTNESS / float(shadowMapResolution);
    float sum = 0.0;
    for (int i = 0; i < SHADOW_SAMPLES; ++i) {
        float fi = float(i);
        float theta = fi * 2.39996323;
        vec2 disk = vec2(cos(theta), sin(theta)) * sqrt((fi + 0.5) / float(SHADOW_SAMPLES));
        float depth = texture2D(shadowtex0, coord.xy + rotation * disk * radius).r;
        sum += step(coord.z - 0.00012, depth);
    }
    float visibility = sum / float(SHADOW_SAMPLES);
    float fade = smoothstep(shadowDistance * 0.75, shadowDistance * 0.98, length(relativeWorld.xz));
    return mix(visibility, 1.0, fade);
#else
    return 1.0;
#endif
}
#endif
