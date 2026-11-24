#include "/lib/lighting.glsl"
#include "/lib/atmosphere.glsl"
#include "/lib/waving.glsl"
#ifdef GPT_WATER
#include "/lib/water.glsl"
#endif
uniform sampler2D texture;
uniform vec4 entityColor;
varying vec2 vTexCoord;
varying vec2 vLightmap;
varying vec4 vColor;
varying vec3 vViewPosition;
varying vec3 vNormal;
varying float vBlockId;

/* DRAWBUFFERS:01 */

void main() {
#ifdef GPT_BASIC
    vec4 texel = vec4(1.0);
#else
    vec4 texel = texture2D(texture, vTexCoord);
#endif
    float alpha = texel.a;
#if defined(GPT_TERRAIN) || defined(GPT_ENTITY) || defined(GPT_HAND)
    // Separate AO uses vertex alpha for terrain, not opacity.
    if (alpha < 0.1) discard;
#else
    alpha *= vColor.a;
    if (alpha < 0.01) discard;
#endif
    vec3 albedo = toLinear(texel.rgb * vColor.rgb);
#ifdef GPT_ENTITY
    albedo = mix(albedo, toLinear(entityColor.rgb), entityColor.a);
#endif
    vec3 normalWorld = worldDirection(normalize(vNormal));
    vec3 relativeWorld = cameraRelativeWorld(vViewPosition);
    vec3 color;
#ifdef GPT_UNLIT
    color = albedo;
#else
#ifdef GPT_HAND
    bool hand = true;
#else
    bool hand = false;
#endif
#ifdef GPT_TERRAIN
    float ao = saturate(vColor.a);
#else
    float ao = 1.0;
#endif
#ifdef GPT_WATER
    if (abs(vBlockId - 10000.0) < 0.5) {
        vec4 water = waterSurface(albedo, normalWorld, relativeWorld, vViewPosition, vLightmap);
        color = water.rgb;
        alpha = water.a;
    } else
#endif
    {
        color = surfaceLighting(albedo, normalWorld, relativeWorld, vLightmap, ao, hand);
    }
#endif

#ifdef GPT_EMISSIVE
    color = max(color, albedo * 1.8);
#endif

#ifdef GPT_TERRAIN
    // A restrained sun highlight on wet, upward-facing outdoor surfaces.
    vec3 viewWorld = normalize(-relativeWorld);
    vec3 halfVector = normalize(lightDirection() + viewWorld);
    float wetSpecular = pow(saturate(dot(normalWorld, halfVector)), 64.0);
    wetSpecular *= wetness * saturate(normalWorld.y) * pow(vLightmap.y, 4.0);
    color += directLightColor() * wetSpecular * shadowVisibility(relativeWorld, normalWorld) * 0.22;
#endif

#if defined(GPT_TRANSLUCENT) || defined(GPT_WEATHER)
    // These passes render after deferred or do not contribute reliable depth.
    color = applyFog(color, vViewPosition, vLightmap.y);
#endif
#ifdef GPT_DAMAGE
    // OptiFine multiplies the cracking texture into the existing terrain.
    color = texel.rgb * vColor.rgb;
#endif
    vec3 viewNormal = normalize(mat3(gbufferModelView) * normalWorld);
    gl_FragData[0] = vec4(max(color, vec3(0.0)), alpha);
    gl_FragData[1] = vec4(viewNormal * 0.5 + 0.5, vLightmap.y);
}
