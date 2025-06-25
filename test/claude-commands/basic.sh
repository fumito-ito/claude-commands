#!/bin/bash

# This test file will be executed against the 'basic' scenario.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for basic scenario (no repo specified)
echo "Testing basic scenario (no repository)..."

check "git is installed" which git
check "curl is installed" which curl

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that commands directory exists
check ".claude/commands directory exists" test -d /workspaces/.claude/commands

# Test that .claude/commands is empty (no repo specified)
check ".claude/commands is empty" test -z "$(ls -A /workspaces/.claude/commands 2>/dev/null || true)"

echo "Basic scenario tests completed!"

# Report result
reportResults