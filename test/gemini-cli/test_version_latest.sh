#!/bin/bash

# This test file will be executed against the scenario "gemini-cli_latest_version"

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for latest version
check "gemini command exists" bash -c "command -v gemini"
check "gemini is executable" bash -c "test -x /usr/local/bin/gemini"
check "gemini version command works" bash -c "gemini --version"

# Check that we got a reasonable version string
check "gemini version output contains version info" bash -c "gemini --version | grep -E '(v[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+\.[0-9]+|version|Gemini)'"

# Verify the binary is properly installed
check "gemini binary exists in correct location" bash -c "test -f /usr/local/bin/gemini"
check "gemini binary has correct permissions" bash -c "ls -la /usr/local/bin/gemini | grep -q '^-rwxr-xr-x'"

# Test that basic functionality works
check "gemini help shows usage information" bash -c "gemini --help | grep -i -E '(usage|command|option)'"

# Test that the installation didn't leave temporary files
check "no temporary installation files left" bash -c "! test -d /tmp/gemini-cli-install"

echo "Latest version tests passed!"

# Report result
reportResults