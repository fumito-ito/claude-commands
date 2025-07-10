#!/bin/bash

# This test file will be executed against the 'basic' scenario.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for basic scenario (no repo specified)
echo "Testing basic scenario (no repository)..."

check "git is installed" which git
check "curl is installed" which curl

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

# Test that .claude directory exists
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

# Test that .claude directory is set up correctly
check ".claude directory is accessible" test -d "$EXPECTED_CLAUDE_DIR"

# Test that .claude directory exists but has minimal content (no repo specified)
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

echo "Basic scenario tests completed!"

# Report result
reportResults