import unittest

import commit_message


class CommitMessageTests(unittest.TestCase):
    def test_accepts_japanese_subject(self) -> None:
        self.assertEqual(
            commit_message.subject_errors("build(gate): 厳格規約の足場を固定する (#1)"),
            [],
        )

    def test_rejects_english_description(self) -> None:
        errors = commit_message.subject_errors("build(gate): pin the gate (#1)")
        self.assertTrue(any(item.startswith("GIT-003") for item in errors))

    def test_rejects_missing_issue(self) -> None:
        errors = commit_message.subject_errors("build: 足場を固定する")
        self.assertTrue(any(item.startswith("GIT-003") for item in errors))

    def test_branch_shape(self) -> None:
        self.assertEqual(commit_message.branch_errors("build/1-strict-foundation"), [])
        self.assertEqual(commit_message.branch_errors("main"), [])
        errors = commit_message.branch_errors("feature-branch")
        self.assertTrue(any(item.startswith("GIT-002") for item in errors))


if __name__ == "__main__":
    unittest.main()
