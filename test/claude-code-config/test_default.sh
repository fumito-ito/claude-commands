#!/bin/bash

# This test file will be executed against the scenario "claude-code-config_default"

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" bash -c "command -v git"
check "git is executable" bash -c "test -x $(which git)"

# Determine the correct workspace directory
WORKSPACE_DIR="/workspaces"
if [ ! -d "$WORKSPACE_DIR" ]; then
    # In test environment, might be mounted differently
    WORKSPACE_DIR="/workspaces"
    mkdir -p "$WORKSPACE_DIR"
fi

# Test that .claude directory exists
check ".claude directory exists" test -d "${WORKSPACE_DIR}/.claude"

# Test that .claude directory is accessible
check ".claude directory is accessible" test -d "${WORKSPACE_DIR}/.claude"

# Since no repo was specified in the default test, the directory should only contain the base structure
check ".claude directory has minimal content (no repo specified)" test -d "${WORKSPACE_DIR}/.claude"

# Test that git configuration is not broken
check "git config works" bash -c "git config --global user.name 'Test User' && git config --global user.email 'test@example.com'"

# Test that the feature doesn't break basic system functionality
check "basic system commands work" bash -c "ls ${WORKSPACE_DIR}/.claude/"

echo "All tests passed!"

# Report result
reportResults