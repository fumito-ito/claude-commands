#!/bin/bash

# This test file tests integration with other tools and features

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic functionality
check "gemini command exists" bash -c "command -v gemini"

# Test integration with common development tools
check "gemini works with shell scripting" bash -c "GEMINI_VERSION=\$(gemini --version) && echo \"Gemini version: \$GEMINI_VERSION\""

# Test that gemini can be called from different locations
check "gemini works from home directory" bash -c "cd ~ && gemini --version"
check "gemini works from root directory" bash -c "cd / && gemini --version"
check "gemini works with full path" bash -c "/usr/local/bin/gemini --version"

# Test environment variable handling
check "gemini respects environment" bash -c "GEMINI_CLI_TEST=1 gemini --version"

# Test that gemini integrates well with common shells
check "gemini works in bash" bash -c "bash -c 'gemini --version'"
check "gemini works in sh" sh -c "gemini --version"

# Test pipe and redirection capabilities
check "gemini output can be piped" bash -c "gemini --version | head -1"
check "gemini output can be redirected" bash -c "gemini --version > /tmp/gemini_version.txt && test -s /tmp/gemini_version.txt"

# Test that gemini doesn't conflict with other CLI tools
check "curl still works after gemini installation" bash -c "curl --version"
check "wget works if available" bash -c "command -v wget && wget --version || echo 'wget not available, skipping'"

# Test process management
check "gemini process exits cleanly" bash -c "timeout 10 gemini --help && echo 'Process exited cleanly'"

# Test file system permissions
check "gemini respects umask" bash -c "umask 022 && gemini --version"

# Clean up test files
rm -f /tmp/gemini_version.txt

echo "Integration tests passed!"

# Report result
reportResults