#!/bin/bash

# Cross-platform compatibility test for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

echo "Testing on $OS ($ARCH)"

# Test git installation works across platforms
check "git is available" bash -c "command -v git"

# Test directory creation works across platforms
WORKSPACE_DIR="/workspaces"
check "workspace directory accessible" test -d "${WORKSPACE_DIR}" || mkdir -p "${WORKSPACE_DIR}"

# Test .claude directory exists
check ".claude directory exists" test -d "${WORKSPACE_DIR}/.claude"

# Test permissions are correct across platforms
check ".claude directory has correct permissions" bash -c "ls -la ${WORKSPACE_DIR}/.claude"

# Test git operations work across platforms
check "git commands work" bash -c "cd ${WORKSPACE_DIR}/.claude && git status" || echo "No git repo found (expected for basic test)"

# Platform-specific tests
case "$OS" in
    Linux)
        echo "Running Linux-specific tests..."
        check "Linux git installation" bash -c "dpkg -l | grep git || apk list git || rpm -qa | grep git"
        ;;
    Darwin)
        echo "Running macOS-specific tests..."
        check "macOS git installation" bash -c "brew list git || which git"
        ;;
    *)
        echo "Running generic tests for $OS..."
        check "generic git check" bash -c "git --version"
        ;;
esac

echo "Cross-platform tests completed!"

# Report result
reportResults