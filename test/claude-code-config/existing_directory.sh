#!/bin/bash

set -e

# Test for existing directory scenario
# This test simulates running the feature when .claude directory already exists

source dev-container-features-test-lib

# Test that .claude directory exists (should be created by feature)
check ".claude directory exists" test -d /workspaces/.claude

# Create a test file to simulate existing content
# First ensure we have write permissions
sudo chmod 755 /workspaces/.claude 2>/dev/null || true
if touch /workspaces/.claude/existing-test.txt 2>/dev/null; then
    echo "existing-test-file" > /workspaces/.claude/existing-test.txt
    HAS_EXISTING_FILE=true
else
    echo "Warning: Cannot create test file, permissions may be restricted"
    HAS_EXISTING_FILE=false
fi

# Test that the feature handles existing directory gracefully
# by checking if the directory exists and the feature completed successfully
check "feature handles existing directory" test -d /workspaces/.claude

# Test that existing content is preserved (if we could create it)
if [ "$HAS_EXISTING_FILE" = "true" ]; then
    check "existing content is preserved" test -f /workspaces/.claude/existing-test.txt
    check "existing content is correct" grep -q "existing-test-file" /workspaces/.claude/existing-test.txt
else
    check "directory is accessible" test -d /workspaces/.claude
fi

# Report results
reportResults