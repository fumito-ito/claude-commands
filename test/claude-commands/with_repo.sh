#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'claude-commands' feature with a specific repository.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" which git

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that commands directory exists
check ".claude/commands directory exists" test -d /workspaces/.claude/commands

# Test that .claude/commands is not empty (repo was cloned)
check ".claude/commands is not empty" test -n "$(ls -A /workspaces/.claude/commands 2>/dev/null || true)"

# Test that .git directory was removed
check ".git directory was removed" test ! -d /workspaces/.claude/commands/.git

# Test that at least one file exists (indicating successful clone)
check "files exist in .claude/commands" test "$(find /workspaces/.claude/commands -type f 2>/dev/null | wc -l)" -gt 0

# Report result
reportResults