"""Lint Swift formatting. This does not rewrite sources."""

from __future__ import annotations

import subprocess
import sys


def main() -> int:
    completed = subprocess.run(
        [
            "swift-format",
            "lint",
            "--strict",
            "--recursive",
            "--configuration",
            ".swift-format",
            "Package.swift",
            "Sources",
        ],
        capture_output=True,
        text=True,
    )
    sys.stdout.write(completed.stdout)
    sys.stdout.write(completed.stderr)
    if completed.returncode != 0:
        print("QLT-004: swift-format の検査が失敗した")
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
