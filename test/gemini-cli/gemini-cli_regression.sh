#!/bin/bash

# Regression test for gemini-cli

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

# Test that multiple invocations work (regression test)
check "multiple version calls work" bash -c "gemini --version && gemini --version"

# Test that the installation doesn't break basic system functionality
check "basic commands still work" bash -c "ls / && pwd && echo 'system functional'"

# Report result
reportResults