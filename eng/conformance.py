"""Dependency-free conformance checks for NeNe Sand.

Detection phrases that would flag this file are assembled at runtime and this
file is not scanned for them.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

RULE_ID = re.compile(r"(?:ARC|SWF|QLT|CNF|GIT)-\d{3}")
HEADING = re.compile(r"^### ((?:ARC|SWF|QLT|CNF|GIT)-\d{3}) — ")
STATUS = re.compile(r"機械強制:\s*\*\*(active|planned|不能|不採用)\*\*")
MATRIX_ROW = re.compile(r"^\| ((?:ARC|SWF|QLT|CNF|GIT)-\d{3}) \| ([^|]*?)\|")
PROOF_ROW = re.compile(r"^\| ((?:ARC|SWF|QLT|CNF|GIT)-\d{3}) \|")
TYPE_DECL = re.compile(
    r"\b(struct|enum|class|actor|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)"
)
IMPORT_LINE = re.compile(r"^\s*import\s+(?:struct\s+|class\s+|enum\s+|func\s+|var\s+)?([A-Za-z_][A-Za-z0-9_]*)")
PUBLIC_VAR = re.compile(r"\b(?:public|open)\s+(?:static\s+)?var\s+")
WAIVER_LINE = re.compile(r"^\s*//\s*Waiver:\s*(WVR-\d{4})\b")
TARGET_CALL = re.compile(r"\.(executableTarget|target)\(", re.S)
NAME_FIELD = re.compile(r'name:\s*"([^"]+)"')
DEPS_FIELD = re.compile(r"dependencies:\s*\[(.*?)\]", re.S)
QUOTED = re.compile(r'"([^"]+)"')
PACKAGE_URL = ".pack" + "age("
WARNINGS_AS_ERRORS = "-warnings-" + "as-errors"
SUPPRESS_WARNINGS = "-suppress-" + "warnings"
BASELINE_FLAG = "--base" + "line"
IGNORE_FAILURES = "ignore" + "Failures"
FORBIDDEN_SUFFIXES = ("Manager", "Helper", "Utils", "Util", "Common")
FORBIDDEN_DIRS = frozenset({"utils", "helpers", "managers", "misc", "common"})
TIME_TOKENS = (
    re.compile(r"\bDate\s*\("),
    re.compile(r"\bNSDate\b"),
    re.compile(r"\bContinuousClock\b"),
    re.compile(r"\bSuspendingClock\b"),
    re.compile(r"\bSystemRandomNumberGenerator\b"),
    re.compile(r"\.random\s*\("),
    re.compile(r"\bProcessInfo\b"),
    re.compile(r"\bLocale\.current\b"),
    re.compile(r"\bTimeZone\.current\b"),
    re.compile(r"\bCalendar\.current\b"),
    re.compile(r"\bFileManager\b"),
    re.compile(r"\bgetenv\s*\("),
    re.compile(r"\btime\s*\("),
    re.compile(r"\bclock_gettime\s*\("),
    re.compile(r"\bgettimeofday\s*\("),
    re.compile(r"\barc4random\b"),
)
TASK_TOKENS = (
    re.compile(r"\bTask\s*\{"),
    re.compile(r"\bTask\.detached\b"),
    re.compile(r"\bTaskGroup\b"),
)
UNSAFE_TOKENS = (
    re.compile(r"\bunsafeBitCast\s*\("),
    re.compile(r"\bunsafeDowncast\s*\("),
)
EXHAUSTIVE_TOKENS = (
    re.compile(r"\bdefault\s*:"),
    re.compile(r"@unknown\s+default"),
    re.compile(r"^\s*case\s+_"),
)
QUALITY_COMMANDS = (
    "swiftlint",
    "swift-format",
    "swift build",
    "swift test",
    "conformance.py",
    "unittest",
)
SKIP_DIRS = {"__pycache__"}


@dataclass(frozen=True)
class Violation:
    rule_id: str
    where: str
    message: str

    def format(self) -> str:
        return f"{self.rule_id}: {self.where}: {self.message}"


def check(root: Path) -> list[Violation]:
    found: list[Violation] = []
    found.extend(check_swift(root))
    found.extend(check_graph(root))
    found.extend(check_versions(root))
    found.extend(check_neutralization(root))
    found.extend(check_workflow(root))
    found.extend(check_references(root))
    found.extend(check_documents(root))
    found.extend(check_waivers(root))
    found.extend(check_todos(root))
    return sorted(found, key=lambda item: (item.rule_id, item.where, item.message))


def check_swift(root: Path) -> list[Violation]:
    found: list[Violation] = []
    graph = load_graph(root / "eng" / "module-graph.txt")
    for path in sorted((root / "Sources").rglob("*.swift")):
        module = path.relative_to(root / "Sources").parts[0]
        text = path.read_text(encoding="utf-8")
        where = str(path.relative_to(root))
        found.extend(generic_names(where, text))
        found.extend(one_primary(where, path.stem, text))
        found.extend(suppressions(where, text))
        found.extend(imports_and_calls(where, module, text, graph))
        found.extend(public_vars(where, text))
        found.extend(unsafe_casts(where, text))
        found.extend(exhaustiveness(where, text))
        for part in path.relative_to(root).parts:
            if part in FORBIDDEN_DIRS:
                found.append(
                    Violation("CNF-001", where, f"ディレクトリ名 {part} は禁止 (SWF-010)")
                )
    return found


def generic_names(where: str, text: str) -> list[Violation]:
    found: list[Violation] = []
    for name in declared_names(text):
        for suffix in FORBIDDEN_SUFFIXES:
            if name == suffix or (
                name.endswith(suffix) and name[-len(suffix)].isupper()
            ):
                found.append(
                    Violation(
                        "CNF-001",
                        where,
                        f"型名 {name} は禁止語尾 {suffix} で終わる (SWF-010)",
                    )
                )
                break
    return found


def declared_names(text: str) -> list[str]:
    names: list[str] = []
    depth = 0
    for line in text.splitlines():
        code = code_only(line)
        if depth == 0 and not code.lstrip().startswith("extension"):
            match = TYPE_DECL.search(code)
            if match:
                names.append(match.group(2))
        depth += code.count("{") - code.count("}")
        if depth < 0:
            depth = 0
    return names


def one_primary(where: str, stem: str, text: str) -> list[Violation]:
    names = declared_names(text)
    if len(names) != 1:
        return [
            Violation(
                "CNF-002",
                where,
                f"主要宣言は 1 つ（実際は {len(names)}）(SWF-011)",
            )
        ]
    if names[0] != stem:
        return [
            Violation(
                "CNF-002",
                where,
                f"ファイル名 {stem} と型名 {names[0]} が一致しない (SWF-011)",
            )
        ]
    return []


def suppressions(where: str, text: str) -> list[Violation]:
    found: list[Violation] = []
    lines = text.splitlines()
    for index, line in enumerate(lines):
        if "swiftlint:disable" not in line and "swift-format-ignore" not in line:
            continue
        if "swiftlint:disable" in line and not re.search(
            r"swiftlint:disable:(next|this|previous)\b", line
        ):
            found.append(
                Violation(
                    "CNF-003",
                    f"{where}:{index + 1}",
                    "ファイル範囲の swiftlint:disable は禁止 (SWF-015)",
                )
            )
            continue
        previous = lines[index - 1] if index else ""
        if not WAIVER_LINE.match(previous):
            found.append(
                Violation(
                    "CNF-003",
                    f"{where}:{index + 1}",
                    "抑制の直前行に Waiver ID が無い (SWF-015)",
                )
            )
    return found


def imports_and_calls(
    where: str, module: str, text: str, graph: dict[str, set[str]]
) -> list[Violation]:
    found: list[Violation] = []
    allowed = {item.lstrip("+") for item in graph.get(module, set())}
    app = module == "NeNeSandApp"
    for index, line in enumerate(text.splitlines(), start=1):
        code = code_only(line)
        if not code.strip():
            continue
        imported = IMPORT_LINE.match(code)
        if imported and imported.group(1) not in allowed:
            rule = "SWF-013" if imported.group(1) == "Dispatch" else "ARC-002"
            tag = "CNF-011" if rule == "ARC-002" else "CNF-010"
            parent = "QLT-006" if rule == "ARC-002" else "SWF-013"
            found.append(
                Violation(
                    tag,
                    f"{where}:{index}",
                    f"{module} は {imported.group(1)} を import できない ({rule}) ({parent})",
                )
            )
        if not app:
            for token in TIME_TOKENS:
                if token.search(code):
                    found.append(
                        Violation(
                            "CNF-010",
                            f"{where}:{index}",
                            f"時刻・乱数・環境の綴りを {module} に書いた (ARC-007)",
                        )
                    )
                    break
        for token in TASK_TOKENS:
            if token.search(code):
                found.append(
                    Violation(
                        "CNF-010",
                        f"{where}:{index}",
                        "Task / Dispatch を書いた (SWF-013)",
                    )
                )
                break
    return found


def public_vars(where: str, text: str) -> list[Violation]:
    found: list[Violation] = []
    for index, line in enumerate(text.splitlines(), start=1):
        code = code_only(line)
        if PUBLIC_VAR.search(code):
            found.append(
                Violation(
                    "CNF-012",
                    f"{where}:{index}",
                    "public / open var は公開状態を可変にする (SWF-003)",
                )
            )
    return found


def unsafe_casts(where: str, text: str) -> list[Violation]:
    found: list[Violation] = []
    for index, line in enumerate(text.splitlines(), start=1):
        code = code_only(line)
        if any(token.search(code) for token in UNSAFE_TOKENS):
            found.append(
                Violation(
                    "CNF-013",
                    f"{where}:{index}",
                    "unsafeBitCast / unsafeDowncast は非公開初期化子を迂回する",
                )
            )
    return found


def exhaustiveness(where: str, text: str) -> list[Violation]:
    found: list[Violation] = []
    for index, line in enumerate(text.splitlines(), start=1):
        code = code_only(line)
        if any(token.search(code) for token in EXHAUSTIVE_TOKENS):
            found.append(
                Violation(
                    "CNF-009",
                    f"{where}:{index}",
                    "switch の default / case _ / @unknown default は網羅性を消す (SWF-002)",
                )
            )
    return found


def check_graph(root: Path) -> list[Violation]:
    graph_path = root / "eng" / "module-graph.txt"
    package_path = root / "Package.swift"
    if not graph_path.is_file() or not package_path.is_file():
        return [Violation("CNF-011", "eng/module-graph.txt", "グラフか Package.swift が無い (ARC-002) (QLT-006)")]
    declared = load_graph(graph_path)
    package = package_path.read_text(encoding="utf-8")
    parsed = parse_package(package)
    found: list[Violation] = []
    executables = [name for name, kind in parsed["kinds"].items() if kind == "executable"]
    if executables != ["NeNeSandApp"]:
        found.append(
            Violation(
                "CNF-011",
                "Package.swift",
                f"実行ターゲットは NeNeSandApp だけ（実際は {executables}）(ARC-002) (QLT-006)",
            )
        )
    expected = {
        name: {dep for dep in deps if not dep.startswith("+")}
        for name, deps in declared.items()
    }
    actual = parsed["deps"]
    if set(actual) != set(expected):
        found.append(
            Violation(
                "CNF-011",
                "Package.swift",
                f"ターゲット集合がグラフと違う (ARC-002) (QLT-006): {sorted(set(actual) ^ set(expected))}",
            )
        )
    for name, deps in expected.items():
        if actual.get(name, set()) != deps:
            found.append(
                Violation(
                    "CNF-011",
                    "Package.swift",
                    f"{name} の依存がグラフと違う (ARC-002) (QLT-006)",
                )
            )
    if PACKAGE_URL in package:
        found.append(
            Violation("QLT-011", "Package.swift", "外部パッケージ依存は ADR と許可リストが揃うまで足さない")
        )
    return found


def check_versions(root: Path) -> list[Violation]:
    found: list[Violation] = []
    version_file = root / ".swift-version"
    package = root / "Package.swift"
    if not version_file.is_file():
        return [Violation("CNF-007", ".swift-version", "Swift の版を書くファイルが無い")]
    version = version_file.read_text(encoding="utf-8").strip()
    major_minor = ".".join(version.split(".")[:2])
    text = package.read_text(encoding="utf-8") if package.is_file() else ""
    if f"swift-tools-version: {major_minor}" not in text:
        found.append(
            Violation(
                "CNF-007",
                "Package.swift",
                f"tools-version が .swift-version の {major_minor} と一致しない",
            )
        )
    if WARNINGS_AS_ERRORS not in text:
        found.append(Violation("QLT-002", "Package.swift", "警告をエラーにする指定が Package.swift に無い"))
    mentioned = combined_build_text(root)
    for name in (".swift-version", ".swiftlint.yml", ".swift-format", "eng/module-graph.txt", "eng/tool-versions.txt", "eng/conformance.py"):
        if not (root / name).is_file():
            found.append(Violation("CNF-007", name, "宣言した設定ファイルが無い"))
            continue
        if Path(name).name not in mentioned and name not in mentioned:
            found.append(Violation("CNF-007", name, "設定ファイルをビルドが参照していない"))
    pinned = (root / "eng" / "tool-versions.txt").read_text(encoding="utf-8")
    for line in pinned.splitlines():
        if "=" not in line:
            continue
        value = line.split("=", 1)[1].strip()
        if value and value in build_script_text(root):
            found.append(
                Violation(
                    "CNF-007",
                    "eng/tool-versions.txt",
                    "道具の版の値を Makefile かワークフローに重複して書いた",
                )
            )
    if version and version in build_script_text(root):
        found.append(
            Violation("CNF-007", ".swift-version", "Swift の版の値を Makefile かワークフローに重複して書いた")
        )
    return found


def check_neutralization(root: Path) -> list[Violation]:
    found: list[Violation] = []
    needles = (BASELINE_FLAG, SUPPRESS_WARNINGS, IGNORE_FAILURES, "new-from-" + "rev")
    for path in iter_text_files(root):
        if path.suffix == ".md" or path.name == "conformance.py" or path.name.startswith("test_"):
            continue
        name = path.name.lower()
        if "baseline" in name:
            found.append(Violation("CNF-005", str(path.relative_to(root)), "baseline を名に含むファイルは禁止 (QLT-003)"))
        text = path.read_text(encoding="utf-8", errors="replace")
        for needle in needles:
            if needle in text:
                found.append(
                    Violation(
                        "CNF-005",
                        str(path.relative_to(root)),
                        f"ゲートを無力化する綴り {needle} がある (QLT-003)",
                    )
                )
                break
    lint = root / ".swiftlint.yml"
    if lint.is_file():
        lint_text = lint.read_text(encoding="utf-8")
        if re.search(r"(?m)^excluded\s*:", lint_text) or "disabled_rules" in lint_text:
            found.append(
                Violation("CNF-005", ".swiftlint.yml", "ディレクトリ除外か disabled_rules は禁止 (QLT-003)")
            )
    return found


def check_workflow(root: Path) -> list[Violation]:
    path = root / ".github" / "workflows" / "ci.yml"
    if not path.is_file():
        return [Violation("QLT-001", ".github/workflows/ci.yml", "CI が無い (QLT-005)")]
    text = path.read_text(encoding="utf-8")
    found: list[Violation] = []
    if "contents: read" not in text or "contents: write" in text:
        found.append(Violation("QLT-001", ".github/workflows/ci.yml", "permissions は contents: read だけ (QLT-005)"))
    if "make check" not in text:
        found.append(Violation("QLT-001", ".github/workflows/ci.yml", "CI は make check を呼ぶ (QLT-005)"))
    if "draft == false" not in text:
        found.append(Violation("QLT-012", ".github/workflows/ci.yml", "draft の間はゲートを回さない"))
    for command in QUALITY_COMMANDS:
        if command in text:
            found.append(
                Violation(
                    "QLT-001",
                    ".github/workflows/ci.yml",
                    f"品質判断 {command} をワークフローに書いた (QLT-005)",
                )
            )
    uses = re.findall(r"uses:\s*(\S+)", text)
    for use in uses:
        if "@" not in use or re.search(r"@(v?\d+|main|master)$", use):
            found.append(Violation("QLT-001", ".github/workflows/ci.yml", f"アクション {use} を SHA で固定していない (QLT-005)"))
    return found


def check_references(root: Path) -> list[Violation]:
    return []


def check_documents(root: Path) -> list[Violation]:
    definitions: dict[str, str] = {}
    body_status: dict[str, str] = {}
    references: list[tuple[str, str]] = []
    found: list[Violation] = []
    for path in sorted(root.rglob("*.md")):
        if hidden(path):
            continue
        text = path.read_text(encoding="utf-8")
        rel = str(path.relative_to(root))
        lines = text.splitlines()
        for index, line in enumerate(lines):
            heading = HEADING.match(line)
            if heading:
                rule = heading.group(1)
                if rule in definitions:
                    found.append(Violation("CNF-006", rel, f"{rule} を {definitions[rule]} と重複定義した"))
                else:
                    definitions[rule] = rel
                    body_status[rule] = first_status(lines[index + 1 :])
            for rule in RULE_ID.findall(line):
                references.append((rel, rule))
        if rel == "docs/QUALITY_GATES.md":
            matrix = matrix_statuses(text)
            for rule, status in matrix.items():
                if rule not in definitions:
                    found.append(Violation("CNF-006", rel, f"マトリクスの {rule} に定義が無い"))
                elif body_status.get(rule) != status:
                    found.append(
                        Violation(
                            "CNF-006",
                            rel,
                            f"{rule} の本文は {body_status.get(rule)}、マトリクスは {status}",
                        )
                    )
            for rule in definitions:
                if rule not in matrix:
                    found.append(Violation("CNF-006", definitions[rule], f"{rule} がマトリクスに無い"))
            proofs = proof_ids(root / "docs" / "quality" / "gate-proofs.md")
            for rule, status in matrix.items():
                if status == "active" and rule not in proofs:
                    found.append(Violation("CNF-006", "docs/quality/gate-proofs.md", f"active の {rule} に証明行が無い"))
            for rule in proofs:
                if rule not in definitions:
                    found.append(Violation("CNF-006", "docs/quality/gate-proofs.md", f"証明行の {rule} は未定義"))
    defined = set(definitions)
    for rel, rule in references:
        if rule not in defined:
            found.append(Violation("CNF-006", rel, f"未定義の {rule} を参照している"))
    return found


def check_waivers(root: Path) -> list[Violation]:
    found: list[Violation] = []
    waiver_dir = root / "docs" / "waivers"
    if not waiver_dir.is_dir():
        return [Violation("CNF-004", "docs/waivers", "waiver 台帳が無い (SWF-015)")]
    index = (waiver_dir / "README.md").read_text(encoding="utf-8") if (waiver_dir / "README.md").is_file() else ""
    today = __import__("datetime").date.today()
    known: set[str] = set()
    for path in sorted(waiver_dir.glob("WVR-*.md")):
        if path.name.startswith("0000"):
            continue
        match = re.match(r"(WVR-\d{4})-[a-z0-9-]+\.md$", path.name)
        if not match:
            found.append(Violation("CNF-004", path.name, "waiver のファイル名が WVR-NNNN-kebab.md ではない (SWF-015)"))
            continue
        waiver_id = match.group(1)
        known.add(waiver_id)
        text = path.read_text(encoding="utf-8")
        if f"Rule:" not in text or "Expires:" not in text or "Scope:" not in text:
            found.append(Violation("CNF-004", path.name, "Rule / Expires / Scope が欠けている (SWF-015)"))
        expires = re.search(r"Expires:\s*(\d{4}-\d{2}-\d{2})", text)
        if not expires:
            found.append(Violation("CNF-004", path.name, "期限が YYYY-MM-DD ではない (SWF-015)"))
        else:
            year, month, day = (int(part) for part in expires.group(1).split("-"))
            if __import__("datetime").date(year, month, day) < today:
                found.append(Violation("CNF-004", path.name, "期限切れの waiver (SWF-015)"))
        rule = re.search(r"Rule:\s*`((?:ARC|SWF|QLT|CNF|GIT)-\d{3})`", text)
        if not rule:
            found.append(Violation("CNF-004", path.name, "Rule が実在する規則 ID ではない (SWF-015)"))
        if waiver_id not in index:
            found.append(Violation("CNF-004", "docs/waivers/README.md", f"{waiver_id} が索引に無い (SWF-015)"))
    for path in (root / "Sources").rglob("*.swift"):
        lines = path.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            marker = WAIVER_LINE.match(line)
            if not marker:
                continue
            waiver_id = marker.group(1)
            if waiver_id not in known:
                found.append(
                    Violation(
                        "CNF-004",
                        f"{path.relative_to(root)}:{index + 1}",
                        f"{waiver_id} は台帳に無い (SWF-015)",
                    )
                )
    return found


def check_todos(root: Path) -> list[Violation]:
    found: list[Violation] = []
    for path in iter_text_files(root):
        if path.suffix not in {".swift", ".py", ".yml", ".yaml", ".sh"} and path.name != "Makefile":
            continue
        if path.name.startswith("test_"):
            continue
        for index, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            if any(word in line for word in ("TO" + "DO", "FIX" + "ME")) and not re.search(
            r"#[1-9][0-9]*", line
        ):
                found.append(
                    Violation(
                        "CNF-008",
                        f"{path.relative_to(root)}:{index}",
                        "未完了の印には Issue 番号が要る",
                    )
                )
    return found


def load_graph(path: Path) -> dict[str, set[str]]:
    graph: dict[str, set[str]] = {}
    if not path.is_file():
        return graph
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        graph[parts[0]] = set(parts[1:])
    return graph


def parse_package(text: str) -> dict[str, object]:
    deps: dict[str, set[str]] = {}
    kinds: dict[str, str] = {}
    for match in re.finditer(r"\.(executableTarget|target)\(", text):
        kind = "executable" if match.group(1) == "executableTarget" else "library"
        body, _end = balanced(text, match.end() - 1)
        name_match = NAME_FIELD.search(body)
        if not name_match:
            continue
        name = name_match.group(1)
        dep_match = DEPS_FIELD.search(body)
        dep_names = set(QUOTED.findall(dep_match.group(1))) if dep_match else set()
        deps[name] = dep_names
        kinds[name] = kind
    return {"deps": deps, "kinds": kinds}


def balanced(text: str, open_index: int) -> tuple[str, int]:
    depth = 0
    for index in range(open_index, len(text)):
        if text[index] == "(":
            depth += 1
        elif text[index] == ")":
            depth -= 1
            if depth == 0:
                return text[open_index : index + 1], index
    return text[open_index:], len(text)


def first_status(lines: list[str]) -> str | None:
    for line in lines:
        if line.startswith("### "):
            return None
        match = STATUS.search(line)
        if match:
            return match.group(1)
    return None


def matrix_statuses(text: str) -> dict[str, str]:
    lines = text.splitlines()
    start = next((i for i, line in enumerate(lines) if line.startswith("## 3. 強制マトリクス")), None)
    if start is None:
        return {}
    statuses: dict[str, str] = {}
    for line in lines[start + 1 :]:
        if line.startswith("## "):
            break
        match = MATRIX_ROW.match(line)
        if match:
            statuses[match.group(1)] = match.group(2).strip()
    return statuses


def proof_ids(path: Path) -> set[str]:
    if not path.is_file():
        return set()
    return {match.group(1) for line in path.read_text(encoding="utf-8").splitlines() if (match := PROOF_ROW.match(line))}


def combined_build_text(root: Path) -> str:
    chunks = []
    for name in ("Makefile", "eng/run_build.py", "eng/run_format.py", "eng/run_lint.py", "eng/run_tests.py"):
        path = root / name
        if path.is_file():
            chunks.append(path.read_text(encoding="utf-8"))
    workflow = root / ".github" / "workflows" / "ci.yml"
    if workflow.is_file():
        chunks.append(workflow.read_text(encoding="utf-8"))
    return "\n".join(chunks)


def hidden(path: Path) -> bool:
    for part in path.parts:
        if part in SKIP_DIRS:
            return True
        if part.startswith(".") and part != ".github":
            return True
    return False


def build_script_text(root: Path) -> str:
    chunks = []
    makefile = root / "Makefile"
    workflow = root / ".github" / "workflows" / "ci.yml"
    if makefile.is_file():
        chunks.append(makefile.read_text(encoding="utf-8"))
    if workflow.is_file():
        chunks.append(workflow.read_text(encoding="utf-8"))
    return "\n".join(chunks)


def iter_text_files(root: Path):
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if hidden(path) or path.suffix in {".png", ".zip", ".o"}:
            continue
            continue
        yield path


def code_only(line: str) -> str:
    if "//" in line:
        return line.split("//", 1)[0]
    return line


def main() -> int:
    if len(sys.argv) > 1 and Path(sys.argv[1]) != Path("eng/module-graph.txt"):
        print("CNF-007: eng/module-graph.txt: 引数は eng/module-graph.txt だけ")
        return 1
    found = check(Path.cwd())
    for item in found:
        print(item.format())
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
