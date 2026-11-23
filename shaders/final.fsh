#version 120
#include "/lib/common.glsl"
uniform sampler2D colortex0;
varying vec2 vTexCoord;

vec3 toneMap(vec3 color) {
    color = max(color * EXPOSURE, vec3(0.0));
    // ACES fitted curve: retain highlights instead of clipping HDR lighting.
    color = clamp((color * (2.51 * color + 0.03)) /
                  (color * (2.43 * color + 0.59) + 0.14), 0.0, 1.0);
    color = mix(vec3(luminance(color)), color, SATURATION);
    return toDisplay(clamp(color, 0.0, 1.0));
}
vec3 displaySample(vec2 uv) {
    return toneMap(texture2D(colortex0, clamp(uv, vec2(0.0), vec2(1.0))).rgb);
}
void main() {
    vec3 color = displaySample(vTexCoord);
#if FXAA == 1
    vec2 pixel = vec2(1.0 / viewWidth, 1.0 / viewHeight);
    vec3 nw = displaySample(vTexCoord + vec2(-1.0, -1.0) * pixel);
    vec3 ne = displaySample(vTexCoord + vec2( 1.0, -1.0) * pixel);
    vec3 sw = displaySample(vTexCoord + vec2(-1.0,  1.0) * pixel);
    vec3 se = displaySample(vTexCoord + vec2( 1.0,  1.0) * pixel);
    float lm = luminance(color);
    float lnw = luminance(nw), lne = luminance(ne), lsw = luminance(sw), lse = luminance(se);
    float lmin = min(lm, min(min(lnw, lne), min(lsw, lse)));
    float lmax = max(lm, max(max(lnw, lne), max(lsw, lse)));
    if (lmax - lmin > max(0.035, lmax * 0.125)) {
        vec2 direction = vec2(-((lnw + lne) - (lsw + lse)), (lnw + lsw) - (lne + lse));
        float reduce = max((lnw + lne + lsw + lse) * 0.03125, 0.0078125);
        float reciprocal = 1.0 / (min(abs(direction.x), abs(direction.y)) + reduce);
        direction = clamp(direction * reciprocal, vec2(-8.0), vec2(8.0)) * pixel;
        vec3 a = 0.5 * (displaySample(vTexCoord + direction * (-1.0 / 6.0)) +
                        displaySample(vTexCoord + direction * ( 1.0 / 6.0)));
        vec3 b = a * 0.5 + 0.25 * (displaySample(vTexCoord - direction * 0.5) +
                                   displaySample(vTexCoord + direction * 0.5));
        float lb = luminance(b);
        color = lb < lmin || lb > lmax ? a : b;
    }
#endif
    // One display-space LSB of dither reduces visible bands in sky gradients.
    color += (hash12(gl_FragCoord.xy) - 0.5) / 255.0;
    gl_FragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
