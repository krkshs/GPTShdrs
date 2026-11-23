#ifndef GPT_LIGHTING
#define GPT_LIGHTING
#include "/lib/shadows.glsl"

vec3 surfaceLighting(vec3 albedo, vec3 normalWorld, vec3 relativeWorld, vec2 lightmapUV, float vanillaAO, bool hand) {
    float skyLight = pow(lightmapUV.y, 3.0);
    float blockLight = pow(lightmapUV.x, 3.0);
    float day = daylight();
    vec3 skyAmbient = mix(vec3(0.025, 0.045, 0.085), vec3(0.28, 0.36, 0.46), day);
    skyAmbient = mix(skyAmbient, vec3(luminance(skyAmbient)), rainStrength * 0.4);
    float hemisphere = 0.55 + 0.45 * saturate(normalWorld.y * 0.5 + 0.5);
    vec3 ambient = vec3(CAVE_BRIGHTNESS) + skyAmbient * skyLight * hemisphere;
    vec3 torch = vec3(1.5, 0.65, 0.22) * blockLight * TORCH_STRENGTH;
    float ndotl = saturate(dot(normalWorld, lightDirection()));
    float shadow = hand ? 1.0 : shadowVisibility(relativeWorld, normalWorld);
    float horizonFade = smoothstep(0.01, 0.09, abs(sunDirection().y));
    shadow = mix(1.0, shadow, horizonFade);
    vec3 direct = directLightColor() * ndotl * shadow * smoothstep(0.05, 0.85, lightmapUV.y);
    vec3 light = (ambient + torch) * mix(0.35, 1.0, vanillaAO) + direct;
    light = mix(light, max(light, vec3(0.85)), nightVision);
    return albedo * light;
}
#endif
