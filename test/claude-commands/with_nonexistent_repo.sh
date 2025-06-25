#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'claude-commands' feature with a nonexistent repository.
# This should fail gracefully without breaking the container.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" which git

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that commands directory exists
check ".claude/commands directory exists" test -d /workspaces/.claude/commands

# Test that .claude/commands is empty (clone should have failed)
check ".claude/commands is empty after failed clone" test -z "$(ls -A /workspaces/.claude/commands 2>/dev/null || true)"

# Test that container still works despite failed clone
check "container is functional" echo "Container is working"

# Report result
reportResults