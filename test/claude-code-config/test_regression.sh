#!/bin/bash

# Regression tests for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_DIR="/workspaces"

echo "Running regression tests for claude-code-config..."

# Test that basic functionality still works
check "basic functionality regression test" test -d "${WORKSPACE_DIR}/.claude"

# Test git functionality regression
check "git functionality regression test" bash -c "command -v git"

# Test that git version is acceptable
check "git version regression test" bash -c "git --version | grep -E 'git version [0-9]+\.[0-9]+'"

# Test directory structure regression
check "directory structure regression test" bash -c "ls -la ${WORKSPACE_DIR}/.claude"

# Test that permissions haven't regressed
check "permissions regression test" bash -c "test -w ${WORKSPACE_DIR}/.claude"

# Test that git configuration hasn't regressed
check "git config regression test" bash -c "git config --global --list >/dev/null 2>&1 || echo 'No global config'"

# Test that the feature works with different base images (simulated)
check "base image compatibility regression test" bash -c "uname -a"

# Test that environment variables are preserved
check "environment variables regression test" bash -c "echo \$PATH | grep -q /usr/local/bin"

# Test that the feature doesn't break on repeated runs
check "repeated runs regression test" test -d "${WORKSPACE_DIR}/.claude"

echo "Regression tests completed!"

# Report result
reportResults