#!/bin/bash

# Performance test for gemini-cli

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that gemini CLI is installed
check "gemini command exists" command -v gemini

# Test that node is installed (required for gemini)
check "node command exists" command -v node

# Test that gemini shows version quickly (performance check)
check "gemini version response time" bash -c "timeout 10 gemini --version"

# Test that gemini binary exists and is executable
check "gemini binary is executable" test -x "$(command -v gemini)"

# Test that npm installation is reasonable
check "npm global installation exists" bash -c "test -d /usr/lib/node_modules/@google/gemini-cli"

# Report result
reportResults