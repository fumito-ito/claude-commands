#!/bin/bash

# This script runs all tests for the claude-code-config feature

set -e

cd "$(dirname "$0")/.."

echo "Running tests for claude-code-config feature..."

# Check if devcontainer CLI is available
if ! command -v devcontainer &> /dev/null; then
    echo "Error: devcontainer CLI not found!"
    echo "Please install it with: npm install -g @devcontainers/cli"
    echo "Or use VS Code Dev Containers extension for testing"
    exit 1
fi

# Check directory structure
echo "Checking directory structure..."
if [ ! -d "src/claude-code-config" ]; then
    echo "Error: src/claude-code-config directory not found!"
    echo "Please ensure the correct directory structure:"
    echo "  src/claude-code-config/devcontainer-feature.json"
    echo "  src/claude-code-config/install.sh"
    exit 1
fi

if [ ! -d "test/claude-code-config" ]; then
    echo "Error: test/claude-code-config directory not found!"
    echo "Please ensure test files are in test/claude-code-config/"
    exit 1
fi

# Run tests for the specific feature
echo "Running tests for claude-code-config feature..."
devcontainer features test --features claude-code-config

echo "All tests completed!"