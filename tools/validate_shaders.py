#!/usr/bin/env python3
"""Check OptiFine layout, resolve includes, compile/link GLSL 1.20 with glslang."""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHADERS = ROOT / "shaders"
INCLUDE = re.compile(r'^\s*#include\s+"([^"]+)"\s*$', re.MULTILINE)
DEFINE_OPTION = re.compile(r"^#define\s+(\w+)\s+([0-9.]+)\s+//.*\[([^]]+)\]", re.MULTILINE)
CONST_OPTION = re.compile(r"^const\s+(?:int|float)\s+(\w+)\s*=\s*([0-9.]+);.*\[([^]]+)\]", re.MULTILINE)
REQUIRED = ("shadow", "gbuffers_terrain", "gbuffers_water", "gbuffers_entities",
            "gbuffers_hand", "deferred", "composite", "composite1", "final")


def expand(path: Path, stack: tuple[Path, ...] = ()) -> str:
    path = path.resolve()
    if not path.is_relative_to(SHADERS.resolve()):
        raise ValueError(f"Include leaves shader directory: {path}")
    if path in stack:
        raise ValueError("Include cycle: " + " -> ".join(p.name for p in (*stack, path)))
    if len(stack) >= 10:
        raise ValueError(f"OptiFine include depth exceeded at {path.name}")

    def replace(match: re.Match) -> str:
        name = match.group(1)
        target = SHADERS / name.lstrip("/") if name.startswith("/") else path.parent / name
        return expand(target, (*stack, path))

    return INCLUDE.sub(replace, path.read_text(encoding="utf-8"))


def properties() -> dict[str, str]:
    result = {}
    for line in (SHADERS / "shaders.properties").read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        key, separator, value = line.partition("=")
        if not separator or key in result:
            raise ValueError(f"Invalid or duplicate property: {line}")
        result[key] = value.strip()
    return result


def options() -> dict[str, tuple[str, list[str]]]:
    source = (SHADERS / "lib/settings.glsl").read_text(encoding="utf-8")
    return {name: (default, values.split()) for name, default, values
            in (*DEFINE_OPTION.findall(source), *CONST_OPTION.findall(source))}


def profiles() -> dict[str, dict[str, str]]:
    schema = options()
    result = {}
    for key, value in properties().items():
        if not key.startswith("profile."):
            continue
        values = {}
        for token in value.split():
            name, separator, setting = token.partition(":")
            if not separator or name not in schema or setting not in schema[name][1]:
                raise ValueError(f"Invalid option in {key}: {token}")
            values[name] = setting
        result[key.removeprefix("profile.")] = values
    return result


def validate_structure() -> list[str]:
    vertices = {p.stem for p in SHADERS.glob("*.vsh")}
    fragments = {p.stem for p in SHADERS.glob("*.fsh")}
    if vertices != fragments:
        raise ValueError(f"Unpaired stages: {sorted(vertices ^ fragments)}")
    if not set(REQUIRED).issubset(vertices):
        raise ValueError(f"Missing programs: {sorted(set(REQUIRED) - vertices)}")
    for name in sorted(vertices):
        for extension in ("vsh", "fsh"):
            source = expand(SHADERS / f"{name}.{extension}")
            if not source.startswith("#version 120\n") or source.count("#version") != 1:
                raise ValueError(f"{name}.{extension}: expected one GLSL 120 version")
            if extension == "fsh" and name != "final" and "DRAWBUFFERS:" not in source:
                raise ValueError(f"{name}: missing explicit buffer routing")
    schema = options()
    for name, (default, values) in schema.items():
        if default not in values:
            raise ValueError(f"Default for {name} is not an allowed value")
    for key, value in properties().items():
        if key == "sliders" or key.startswith("screen"):
            if key.endswith("columns"):
                continue
            for token in value.split():
                if token not in ("<profile>", "<empty>", "*") and not token.startswith("["):
                    if token not in schema:
                        raise ValueError(f"Unknown menu option: {token}")
    presets = profiles()
    if not presets or len({tuple(sorted(p)) for p in presets.values()}) != 1:
        raise ValueError("Profiles must configure the same options")
    defaults = {name: default for name, (default, _) in schema.items()}
    if any(defaults[name] != value for name, value in presets["BALANCED"].items()):
        raise ValueError("Defaults must match BALANCED")
    for dimension in ("world-1", "world1"):
        folder = SHADERS / dimension
        if not folder.is_dir() or list(folder.glob("*.?sh")):
            raise ValueError(f"{dimension} must exist without shader programs")
    for required in ("README.md", "LICENSE", "VERSION", "shaders/block.properties",
                     "shaders/lang/en_us.lang", "shaders/lang/ru_ru.lang"):
        if not (ROOT / required).is_file():
            raise ValueError(f"Missing pack file: {required}")
    return sorted(vertices)


def compiler_path(explicit: str | None) -> str | None:
    if explicit:
        path = Path(explicit)
        if path.is_file():
            return str(path.resolve())
        found = shutil.which(explicit)
        if not found:
            raise ValueError(f"Compiler not found: {explicit}")
        return found
    for candidate in (ROOT / ".tools/glslang/bin/glslang.exe",
                      ROOT / ".tools/glslang/bin/glslangValidator.exe"):
        if candidate.is_file():
            return str(candidate)
    return shutil.which("glslangValidator") or shutil.which("glslang")


def configured_source(path: Path, values: dict[str, str]) -> str:
    source = expand(path)
    for name, value in values.items():
        source = re.sub(rf"(^#define\s+{re.escape(name)}\s+)[0-9.]+",
                        lambda m: m.group(1) + value, source, flags=re.MULTILINE)
        source = re.sub(rf"(^const\s+(?:int|float)\s+{re.escape(name)}\s*=\s*)[0-9.]+",
                        lambda m: m.group(1) + value, source, flags=re.MULTILINE)
    # OptiFine injects format/environment macros after #version.
    preamble = "#define RGBA16F 34842\n#define MC_VERSION 11605\n"
    return source.replace("#version 120\n", "#version 120\n" + preamble, 1)


def compile_programs(compiler: str, programs: list[str], scenarios: dict[str, dict[str, str]]) -> int:
    count = 0
    with tempfile.TemporaryDirectory(prefix="gptshdrs-glsl-") as directory:
        folder = Path(directory)
        for scenario, values in scenarios.items():
            for name in programs:
                paths = []
                for extension, stage in (("vsh", "vert"), ("fsh", "frag")):
                    target = folder / f"{name}.{stage}"
                    target.write_text(configured_source(SHADERS / f"{name}.{extension}", values),
                                      encoding="utf-8", newline="\n")
                    paths.append(str(target))
                result = subprocess.run([compiler, "-l", *paths], capture_output=True,
                                        text=True, timeout=30)
                if result.returncode:
                    raise ValueError(f"{scenario}/{name} failed:\n{result.stdout}{result.stderr}")
                count += 1
            print(f"OK: {scenario} ({len(programs)} programs compiled and linked)", flush=True)
    return count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--validator", help="Path to glslang or glslangValidator")
    parser.add_argument("--require-compiler", action="store_true")
    parser.add_argument("--all-profiles", action="store_true")
    parser.add_argument("--all-options", action="store_true",
                        help="Compile all profiles, all effects off, each effect individually off")
    args = parser.parse_args()
    try:
        programs = validate_structure()
        print(f"OK: structure, includes, options and profiles ({len(programs)} programs)")
        compiler = compiler_path(args.validator)
        if not compiler:
            if args.require_compiler:
                raise ValueError("Install glslang and pass --validator or add it to PATH")
            print("SKIPPED: GLSL compilation (no compiler). In-game testing is still required.")
            return 0
        scenarios = profiles() if args.all_profiles or args.all_options else {"DEFAULT": {}}
        if args.all_options:
            effects = ("SHADOWS", "SSAO", "WATER_WAVES", "WATER_REFLECTIONS", "WAVING_FOLIAGE", "BLOOM", "FXAA")
            scenarios["ALL_OFF"] = dict.fromkeys(effects, "0")
            for effect in effects:
                scenarios[f"NO_{effect}"] = {effect: "0"}
        count = compile_programs(compiler, programs, scenarios)
        print(f"PASS: {count} program configurations. Minecraft visual/FPS testing remains pending.")
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
