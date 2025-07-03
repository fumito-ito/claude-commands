#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'claude-code-config' feature with a specific repository.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" which git

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that .claude directory is not empty (repo was cloned)
check ".claude directory is not empty" test -n "$(ls -A /workspaces/.claude 2>/dev/null || true)"

# Test that .git directory was removed
check ".git directory was removed" test ! -d /workspaces/.claude/.git

# Test that at least one file exists (indicating successful clone)
check "files exist in .claude directory" test "$(find /workspaces/.claude -type f 2>/dev/null | wc -l)" -gt 0

# Report result
reportResults