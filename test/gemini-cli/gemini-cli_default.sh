#!/bin/bash

# This test file will be executed against the scenario in scenarios.json
# The test should verify the feature works as expected

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that gemini CLI is installed
check "gemini command exists" command -v gemini

# Test that node is installed (required for gemini)
check "node command exists" command -v node

# Test that gemini shows version
check "gemini shows version" bash -c "gemini --version"

# Test that gemini is installed globally via npm
check "gemini binary exists" command -v gemini

# Test that gemini is executable
check "gemini is executable" test -x "$(command -v gemini)"

# Report result
reportResults