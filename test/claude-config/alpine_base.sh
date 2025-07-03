#!/bin/bash

# This test file will be executed against an Alpine-based devcontainer.json that
# includes the 'claude-config' feature to test apk package manager support.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" which git

# Test Alpine-specific package manager was used
check "apk is available" which apk

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that .claude directory is not empty (repo was cloned)
check ".claude directory is not empty" test -n "$(ls -A /workspaces/.claude 2>/dev/null || true)"

# Test that .git directory was removed
check ".git directory was removed" test ! -d /workspaces/.claude/.git

# Report result
reportResults