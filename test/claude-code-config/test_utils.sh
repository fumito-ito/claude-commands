#!/bin/bash

# Utility functions for claude-code-config tests

# Common test utilities
print_test_header() {
    echo "=========================================="
    echo "Testing: $1"
    echo "=========================================="
}

print_test_footer() {
    echo "=========================================="
    echo "Completed: $1"
    echo "=========================================="
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a file exists and is executable
is_executable() {
    [ -f "$1" ] && [ -x "$1" ]
}

# Check if a directory exists and is writable
is_writable_dir() {
    [ -d "$1" ] && [ -w "$1" ]
}

# Get the size of a directory
get_dir_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Check if git is properly configured
check_git_config() {
    git config --global user.name >/dev/null 2>&1 && git config --global user.email >/dev/null 2>&1
}

# Verify the workspace directory setup
verify_workspace_setup() {
    local workspace_dir="/workspaces"
    
    if [ ! -d "$workspace_dir" ]; then
        echo "Creating workspace directory: $workspace_dir"
        mkdir -p "$workspace_dir"
    fi
    
    if [ ! -d "$workspace_dir/.claude" ]; then
        echo "ERROR: .claude directory not found in $workspace_dir"
        return 1
    fi
    
    return 0
}

# Test git operations safely
test_git_operations() {
    local test_dir="$1"
    
    if [ ! -d "$test_dir" ]; then
        echo "ERROR: Test directory does not exist: $test_dir"
        return 1
    fi
    
    cd "$test_dir"
    
    # Test basic git commands
    git --version >/dev/null 2>&1 || {
        echo "ERROR: git --version failed"
        return 1
    }
    
    return 0
}

# Clean up test artifacts
cleanup_test_artifacts() {
    echo "Cleaning up test artifacts..."
    # Remove any temporary files created during tests
    find /tmp -name "*claude*test*" -type f -delete 2>/dev/null || true
}

# Setup test environment
setup_test_environment() {
    echo "Setting up test environment..."
    
    # Ensure workspace directory exists
    verify_workspace_setup
    
    # Set up basic git configuration for tests
    git config --global user.name "Claude Test User" 2>/dev/null || true
    git config --global user.email "test@claude.ai" 2>/dev/null || true
    
    return 0
}

# Export functions for use in other test scripts
export -f print_test_header
export -f print_test_footer
export -f command_exists
export -f is_executable
export -f is_writable_dir
export -f get_dir_size
export -f check_git_config
export -f verify_workspace_setup
export -f test_git_operations
export -f cleanup_test_artifacts
export -f setup_test_environment