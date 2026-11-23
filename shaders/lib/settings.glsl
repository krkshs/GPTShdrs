#ifndef GPT_SETTINGS
#define GPT_SETTINGS

// All user options are numeric so OptiFine can expose them reliably.
#define SHADOWS 1 // Direct-light shadows. [0 1]
const int shadowMapResolution = 2048; // Shadow texture size. [1024 1536 2048 3072]
const float shadowDistance = 96.0; // Shadow reach in blocks. [48.0 64.0 96.0 128.0]
#define SHADOW_SAMPLES 8 // Shadow filter taps. [4 8 12]
#define SHADOW_SOFTNESS 1.25 // Shadow filter radius. [0.75 1.25 2.0]
#define SSAO 1 // Screen-space contact shading. [0 1]
#define SSAO_STRENGTH 0.4 // Contact shading strength. [0.0 0.25 0.4 0.6]
#define WATER_WAVES 1 // Small water waves and moving normals. [0 1]
#define WATER_REFLECTIONS 1 // Fresnel sky reflection on water. [0 1]
#define WATER_TRANSPARENCY 0.6 // Water transparency. [0.4 0.6 0.75]
#define WAVING_FOLIAGE 1 // Wind in leaves and plants. [0 1]
#define WIND_STRENGTH 1.0 // Foliage wind amplitude. [0.0 0.5 1.0 1.5]
#define BLOOM 1 // Soft glow around bright light. [0 1]
#define BLOOM_STRENGTH 0.08 // Glow intensity. [0.0 0.04 0.08 0.14]
#define FOG_DENSITY 1.0 // Atmospheric haze density. [0.5 1.0 1.5]
#define EXPOSURE 1.0 // Scene exposure before tone mapping. [0.7 0.85 1.0 1.15 1.3]
#define SATURATION 1.04 // Color saturation. [0.85 1.0 1.04 1.15]
#define FXAA 1 // Fast edge antialiasing. [0 1]
#define CAVE_BRIGHTNESS 0.025 // Minimum light in enclosed areas. [0.01 0.025 0.04]
#define TORCH_STRENGTH 1.0 // Warm block-light intensity. [0.75 1.0 1.25]

const float sunPathRotation = -25.0;
const float ambientOcclusionLevel = 1.0;
const float shadowIntervalSize = 2.0;
const bool shadowHardwareFiltering = false;
const bool shadowtex0Nearest = true;
const float wetnessHalflife = 100.0;
const float drynessHalflife = 200.0;
const float eyeBrightnessHalflife = 10.0;
#endif
