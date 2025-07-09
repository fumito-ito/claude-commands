#!/bin/bash

# Test for gemini-cli on Alpine Linux base image

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that gemini CLI is installed
check "gemini command exists" command -v gemini

# Test that node is installed (required for gemini)
check "node command exists" command -v node

# Test that gemini shows version
check "gemini shows version" bash -c "gemini --version"

# Test that apk is available (Alpine-specific)
check "apk command exists" command -v apk

# Test that gemini binary exists and is executable
check "gemini binary is executable" test -x "$(command -v gemini)"

# Report result
reportResults