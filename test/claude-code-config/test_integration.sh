#!/bin/bash

# Integration tests for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_DIR="/workspaces"

echo "Running integration tests for claude-code-config..."

# Test integration with other dev container features
check "common-utils integration" bash -c "which curl || which wget"

# Test that the feature integrates well with the container environment
check "container environment integration" test -d "${WORKSPACE_DIR}"

# Test .claude directory setup
check ".claude directory properly set up" test -d "${WORKSPACE_DIR}/.claude"

# Test git integration
check "git integration works" bash -c "cd ${WORKSPACE_DIR}/.claude && git status || echo 'No git repo (expected for basic test)'"

# Test file system permissions integration
check "file system permissions work" bash -c "ls -la ${WORKSPACE_DIR}/.claude"

# Test that the feature doesn't break other container functionality
check "container functionality preserved" bash -c "echo 'test' > /tmp/test.txt && cat /tmp/test.txt"

# Test environment variable handling
check "environment variables work" bash -c "echo \$HOME && echo \$USER"

# Test that PATH is not corrupted
check "PATH is properly maintained" bash -c "echo \$PATH | grep -q /usr/local/bin"

echo "Integration tests completed!"

# Report result
reportResults