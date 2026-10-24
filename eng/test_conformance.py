import tempfile
import textwrap
import unittest
from pathlib import Path

import conformance


def ids(found: list[conformance.Violation]) -> set[str]:
    return {item.rule_id for item in found}


class SwiftRuleTests(unittest.TestCase):
    def test_generic_name(self) -> None:
        found = conformance.generic_names("Sources/NeNeSandCore/TimeHelper.swift", "struct TimeHelper {}\n")
        self.assertIn("CNF-001", ids(found))
        self.assertIn("SWF-010", found[0].message)

    def test_one_primary(self) -> None:
        text = "enum Alpha {}\nenum Beta {}\n"
        found = conformance.one_primary("Sources/NeNeSandCore/Alpha.swift", "Alpha", text)
        self.assertIn("CNF-002", ids(found))

    def test_filename_must_match(self) -> None:
        found = conformance.one_primary("Sources/NeNeSandCore/Other.swift", "Other", "enum Alpha {}\n")
        self.assertIn("CNF-002", ids(found))

    def test_suppression_needs_previous_waiver(self) -> None:
        text = "// swiftlint:disable:next force_unwrapping\nlet value = optional!\n"
        found = conformance.suppressions("Sources/NeNeSandCore/Sample.swift", text)
        self.assertIn("CNF-003", ids(found))

    def test_file_disable_is_rejected(self) -> None:
        text = "// Waiver: WVR-0001\n// swiftlint:disable all\n"
        found = conformance.suppressions("Sources/NeNeSandCore/Sample.swift", text)
        self.assertIn("CNF-003", ids(found))

    def test_switch_default(self) -> None:
        text = "enum Paint { case sand }\nfunc code(_ paint: Paint) -> Int {\n  switch paint {\n  default:\n    return 0\n  }\n}\n"
        found = conformance.exhaustiveness("Sources/NeNeSandCore/Paint.swift", text)
        self.assertIn("CNF-009", ids(found))
        self.assertIn("SWF-002", found[0].message)

    def test_public_var(self) -> None:
        found = conformance.public_vars("Sources/NeNeSandCore/Cell.swift", "public struct Cell { public var kind: Int }\n")
        self.assertIn("CNF-012", ids(found))

    def test_private_set_is_allowed(self) -> None:
        found = conformance.public_vars(
            "Sources/NeNeSandCore/Cell.swift",
            "public struct Cell { public private(set) var heat: Int }\n",
        )
        self.assertEqual(found, [])

    def test_core_rejects_date_and_app_allows_it(self) -> None:
        graph = {"NeNeSandCore": set(), "NeNeSandApp": {"Foundation", "NeNeSandCore"}}
        denied = conformance.imports_and_calls(
            "Sources/NeNeSandCore/Clock.swift",
            "NeNeSandCore",
            "func stamp() -> Date { Date() }\n",
            graph,
        )
        self.assertIn("CNF-010", ids(denied))
        self.assertTrue(any("ARC-007" in item.message for item in denied))
        allowed = conformance.imports_and_calls(
            "Sources/NeNeSandApp/Clock.swift",
            "NeNeSandApp",
            "import Foundation\nfunc stamp() -> Date { Date() }\n",
            graph,
        )
        self.assertFalse(any("ARC-007" in item.message for item in allowed))

    def test_dispatch_is_rejected_in_the_app(self) -> None:
        graph = {"NeNeSandApp": {"Foundation"}}
        found = conformance.imports_and_calls(
            "Sources/NeNeSandApp/Loop.swift",
            "NeNeSandApp",
            "import Dispatch\n",
            graph,
        )
        self.assertTrue(any("SWF-013" in item.message for item in found))

    def test_unsafe_bitcast(self) -> None:
        found = conformance.unsafe_casts("Sources/NeNeSandCore/Token.swift", "let value = unsafeBitCast(1, to: Token.self)\n")
        self.assertIn("CNF-013", ids(found))


class GraphTests(unittest.TestCase):
    def test_package_parser_reads_this_repository(self) -> None:
        text = Path("Package.swift").read_text(encoding="utf-8")
        parsed = conformance.parse_package(text)
        self.assertEqual(parsed["deps"]["NeNeSandSave"], {"NeNeSandCore"})
        self.assertEqual(parsed["kinds"]["NeNeSandApp"], "executable")


class DocumentTests(unittest.TestCase):
    def test_undefined_reference_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            docs = root / "docs"
            docs.mkdir()
            (docs / "ARCHITECTURE_CONSTITUTION.md").write_text(
                "### ARC-001 — 見本\n\n- 機械強制: **planned**\n",
                encoding="utf-8",
            )
            (docs / "QUALITY_GATES.md").write_text(
                "## 3. 強制マトリクス\n\n| 規則 | 状態 | 実体 |\n| --- | --- | --- |\n| ARC-001 | planned | 見本 |\n",
                encoding="utf-8",
            )
            (docs / "quality").mkdir()
            (docs / "quality" / "gate-proofs.md").write_text("| ARC-999 | 未定義 |\n", encoding="utf-8")
            (docs / "waivers").mkdir()
            (docs / "waivers" / "README.md").write_text("なし\n", encoding="utf-8")
            found = conformance.check_documents(root)
            self.assertIn("CNF-006", ids(found))


if __name__ == "__main__":
    unittest.main()
