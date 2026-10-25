"""Run the pinned SwiftLint static binary and map rule names to IDs."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

MAPPING = {
    "cyclomatic_complexity": "SWF-012",
    "function_body_length": "SWF-012",
    "function_parameter_count": "SWF-012",
    "nesting": "SWF-012",
    "force_unwrapping": "SWF-004",
    "implicitly_unwrapped_optional": "SWF-004",
}


def main() -> int:
    binary = Path(".tools/swiftlint")
    if not binary.is_file():
        print("SWF-012: .tools/swiftlint が無い。make check が eng/tool-versions.txt から取得する")
        return 1
    completed = subprocess.run(
        [str(binary), "lint", "--strict", "--config", ".swiftlint.yml", "Sources", "Tests"],
        capture_output=True,
        text=True,
    )
    output = completed.stdout + completed.stderr
    sys.stdout.write(output)
    if completed.returncode != 0:
        named = sorted({rule for needle, rule in MAPPING.items() if needle in output})
        if named:
            print(" ".join(named) + ": SwiftLint が対応する違反を報告した")
        else:
            print("SWF-012: SwiftLint が失敗した")
    return completed.returncode


if __name__ == "__main__":
    sys.exit(main())
