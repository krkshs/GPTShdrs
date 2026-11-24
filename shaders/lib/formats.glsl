#ifndef GPT_FORMATS
#define GPT_FORMATS
// OptiFine reads this token for buffer allocation but G8 does not define it
// for the GLSL compiler. Keep the name and supply the OpenGL enum ourselves.
#ifndef RGBA16F
#define RGBA16F 34842
#endif
#endif
