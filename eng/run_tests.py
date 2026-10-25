"""Run conformance unit tests. A failure is QLT-007."""

from __future__ import annotations

import subprocess
import sys


def main() -> int:
    completed = subprocess.run(
        [sys.executable, "-m", "unittest", "discover", "-s", "eng", "-p", "test_*.py"],
    )
    if completed.returncode != 0:
        print("QLT-007: 規約検査の単体テストが失敗した")
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
