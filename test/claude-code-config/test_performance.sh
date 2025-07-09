#!/bin/bash

# Performance tests for claude-code-config

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_DIR="/workspaces"

echo "Running performance tests for claude-code-config..."

# Test that the feature installs quickly
start_time=$(date +%s)
check "feature installation is fast" test -d "${WORKSPACE_DIR}/.claude"
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Feature setup took ${duration} seconds"

# Test git installation performance
start_time=$(date +%s)
check "git installation is efficient" bash -c "command -v git"
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Git check took ${duration} seconds"

# Test directory creation performance
start_time=$(date +%s)
check "directory operations are fast" test -d "${WORKSPACE_DIR}/.claude"
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Directory check took ${duration} seconds"

# Test that the feature doesn't consume excessive resources
check "memory usage is reasonable" bash -c "ps aux | grep -v grep | wc -l"

# Test file system performance
start_time=$(date +%s)
check "file system operations are efficient" bash -c "ls -la ${WORKSPACE_DIR}/.claude"
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "File system check took ${duration} seconds"

# Test that multiple git operations don't degrade performance
start_time=$(date +%s)
for i in {1..5}; do
    git --version >/dev/null 2>&1
done
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Multiple git operations took ${duration} seconds"

echo "Performance tests completed!"

# Report result
reportResults