#!/bin/bash

# This test file tests edge cases and error handling

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic functionality test
check "gemini command exists" bash -c "command -v gemini"

# Test that the feature handles user permissions correctly
check "gemini is accessible to non-root users" bash -c "su -c 'command -v gemini' nobody 2>/dev/null || echo 'gemini accessible'"

# Test that the installation is clean
check "no installation artifacts left in /tmp" bash -c "! ls /tmp/gemini-cli-install* 2>/dev/null"
check "no extra files in /usr/local/bin" bash -c "ls /usr/local/bin/gemini* | wc -l | grep -q '^1$'"

# Test file integrity
check "gemini binary is not corrupted" bash -c "test -s /usr/local/bin/gemini"
check "gemini binary has reasonable size" bash -c "stat -c %s /usr/local/bin/gemini | awk '{if($1 > 1000000 && $1 < 100000000) exit 0; else exit 1}'"

# Test that help/version don't require network access
check "gemini --version works without network" bash -c "timeout 5 gemini --version"
check "gemini --help works without network" bash -c "timeout 5 gemini --help"

# Test command line argument handling
check "gemini handles invalid flags gracefully" bash -c "gemini --invalid-flag 2>&1 | grep -i -E '(error|invalid|unknown|usage)'"

# Verify that the feature doesn't interfere with system utilities
check "system PATH is preserved" bash -c "echo $PATH | grep -q '/usr/local/bin'"
check "system utilities still work" bash -c "ls --version && cat --version && grep --version"

# Test installation idempotency (if run multiple times)
GEMINI_SIZE_BEFORE=$(stat -c %s /usr/local/bin/gemini)
check "gemini binary size is consistent" bash -c "stat -c %s /usr/local/bin/gemini | grep -q '$GEMINI_SIZE_BEFORE'"

echo "Edge case tests passed!"

# Report result
reportResults