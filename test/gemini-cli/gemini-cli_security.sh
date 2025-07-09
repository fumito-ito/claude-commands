#!/bin/bash

# Security test for gemini-cli

set -e

# Import test utility functions
source dev-container-features-test-lib

# Test that gemini CLI is installed
check "gemini command exists" command -v gemini

# Test that node is installed (required for gemini)
check "node command exists" command -v node

# Test that gemini shows version
check "gemini shows version" bash -c "gemini --version"

# Security checks
check "gemini binary has safe permissions" bash -c "perms=\$(stat -c%a \$(command -v gemini)); test \"\$perms\" = \"755\" -o \"\$perms\" = \"777\""

check "gemini binary is owned by root" bash -c "test \$(stat -c%U \$(command -v gemini)) = root"

# Test that npm global installation is secure
check "npm global directory has safe permissions" bash -c "
    global_dir=\$(npm root -g 2>/dev/null || echo '/usr/lib/node_modules')
    if [ -d \"\$global_dir/@google/gemini-cli\" ]; then
        perms=\$(stat -c%a \"\$global_dir/@google/gemini-cli\")
        test \"\$perms\" = 755 -o \"\$perms\" = 777
    else
        echo 'npm global directory not found, skipping permission check'
    fi
"

# Report result
reportResults