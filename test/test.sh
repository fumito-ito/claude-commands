#!/bin/bash

# This script runs all tests for the claude-commands feature

set -e

cd "$(dirname "$0")/.."

echo "Running tests for claude-commands feature..."

# Check if devcontainer CLI is available
if ! command -v devcontainer &> /dev/null; then
    echo "Error: devcontainer CLI not found!"
    echo "Please install it with: npm install -g @devcontainers/cli"
    echo "Or use VS Code Dev Containers extension for testing"
    exit 1
fi

# Check directory structure
echo "Checking directory structure..."
if [ ! -d "src/claude-commands" ]; then
    echo "Error: src/claude-commands directory not found!"
    echo "Please ensure the correct directory structure:"
    echo "  src/claude-commands/devcontainer-feature.json"
    echo "  src/claude-commands/install.sh"
    exit 1
fi

if [ ! -d "test/claude-commands" ]; then
    echo "Error: test/claude-commands directory not found!"
    echo "Please ensure test files are in test/claude-commands/"
    exit 1
fi

# Run tests for the specific feature
echo "Running tests for claude-commands feature..."
devcontainer features test --features claude-commands

echo "All tests completed!"