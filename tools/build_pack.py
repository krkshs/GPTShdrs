#!/usr/bin/env python3
"""Build a deterministic OptiFine ZIP with Python's standard library."""
from __future__ import annotations

import argparse
import hashlib
import re
import sys
import zipfile
from pathlib import Path

from validate_shaders import ROOT, validate_structure

ZIP_TIME = (2026, 11, 24, 0, 0, 0)


def build(destination: Path) -> tuple[Path, str, int]:
    validate_structure()
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    if not re.fullmatch(r"[0-9A-Za-z.-]+", version):
        raise ValueError("Invalid VERSION filename characters")
    destination.mkdir(parents=True, exist_ok=True)
    archive = destination / f"GPTShdrs-{version}.zip"
    files = [ROOT / name for name in ("README.md", "LICENSE", "VERSION", "CHANGELOG.md")]
    files.extend(sorted((ROOT / "shaders").rglob("*")))
    files.extend(sorted((ROOT / "docs").glob("*.md")))
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for path in sorted(files):
            if not path.is_file():
                continue
            info = zipfile.ZipInfo(path.relative_to(ROOT).as_posix(), ZIP_TIME)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            content = path.read_text(encoding="utf-8").replace("\r\n", "\n").encode("utf-8")
            output.writestr(info, content, compresslevel=9)
    with zipfile.ZipFile(archive) as output:
        bad = output.testzip()
        if bad:
            raise ValueError(f"ZIP checksum failed: {bad}")
        names = output.namelist()
        if "shaders/gbuffers_terrain.fsh" not in names:
            raise ValueError("Invalid shader root in ZIP")
        for dimension in ("world-1", "world1"):
            if f"shaders/{dimension}/README.txt" not in names:
                raise ValueError(f"Missing ZIP dimension fallback: {dimension}")
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n", encoding="ascii")
    return archive, digest, len(names)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    args = parser.parse_args()
    try:
        archive, digest, count = build(args.output.resolve())
        print(f"Built: {archive}")
        print(f"Entries: {count}; size: {archive.stat().st_size:,} bytes")
        print(f"SHA256: {digest}")
        return 0
    except (ValueError, OSError, zipfile.BadZipFile) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
