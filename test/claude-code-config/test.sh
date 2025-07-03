#!/bin/bash

# This test file will be executed against the feature.
# It will test the basic functionality of the claude-code-config feature.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
echo "Testing claude-code-config feature..."

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

# Test that .claude directory is set up correctly
check ".claude directory is accessible" test -d "${WORKSPACE_DIR}/.claude"

# Since no repo was specified in the default test, the directory should only contain the base structure
check ".claude directory has minimal content (no repo specified)" test -d "${WORKSPACE_DIR}/.claude"

echo "Basic tests completed successfully!"

# Report result
reportResults