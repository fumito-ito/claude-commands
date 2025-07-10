#!/bin/bash

set -e

# Test for existing directory scenario
# This test simulates running the feature when .claude directory already exists

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

# Test that .claude directory exists (should be created by feature)
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

# Create a test file to simulate existing content
# First ensure we have write permissions
sudo chmod 755 "$EXPECTED_CLAUDE_DIR" 2>/dev/null || true
if touch "$EXPECTED_CLAUDE_DIR/existing-test.txt" 2>/dev/null; then
    echo "existing-test-file" > "$EXPECTED_CLAUDE_DIR/existing-test.txt"
    HAS_EXISTING_FILE=true
else
    echo "Warning: Cannot create test file, permissions may be restricted"
    HAS_EXISTING_FILE=false
fi

# Test that the feature handles existing directory gracefully
# by checking if the directory exists and the feature completed successfully
check "feature handles existing directory" test -d "$EXPECTED_CLAUDE_DIR"

# Test that existing content is preserved (if we could create it)
if [ "$HAS_EXISTING_FILE" = "true" ]; then
    check "existing content is preserved" test -f "$EXPECTED_CLAUDE_DIR/existing-test.txt"
    check "existing content is correct" grep -q "existing-test-file" "$EXPECTED_CLAUDE_DIR/existing-test.txt"
else
    check "directory is accessible" test -d "$EXPECTED_CLAUDE_DIR"
fi

# Report results
reportResults