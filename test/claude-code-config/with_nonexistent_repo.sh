#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'claude-code-config' feature with a nonexistent repository.
# This should fail gracefully without breaking the container.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Run the runtime setup script to create .claude directory at the correct location
/usr/local/bin/claude-setup.sh

# Determine the expected .claude directory location
if [ -n "$CONTAINERWORKSPACEFOLDER" ]; then
    EXPECTED_CLAUDE_DIR="$CONTAINERWORKSPACEFOLDER/.claude"
else
    # Find the project directory in /workspaces
    EXPECTED_CLAUDE_DIR="/workspaces/.claude"
    for dir in /workspaces/*/; do
        if [ -d "$dir" ]; then
            EXPECTED_CLAUDE_DIR="${dir%/}/.claude"  # Remove trailing slash
            break
        fi
    done
fi

# Feature-specific tests
check "git is installed" which git

# Test that .claude directory exists
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

# Test that .claude directory exists
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

# Test that .claude directory is empty (clone should have failed)
check ".claude directory is empty after failed clone" test -z "$(ls -A \"$EXPECTED_CLAUDE_DIR\" 2>/dev/null || true)"

# Test that container still works despite failed clone
check "container is functional" echo "Container is working"

# Report result
reportResults