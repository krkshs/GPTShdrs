#ifndef GPT_COMMON
#define GPT_COMMON
#include "/lib/settings.glsl"

const float GPT_PI = 3.14159265359;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform float far;
uniform int isEyeInWater;
uniform float blindness;
uniform float nightVision;
uniform ivec2 eyeBrightnessSmooth;

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec3 toLinear(vec3 color) { return pow(max(color, vec3(0.0)), vec3(2.2)); }
vec3 toDisplay(vec3 color) { return pow(max(color, vec3(0.0)), vec3(1.0 / 2.2)); }
float luminance(vec3 color) { return dot(color, vec3(0.2126, 0.7152, 0.0722)); }
float hash12(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

vec3 worldDirection(vec3 viewDirection) {
    return normalize(mat3(gbufferModelViewInverse) * viewDirection);
}
vec3 sunDirection() { return worldDirection(sunPosition); }
vec3 lightDirection() { return worldDirection(shadowLightPosition); }
float daylight() { return smoothstep(-0.10, 0.12, sunDirection().y); }
vec3 directLightColor() {
    float height = saturate(sunDirection().y * 3.0);
    vec3 sunlight = mix(vec3(1.8, 0.63, 0.25), vec3(1.55, 1.38, 1.12), height);
    vec3 moonlight = vec3(0.075, 0.105, 0.17);
    return mix(moonlight, sunlight, daylight()) * (1.0 - rainStrength * 0.78);
}
vec3 viewFromDepth(vec2 uv, float depth) {
    vec4 position = gbufferProjectionInverse * vec4(uv * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    return position.xyz / position.w;
}
vec3 cameraRelativeWorld(vec3 viewPosition) {
    return (gbufferModelViewInverse * vec4(viewPosition, 1.0)).xyz;
}
#endif
