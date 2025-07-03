#!/bin/bash

# This script runs all tests for the claude-config feature

set -e

cd "$(dirname "$0")/.."

echo "Running tests for claude-config feature..."

# Check if devcontainer CLI is available
if ! command -v devcontainer &> /dev/null; then
    echo "Error: devcontainer CLI not found!"
    echo "Please install it with: npm install -g @devcontainers/cli"
    echo "Or use VS Code Dev Containers extension for testing"
    exit 1
fi

# Check directory structure
echo "Checking directory structure..."
if [ ! -d "src/claude-config" ]; then
    echo "Error: src/claude-config directory not found!"
    echo "Please ensure the correct directory structure:"
    echo "  src/claude-config/devcontainer-feature.json"
    echo "  src/claude-config/install.sh"
    exit 1
fi

if [ ! -d "test/claude-config" ]; then
    echo "Error: test/claude-config directory not found!"
    echo "Please ensure test files are in test/claude-config/"
    exit 1
fi

# Run tests for the specific feature
echo "Running tests for claude-config feature..."
devcontainer features test --features claude-config

echo "All tests completed!"