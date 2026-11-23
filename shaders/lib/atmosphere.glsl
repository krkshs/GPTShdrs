#ifndef GPT_ATMOSPHERE
#define GPT_ATMOSPHERE
#include "/lib/common.glsl"

vec3 atmosphere(vec3 direction, bool disks) {
    vec3 sunDir = sunDirection();
    float day = daylight();
    float elevation = saturate(direction.y);
    float horizon = pow(1.0 - elevation, 4.0);
    vec3 zenith = mix(vec3(0.006, 0.012, 0.028), vec3(0.085, 0.26, 0.56), day);
    vec3 horizonColor = mix(vec3(0.025, 0.038, 0.067), vec3(0.54, 0.68, 0.78), day);
    vec3 sky = mix(zenith, horizonColor, horizon);
    float sunset = (1.0 - smoothstep(0.02, 0.35, abs(sunDir.y))) * day;
    float towardSun = pow(saturate(dot(direction, sunDir) * 0.5 + 0.5), 8.0);
    sky += vec3(0.85, 0.22, 0.065) * sunset * horizon * towardSun;
    float sunDot = saturate(dot(direction, sunDir));
    sky += vec3(1.0, 0.74, 0.42) * pow(sunDot, 96.0) * 0.16 * day;
    if (disks) {
        float sunDisk = smoothstep(0.99980, 0.99994, sunDot);
        sky += vec3(9.0, 7.5, 5.3) * sunDisk * day;
        float moonDot = saturate(dot(direction, worldDirection(moonPosition)));
        float moonDisk = smoothstep(0.99975, 0.99991, moonDot);
        sky += vec3(0.72, 0.85, 1.0) * moonDisk * (1.0 - day);
    }
    vec3 overcast = mix(vec3(0.018, 0.023, 0.036), vec3(0.25, 0.30, 0.35), day);
    sky = mix(sky, overcast * (0.8 + elevation * 0.2), rainStrength * 0.85);
    // The lower hemisphere is only visible in reflections and below the horizon.
    sky = mix(sky * 0.3, sky, smoothstep(-0.25, 0.02, direction.y));
    return sky;
}

vec3 skyWithStars(vec3 direction) {
    vec3 sky = atmosphere(direction, true);
    vec3 cell = floor(direction * 600.0);
    float star = step(0.9985, hash12(cell.xz + cell.y * 37.0));
    star *= pow(hash12(cell.zy), 3.0) * smoothstep(0.04, 0.25, direction.y);
    sky += vec3(0.65, 0.75, 1.0) * star * (1.0 - daylight()) * (1.0 - rainStrength);
    return sky;
}

vec3 applyFog(vec3 color, vec3 viewPosition, float skyLight) {
    float distanceToEye = length(viewPosition);
    vec3 direction = worldDirection(viewPosition);
    if (isEyeInWater == 1) {
        float amount = 1.0 - exp(-distanceToEye * 0.085);
        vec3 underwater = vec3(0.012, 0.085, 0.11) * (0.3 + 0.7 * daylight());
        return mix(color * vec3(0.62, 0.85, 0.9), underwater, amount);
    }
    if (isEyeInWater == 2) {
        return mix(color, vec3(1.1, 0.16, 0.015), 1.0 - exp(-distanceToEye * 1.8));
    }
    float height = cameraPosition.y + cameraRelativeWorld(viewPosition).y * 0.5;
    float heightDensity = exp(-max(height - 64.0, 0.0) * 0.012);
    float density = (0.0013 + rainStrength * 0.0038) * FOG_DENSITY * heightDensity;
    float haze = (1.0 - exp(-distanceToEye * density)) * pow(saturate(skyLight), 2.0);
    float edge = smoothstep(far * 0.72, far * 0.99, distanceToEye);
    vec3 fog = atmosphere(normalize(vec3(direction.x, max(direction.y, 0.015), direction.z)), false);
    fog = mix(toLinear(fogColor), fog, pow(saturate(skyLight), 2.0));
    return mix(color, fog, saturate(max(haze, edge)));
}
#endif
