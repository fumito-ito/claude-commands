#!/bin/bash

# This test file will be executed against the scenario in scenarios.json
# The test should verify the feature works as expected

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that codex CLI is installed
check "codex command exists" command -v codex

# Test that node is installed (required for codex)
check "node command exists" command -v node

# Test that codex shows version
check "codex shows version" bash -c "codex --version"

# Test that codex is installed globally via npm
check "codex binary exists" command -v codex

# Test that codex is executable
check "codex is executable" test -x "$(command -v codex)"

# Test that codex help works
check "codex help works" bash -c "codex --help"

# Report result
reportResults