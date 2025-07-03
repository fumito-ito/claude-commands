#!/bin/bash

# This test file will be executed against the 'basic' scenario.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for basic scenario (no repo specified)
echo "Testing basic scenario (no repository)..."

check "git is installed" which git
check "curl is installed" which curl

# Test that .claude directory exists
check ".claude directory exists" test -d /workspaces/.claude

# Test that .claude directory is set up correctly
check ".claude directory is accessible" test -d /workspaces/.claude

# Test that .claude directory exists but has minimal content (no repo specified)
check ".claude directory exists" test -d /workspaces/.claude

echo "Basic scenario tests completed!"

# Report result
reportResults