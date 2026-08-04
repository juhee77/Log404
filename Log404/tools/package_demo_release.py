#!/usr/bin/env python3
"""Assemble exported demo builds into the Steam content layout."""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DIST_DIR = ROOT / "dist"
STEAM_CONTENT_DIR = ROOT / "distribution" / "steam" / "content"

README_TEXT = """LOG:404 Demo Package

Included builds:
- windows/
- macos/
- web/

This folder is prepared for Steam demo upload packaging.
Replace AppID/DepotID placeholders in distribution/steam/templates before upload.
"""


def copy_tree_if_exists(source: Path, target: Path) -> bool:
    if not source.exists():
        return False
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(source, target)
    return True


def copy_file_if_exists(source: Path, target: Path) -> bool:
    if not source.exists():
        return False
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Package Godot demo exports for Steam upload.")
    parser.add_argument("--source", type=Path, default=DIST_DIR, help="Directory containing Godot export outputs")
    parser.add_argument("--version", default="0.1.0-demo", help="Version label for the package note")
    args = parser.parse_args()

    source = args.source.resolve()
    STEAM_CONTENT_DIR.mkdir(parents=True, exist_ok=True)

    copied_any = False
    copied_any |= copy_tree_if_exists(source / "windows", STEAM_CONTENT_DIR / "windows")
    copied_any |= copy_tree_if_exists(source / "macos", STEAM_CONTENT_DIR / "macos")
    copied_any |= copy_tree_if_exists(source / "web", STEAM_CONTENT_DIR / "web")
    copied_any |= copy_file_if_exists(source / "windows" / "LOG404.exe", STEAM_CONTENT_DIR / "windows" / "LOG404.exe")
    copied_any |= copy_file_if_exists(source / "web" / "index.html", STEAM_CONTENT_DIR / "web" / "index.html")

    note_path = STEAM_CONTENT_DIR / "PACKAGE-README.txt"
    note_path.write_text(README_TEXT + f"\nVersion: {args.version}\n", encoding="utf-8")

    if not copied_any:
        print("No export artifacts were found. Expected folders like dist/windows or dist/macos.")
        return 1

    print(f"Steam demo content prepared at: {STEAM_CONTENT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
