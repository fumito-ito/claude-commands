#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'claude-code-config' feature with a specific repository.

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

# Test that .claude directory is not empty (repo was cloned)
# Check for specific file that should exist (README from octocat/Hello-World repo)
check ".claude directory is not empty" test -f "$EXPECTED_CLAUDE_DIR/README"

# Test that .git directory was removed
check ".git directory was removed" test ! -d "$EXPECTED_CLAUDE_DIR/.git"

# Test that at least one file exists (indicating successful clone)
check "files exist in .claude directory" test "$(find "$EXPECTED_CLAUDE_DIR" -type f 2>/dev/null | wc -l)" -gt 0

# Report result
reportResults