#!/bin/bash

# Test codex-cli feature installation on Alpine base image

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that codex CLI is installed
check "codex command exists" command -v codex

# Test that node is installed (required for codex)
check "node command exists" command -v node

# Test that npm is installed
check "npm command exists" command -v npm

# Test that codex shows version
check "codex shows version" bash -c "codex --version"

# Test that codex is executable
check "codex is executable" test -x "$(command -v codex)"

# Test that codex help works
check "codex help works" bash -c "codex --help"

# Report result
reportResults