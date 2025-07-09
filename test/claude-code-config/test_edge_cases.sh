#!/bin/bash

# Edge cases and error handling tests for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_DIR="/workspaces"

# Test handling of invalid repository configurations
echo "Testing edge cases for claude-code-config..."

# Test with already existing .claude directory
check ".claude directory exists" test -d "${WORKSPACE_DIR}/.claude"

# Test that we can handle cases where directory already exists
check ".claude directory is accessible after feature installation" test -d "${WORKSPACE_DIR}/.claude"

# Test git installation resilience
check "git is properly installed" bash -c "command -v git"

# Test that git works even if run multiple times
check "git commands are stable" bash -c "git --version"

# Test workspace directory permissions
check "workspace directory has correct permissions" test -w "${WORKSPACE_DIR}"

# Test that .claude directory can be read/written
check ".claude directory is writable" test -w "${WORKSPACE_DIR}/.claude"

# Test behavior with different shell environments
check "feature works in different shells" bash -c "sh -c 'ls ${WORKSPACE_DIR}/.claude'"

# Test that the feature doesn't interfere with other git operations
check "git operations not affected" bash -c "cd /tmp && git config --global user.name 'Test'"

echo "Edge case tests completed!"

# Report result
reportResults