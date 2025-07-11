#!/bin/bash

# Test script for all features on Debian base image

set -e

# Import test library
source dev-container-features-test-lib

# Test that gemini-cli is installed
check "gemini-cli version" bash -c "gemini --version"

# Test that codex-cli is installed
check "codex-cli version" bash -c "codex --version"

# Test that .claude directory exists
check "claude directory exists" test -d "/workspaces/.claude"

# Test that the repository content was cloned into .claude directory
check "repository content exists" test -n "$(ls -A /workspaces/.claude 2>/dev/null || echo '')"

# Test that cache directory exists (for runtime deployment)
check "repository cache exists" test -d "/tmp/claude-repo-cache"

# Test that the runtime setup script exists
check "runtime setup script exists" test -f "/usr/local/bin/claude-setup.sh"

# Test that both CLI tools are executable
check "gemini is executable" test -x "$(command -v gemini)"
check "codex is executable" test -x "$(command -v codex)"

# Test that Node.js is installed (required for both CLI tools)
check "node command exists" command -v node

# Report results
reportResults