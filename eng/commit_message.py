"""Validate branch names, commit subjects, and the PR title."""

from __future__ import annotations

import os
import re
import subprocess
import sys

SUBJECT = re.compile(
    r"^(feat|fix|docs|refactor|test|build|ci|chore)"
    r"(?:\([a-z0-9-]+\))?(!)?: (.+) \(#([1-9][0-9]*)\)$"
)
BRANCH = re.compile(
    r"^(feat|fix|docs|refactor|test|build|ci|chore)/[1-9][0-9]*-[a-z0-9]+(?:-[a-z0-9]+)*$"
)
JAPANESE = re.compile(r"[\u3040-\u30ff\u3400-\u9fff]")
SUBJECT_LIMIT = 100


def subject_errors(line: str) -> list[str]:
    if len(line) > SUBJECT_LIMIT:
        return ["GIT-003: 件名が 100 文字を超えている"]
    match = SUBJECT.match(line)
    if not match:
        return ["GIT-003: 件名は type(scope): 日本語 (#N) の形にする"]
    if not JAPANESE.search(match.group(3)):
        return ["GIT-003: 説明は日本語で書く"]
    return []


def branch_errors(name: str) -> list[str]:
    if name in {"main", "master"}:
        return []
    if not BRANCH.match(name):
        return [f"GIT-002: ブランチ名 {name} は type/番号-kebab にする"]
    return []


def message_errors(text: str) -> list[str]:
    subject = text.splitlines()[0] if text.splitlines() else ""
    return subject_errors(subject)


def git(args: list[str]) -> str:
    completed = subprocess.run(["git", *args], check=True, capture_output=True, text=True)
    return completed.stdout.strip()


def current_branch() -> str:
    override = os.environ.get("PR_HEAD", "").strip()
    if override:
        return override
    return git(["rev-parse", "--abbrev-ref", "HEAD"])


def commit_subjects() -> list[str]:
    base = os.environ.get("BASE_SHA", "").strip()
    if not base:
        base = "origin/main"
        verify = subprocess.run(["git", "rev-parse", "--verify", base], capture_output=True, text=True)
        if verify.returncode != 0:
            base = "main"
    output = git(["log", "--format=%s", f"{base}..HEAD"])
    return [line for line in output.splitlines() if line]


def check_repository() -> list[str]:
    found = branch_errors(current_branch())
    for subject in commit_subjects():
        found.extend(subject_errors(subject))
    title = os.environ.get("PR_TITLE", "").strip()
    if title:
        found.extend(subject_errors(title))
    return found


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] == "--message-file":
        text = open(sys.argv[2], encoding="utf-8").read()
        found = message_errors(text)
    else:
        found = check_repository()
    for item in found:
        print(item)
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
