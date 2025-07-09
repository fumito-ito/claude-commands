#!/bin/bash

# This test file will be executed against the scenario "gemini-cli_default"

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "gemini command exists" bash -c "command -v gemini"
check "gemini is executable" bash -c "test -x /usr/local/bin/gemini"
check "gemini version command works" bash -c "gemini --version"
check "gemini help command works" bash -c "gemini --help"
check "gemini binary location" bash -c "which gemini | grep -q '/usr/local/bin/gemini'"

# Check that the binary has proper permissions
check "gemini has execute permissions for all users" bash -c "ls -la /usr/local/bin/gemini | grep -q '^-rwxr-xr-x'"

# Verify gemini responds to basic commands (without requiring API key)
check "gemini shows help when run without args" bash -c "gemini 2>&1 | grep -i -E '(usage|help|command)'"

# Test that the feature doesn't break basic system functionality
check "curl still works" bash -c "curl --version"
check "basic system commands work" bash -c "ls /usr/local/bin/"

echo "All tests passed!"

# Report result
reportResults