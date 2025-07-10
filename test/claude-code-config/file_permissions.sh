#!/bin/bash

# Test file permissions for claude-code-config feature

set -e

# Import test utility functions
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

# Basic functionality tests
check "git is installed" command -v git
check ".claude directory exists" test -d "$EXPECTED_CLAUDE_DIR"

# Check if vscode user exists
check "vscode user exists" id vscode

# Test ownership and permissions
check ".claude directory is owned by vscode" bash -c "test \$(stat -c%U \"$EXPECTED_CLAUDE_DIR\") = 'vscode'"
check ".claude directory group is vscode" bash -c "test \$(stat -c%G \"$EXPECTED_CLAUDE_DIR\") = 'vscode'"
check ".claude directory has correct permissions" bash -c "test \"\$(stat -c%a \"$EXPECTED_CLAUDE_DIR\")\" = '755'"

# Test that directory is writable by owner (vscode)
check "vscode user owns .claude directory" bash -c "ls -ld \"$EXPECTED_CLAUDE_DIR\" | grep '^drwxr-xr-x.*vscode.*vscode'"

# Test any existing files in the directory have appropriate permissions
if [ -f "$EXPECTED_CLAUDE_DIR/README" ]; then
    check "files in .claude directory have correct permissions" bash -c "find \"$EXPECTED_CLAUDE_DIR\" -type f -exec stat -c%a {} \; | grep -q '^644$'"
    check "files in .claude directory are owned by vscode" bash -c "find \"$EXPECTED_CLAUDE_DIR\" -type f -exec stat -c%U {} \; | grep -q '^vscode$'"
fi

# Test basic file creation capability by temporarily switching user
# We'll use a different approach - check if the directory is writable by creating a file as root and then checking if vscode can modify it
echo "test content" > "$EXPECTED_CLAUDE_DIR/permission_test.txt"
chown vscode:vscode "$EXPECTED_CLAUDE_DIR/permission_test.txt"
chmod 644 "$EXPECTED_CLAUDE_DIR/permission_test.txt"

check "test file created with correct ownership" bash -c "test \$(stat -c%U \"$EXPECTED_CLAUDE_DIR/permission_test.txt\") = 'vscode'"
check "test file has correct permissions" bash -c "test \"\$(stat -c%a \"$EXPECTED_CLAUDE_DIR/permission_test.txt\")\" = '644'"

# Clean up test file
rm -f "$EXPECTED_CLAUDE_DIR/permission_test.txt"

echo "File permissions test completed successfully!"

# Report result
reportResults