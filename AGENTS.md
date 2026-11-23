# GPTShdrs project instructions

- Target Minecraft Java 1.16.5 with OptiFine. Shader entry points use GLSL 1.20.
- Keep shared code in shaders/lib and shaders/program; entry points stay in shaders/.
- Keep shadow and main-pass vertex animation and shadow distortion consistent.
- Treat only block.10000 as water. Glass, ice and other translucent blocks retain their materials.
- Keep default option values consistent with the BALANCED profile. Update both language files for new options.
- Preserve empty-program folders world-1 and world1 until dimension support is implemented and tested.
- Before delivering shader changes, run tools/validate_shaders.py --all-options --require-compiler and tools/build_pack.py. Python 3.10+ is required. Also run git diff --check.
- Never describe Minecraft loading, visuals or FPS as tested unless the game was actually run or the user supplied a report. Static GLSL checks are separate.
- Update VERSION and CHANGELOG.md for releases. Use v-prefixed version tags.
- Work directly in main and push completed changes immediately. Do not create separate branches unless the user explicitly requests one.
- Do not commit dist/, .tools/, compiled binaries or caches.
