"""Run Swift Testing and name a failure with QLT-008."""

from __future__ import annotations

import subprocess
import sys


def main() -> int:
    completed = subprocess.run(["swift", "test"], capture_output=True, text=True)
    sys.stdout.write(completed.stdout)
    sys.stdout.write(completed.stderr)
    if completed.returncode != 0:
        print("QLT-008: 製品のテストが失敗した")
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
