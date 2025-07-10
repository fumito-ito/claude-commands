#!/bin/bash

# Test script for both features with default settings

set -e

# Import test library
source dev-container-features-test-lib

# Test that gemini-cli is installed
check "gemini-cli version" bash -c "gemini --version"

# Test that .claude directory exists
check "claude directory exists" test -d "/workspaces/.claude"

# Test that the repository content was cloned into .claude directory
check "repository content exists" test -n "$(ls -A /workspaces/.claude 2>/dev/null || echo '')"

# Test that cache directory exists (for runtime deployment)
check "repository cache exists" test -d "/tmp/claude-repo-cache"

# Test that the runtime setup script exists
check "runtime setup script exists" test -f "/usr/local/bin/claude-setup.sh"

# Report results
reportResults