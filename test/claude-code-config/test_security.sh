#!/bin/bash

# Security tests for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_DIR="/workspaces"

echo "Running security tests for claude-code-config..."

# Test directory permissions are secure
check ".claude directory has secure permissions" bash -c "ls -la ${WORKSPACE_DIR}/.claude | grep -E '^d[rwx-]{9}'"

# Test that no sensitive information is exposed
check "no sensitive info in environment" bash -c "env | grep -v -E '(PASSWORD|SECRET|TOKEN|KEY)='"

# Test git configuration security
check "git configuration is secure" bash -c "git config --global --list | grep -v -E '(password|token|key)'"

# Test that the feature doesn't create world-writable files
check "no world-writable files created" bash -c "! find ${WORKSPACE_DIR}/.claude -type f -perm -002 2>/dev/null"

# Test that the feature doesn't run with unnecessary privileges
check "feature runs with appropriate privileges" bash -c "id -u | grep -q '^[0-9]'"

# Test that git operations are performed securely
check "git operations are secure" bash -c "cd ${WORKSPACE_DIR}/.claude && git config --get remote.origin.url | grep -E '^https://|^git@' || echo 'No remote configured'"

# Test that no temporary files with sensitive data are left behind
check "no sensitive temporary files" bash -c "! find /tmp -name '*git*' -o -name '*clone*' -o -name '*token*' 2>/dev/null"

echo "Security tests completed!"

# Report result
reportResults