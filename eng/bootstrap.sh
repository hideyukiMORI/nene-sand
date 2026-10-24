#!/bin/bash
# Point this clone at the repository-owned hooks. Does not change global git config.
cd "$(dirname "$0")/.."
git config core.hooksPath .githooks
