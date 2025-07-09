#!/bin/bash

# Docker-specific test for gemini-cli

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

# Docker-specific checks
check "container user can run gemini" bash -c "whoami && gemini --version"

# Test that the installation works in container environment
check "PATH includes gemini" bash -c "which gemini"

# Report result
reportResults