SHELL := /bin/bash

SWIFTLINT_VERSION := $(shell awk -F= '$$1=="swiftlint" {print $$2}' eng/tool-versions.txt)
SWIFTLINT_SHA256 := $(shell awk -F= '$$1=="swiftlint_sha256" {print $$2}' eng/tool-versions.txt)

.PHONY: check

check: .tools/swiftlint
	python3 eng/conformance.py eng/module-graph.txt
	python3 eng/run_tests.py
	python3 eng/commit_message.py --check
	python3 eng/run_build.py
	python3 eng/run_swift_tests.py
	python3 eng/run_format.py
	python3 eng/run_lint.py

.tools/swiftlint: eng/tool-versions.txt
	mkdir -p .tools
	curl -fsSL -o .tools/swiftlint.zip "https://github.com/realm/SwiftLint/releases/download/$(SWIFTLINT_VERSION)/swiftlint_linux_amd64.zip"
	echo "$(SWIFTLINT_SHA256)  .tools/swiftlint.zip" | sha256sum -c -
	unzip -p .tools/swiftlint.zip swiftlint-static > .tools/swiftlint
	chmod 755 .tools/swiftlint
	rm -f .tools/swiftlint.zip
