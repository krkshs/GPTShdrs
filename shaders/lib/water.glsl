#ifndef GPT_WATER_LIGHTING
#define GPT_WATER_LIGHTING
#include "/lib/lighting.glsl"
#include "/lib/atmosphere.glsl"
#include "/lib/waving.glsl"
// Opaque depth copied by OptiFine before the translucent water pass.
uniform sampler2D depthtex1;

vec4 waterSurface(vec3 albedo, vec3 normalWorld, vec3 relativeWorld, vec3 viewPosition, vec2 lightmapUV) {
    vec3 waterNormal = normalWorld;
#if WATER_WAVES == 1
    if (normalWorld.y > 0.5) {
        // The analytical slope matches waveHeight; no amplified mirror bands.
        vec2 slope = waveSlope((relativeWorld + cameraPosition).xz);
        waterNormal = normalize(vec3(-slope.x, 1.0, -slope.y));
    }
#endif
    vec3 viewWorld = worldDirection(-viewPosition);
    float fresnel = 0.02 + 0.98 * pow(1.0 - saturate(abs(dot(waterNormal, viewWorld))), 5.0);
    // Reuse the same shadow filter for diffuse water, sky shelter and glints.
    float visibility = shadowVisibility(relativeWorld, waterNormal);
    vec3 waterTint = mix(vec3(0.035, 0.080, 0.070), albedo, 0.12);
    vec3 color = surfaceLightingWithShadow(waterTint, waterNormal, lightmapUV, 1.0, visibility);

    float thickness = 0.0;
    if (isEyeInWater == 0) {
        vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
        float opaqueDepth = texture2D(depthtex1, uv).r;
        thickness = 32.0;
        if (opaqueDepth < 0.999999) {
            vec3 behindWater = viewFromDepth(uv, opaqueDepth);
            thickness = clamp(length(behindWater) - length(viewPosition), 0.0, 32.0);
        }
    }
    // Blend with the already shaded bottom. Longer paths hide it gradually.
    float alpha = 1.0 - WATER_TRANSPARENCY * exp(-thickness * 0.075);
#if WATER_REFLECTIONS == 1
    // Sunlight occlusion is a cheap shelter estimate, not a scene reflection.
    float openSky = pow(lightmapUV.y, 4.0) * mix(0.25, 1.0, visibility);
    float reflectionWeight = fresnel * WATER_REFLECTION_STRENGTH * openSky;
    // The sun disk is excluded: the shadowed glint below supplies it once.
    vec3 reflection = atmosphere(reflect(-viewWorld, waterNormal), false);
    color = mix(color, reflection, reflectionWeight);
    alpha = mix(alpha, max(alpha, 0.85), reflectionWeight);
#endif
    vec3 halfVector = normalize(lightDirection() + viewWorld);
    float specular = pow(saturate(dot(waterNormal, halfVector)), 128.0);
    specular *= visibility * pow(lightmapUV.y, 3.0) * saturate(dot(waterNormal, lightDirection()));
    color += directLightColor() * specular * mix(0.35, 1.0, fresnel) * 0.65;
    return vec4(color, alpha);
}
#endif
