# GPTShdrs

**English** | [Русский](README.ru.md) | [简体中文](README.zh-CN.md)

An experiment in creating a realistic Minecraft shader with AI and improving it through real in-game feedback.

**0.1.1-alpha.2 · Minecraft Java 1.16.5 · OptiFine.** The source code was written for this project. MIT license.

Hardware for the first in-game test:

- GPU: **NVIDIA GeForce RTX 3050 Laptop GPU, 4 GB VRAM**.
- RAM: **16 GB**.
- CPU: **Intel Core i5-12450H**.

## Alpha 2

Updated from the first in-game screenshots and OptiFine G8 log: the pack now defines its own HDR format enum so `deferred` and `composite` can compile. Water uses weaker sky reflections, a single shadowed sun highlight, calmer normals, and depth-dependent transparency. Exposure, Bloom, sunlight, and the sky horizon have been reduced for more natural color and less white glare.

The landscape photograph guides the color and water balance. Reflections still use only the sky; shelter is estimated from existing sunlight shadows, so trees and banks are not mirrored. There are no additional rendering passes or shadow taps. Water adds one opaque-depth lookup and reuses one shadow filter for lighting and highlights; its depth buffer also requires a copy before translucency. Actual performance needs a new in-game test.

- Sun and moon shadows with filtered edges and adjustable distance.
- Linear-space lighting: warm sunlight and torches, cool skylight.
- Screen-space contact shading (SSAO) and Minecraft smooth lighting.
- Procedural sky, sunset, sun and moon disks, and stars.
- Atmospheric and underwater fog, overcast lighting during rain.
- Water with small waves, animated normals, subdued highlights, adjustable Fresnel sky reflections, and depth-dependent transparency.
- Wind in grass, flowers, crops, and leaves; subtle highlights on wet surfaces.
- HDR, Bloom, ACES tone mapping, FXAA, exposure, and saturation controls.
- LOW, BALANCED, and HIGH presets; Russian and English shader option menus.

This alpha focuses on the Overworld. **Shaders are disabled in the Nether and the End using dimension folders**, which select OptiFine's vanilla rendering fallback. Water reflects the sky; block reflections, refraction, volumetric clouds, ray tracing, and PBR are not implemented yet. Iris and mods with additional dimensions have not been tested.

## Installation

1. Install Minecraft Java **1.16.5** with OptiFine; **HD U G8** or a later build for 1.16.5 is recommended.
2. Get **GPTShdrs-0.1.1-alpha.2.zip** from the `dist` folder after building.
3. In Minecraft, open **Options → Video Settings → Shaders → Shaders Folder**.
4. Place the ZIP in the opened `shaderpacks` folder. **Do not extract it.**
5. Return to Minecraft and select GPTShdrs. The ZIP already has `shaders` at the correct root level.

You can also copy the source project folder into `shaderpacks/GPTShdrs`, with `shaders` directly inside it. GitHub's source ZIP includes an extra enclosing directory and must be extracted first.

## Settings for the first test

For the RTX 3050 Laptop 4 GB, Core i5-12450H, and 16 GB RAM, start with **BALANCED**, **1920×1080**, **10–12 chunks**, and default textures. Disable Render Regions. Set OptiFine render and shadow quality to **1×**, OptiFine antialiasing to **OFF**, and old lighting to **OFF** or Default. The shader provides its own FXAA.

BALANCED uses **2048×2048 shadows / 96-block distance / 8 samples**, with SSAO, Bloom, and water effects enabled. If performance is insufficient, select **LOW**: **1024×1024 / 64 blocks / 4 samples**, with SSAO and Bloom disabled.

All presets use **exposure 0.85 / saturation 1.0 / Bloom strength 0.04 / water reflection strength 0.35 / shallow-water transparency 0.6**. The WATER menu can further reduce sky reflections. Select BALANCED after upgrading to reset these values.

**FPS for Alpha 2 has not been measured yet.** These are starting settings; performance also depends on CPU load, resolution, mods, and the laptop's power limit.

## In-game feedback and retest

Alpha 1 screenshots showed excessive water glare and bright reflections under trees. The local Minecraft 1.16.5 / OptiFine HD U G8 log confirmed `undefined variable "RGBA16F"` in `deferred` and `composite`. These are the inputs for Alpha 2; its loading, appearance, and FPS are still awaiting a new game test.

Test route and report template: [docs/TESTING.md](docs/TESTING.md) (Russian).

Include the exact OptiFine build, resolution, preset, render distance, FPS, and screenshots during the day, at sunset, at night, near water, and in a cave. For a red shader error, include its text and the relevant section of the game's `logs/latest.log`.

Successful GLSL compilation checks syntax and the vertex/fragment stage interface. Loading, visuals, and performance in OptiFine require an in-game test.

## Development and building

Requires **Python 3.10+**. The build uses only the Python standard library:

```powershell
py -3 tools/build_pack.py
```

Check the pack layout, includes, menu options, and presets:

```powershell
py -3 tools/validate_shaders.py
```

Compiling all presets and effect switch configurations requires [glslang](https://github.com/KhronosGroup/glslang/releases). Add `glslang` / `glslangValidator` to PATH, extract the Windows build into `.tools/glslang`, or provide its path:

```powershell
py -3 tools/validate_shaders.py --validator "C:/tools/glslang/bin/glslang.exe" --all-options --require-compiler
```

Without a compiler, the normal check explicitly reports that compilation was skipped; `--require-compiler` fails. The build script checks the pack layout; run compilation separately before releasing.

The ZIP and SHA-256 file are created in `dist`. The ZIP contains shaders, the license, and documentation in all three README languages, excluding Git, tools, and caches. Identical sources produce an identical ZIP.

Architecture: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) (Russian). History: [CHANGELOG.md](CHANGELOG.md) (Russian).
