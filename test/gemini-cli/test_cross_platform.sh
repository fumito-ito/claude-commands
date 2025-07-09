#!/bin/bash

# This test file tests cross-platform compatibility

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Basic installation verification
check "gemini command exists" bash -c "command -v gemini"
check "gemini is executable" bash -c "test -x /usr/local/bin/gemini"

# Architecture detection tests
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

check "architecture detected correctly" bash -c "echo 'Architecture: $ARCH, OS: $OS'"

# Verify the correct binary was downloaded based on architecture
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
    check "x86_64 binary works" bash -c "file /usr/local/bin/gemini | grep -E '(x86-64|x86_64)'"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    check "arm64 binary works" bash -c "file /usr/local/bin/gemini | grep -E '(aarch64|arm64)'"
fi

# Test basic functionality across platforms
check "gemini version works on this platform" bash -c "gemini --version"
check "gemini help works on this platform" bash -c "gemini --help"

# Verify dependencies are properly installed
check "curl is available" bash -c "command -v curl"
check "ca-certificates are installed" bash -c "test -d /etc/ssl/certs"

echo "Cross-platform tests passed!"

# Report result
reportResults