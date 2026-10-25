"""Compile the package and name warnings-as-errors failures."""

from __future__ import annotations

import subprocess
import sys


def main() -> int:
    completed = subprocess.run(["swift", "build"], capture_output=True, text=True)
    sys.stdout.write(completed.stdout)
    sys.stdout.write(completed.stderr)
    if completed.returncode != 0 and "[#" in (completed.stdout + completed.stderr):
        print("QLT-002: 警告をエラーとしてコンパイルを止めた")
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
