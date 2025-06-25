#!/bin/bash

# This test file will be executed against the feature.
# It will test the basic functionality of the claude-commands feature.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
echo "Testing claude-commands feature..."

# Test that git is installed
check "git is installed" which git

# Determine the correct workspace directory
WORKSPACE_DIR="/workspaces"
if [ ! -d "$WORKSPACE_DIR" ]; then
    # In test environment, might be mounted differently
    WORKSPACE_DIR="/workspaces"
    mkdir -p "$WORKSPACE_DIR"
fi

# Test that .claude directory exists
check ".claude directory exists" test -d "${WORKSPACE_DIR}/.claude"

# Test that commands directory exists  
check ".claude/commands directory exists" test -d "${WORKSPACE_DIR}/.claude/commands"

# Since no repo was specified in the default test, the directory should be empty
check ".claude/commands is empty (no repo specified)" test -z "$(ls -A ${WORKSPACE_DIR}/.claude/commands 2>/dev/null || true)"

echo "Basic tests completed successfully!"

# Report result
reportResults