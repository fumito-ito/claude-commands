#!/bin/bash

# This test file will be executed against the scenario in scenarios.json
# Test for gemini-cli with latest version explicitly specified

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that gemini CLI is installed
check "gemini command exists" command -v gemini

# Test that node is installed (required for gemini)
check "node command exists" command -v node

# Test that gemini shows version
check "gemini shows version" bash -c "gemini --version"

# Test that gemini binary exists and is executable
check "gemini binary is executable" test -x "$(command -v gemini)"

# Test that the version is the latest nightly or stable release
check "version contains expected format" bash -c "gemini --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+'"

# Report result
reportResults