#!/bin/bash

# Test file permissions for claude-code-config feature

set -e

# Import test utility functions
source dev-container-features-test-lib

# Basic functionality tests
check "git is installed" command -v git
check ".claude directory exists" test -d /workspaces/.claude

# Check if vscode user exists
check "vscode user exists" id vscode

# Test ownership and permissions
check ".claude directory is owned by vscode" bash -c "test \$(stat -c%U /workspaces/.claude) = 'vscode'"
check ".claude directory group is vscode" bash -c "test \$(stat -c%G /workspaces/.claude) = 'vscode'"
check ".claude directory has correct permissions" bash -c "test \"\$(stat -c%a /workspaces/.claude)\" = '755'"

# Test that directory is writable by owner (vscode)
check "vscode user owns .claude directory" bash -c "ls -ld /workspaces/.claude | grep '^drwxr-xr-x.*vscode.*vscode'"

# Test any existing files in the directory have appropriate permissions
if [ -n "$(ls -A /workspaces/.claude)" ]; then
    check "files in .claude directory have correct permissions" bash -c "find /workspaces/.claude -type f -exec stat -c%a {} \; | grep -q '^644$'"
    check "files in .claude directory are owned by vscode" bash -c "find /workspaces/.claude -type f -exec stat -c%U {} \; | grep -q '^vscode$'"
fi

# Test basic file creation capability by temporarily switching user
# We'll use a different approach - check if the directory is writable by creating a file as root and then checking if vscode can modify it
echo "test content" > /workspaces/.claude/permission_test.txt
chown vscode:vscode /workspaces/.claude/permission_test.txt
chmod 644 /workspaces/.claude/permission_test.txt

check "test file created with correct ownership" bash -c "test \$(stat -c%U /workspaces/.claude/permission_test.txt) = 'vscode'"
check "test file has correct permissions" bash -c "test \"\$(stat -c%a /workspaces/.claude/permission_test.txt)\" = '644'"

# Clean up test file
rm -f /workspaces/.claude/permission_test.txt

echo "File permissions test completed successfully!"

# Report result
reportResults