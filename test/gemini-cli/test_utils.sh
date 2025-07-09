#!/bin/bash

# Utility functions for testing DevContainer features

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Enhanced check function with better error reporting
check_enhanced() {
    local description="$1"
    local command="$2"
    
    echo -n "Testing: $description ... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        log_error "Command failed: $command"
        return 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Check if a file exists and is executable
is_executable() {
    test -x "$1"
}

# Check if a file has specific permissions
check_permissions() {
    local file="$1"
    local expected_perms="$2"
    local actual_perms=$(stat -c %a "$file" 2>/dev/null)
    
    if [ "$actual_perms" = "$expected_perms" ]; then
        return 0
    else
        log_error "Expected permissions $expected_perms, got $actual_perms for $file"
        return 1
    fi
}

# Check file size within reasonable bounds
check_file_size() {
    local file="$1"
    local min_size="$2"
    local max_size="$3"
    
    if [ ! -f "$file" ]; then
        log_error "File $file does not exist"
        return 1
    fi
    
    local size=$(stat -c %s "$file")
    
    if [ "$size" -lt "$min_size" ]; then
        log_error "File $file is too small ($size bytes, minimum $min_size)"
        return 1
    fi
    
    if [ "$size" -gt "$max_size" ]; then
        log_error "File $file is too large ($size bytes, maximum $max_size)"
        return 1
    fi
    
    return 0
}

# Check if a service/command produces expected output
check_output_contains() {
    local command="$1"
    local expected="$2"
    local output
    
    output=$(eval "$command" 2>&1)
    
    if echo "$output" | grep -q "$expected"; then
        return 0
    else
        log_error "Command '$command' output does not contain '$expected'"
        log_error "Actual output: $output"
        return 1
    fi
}

# Check if a binary is the correct architecture
check_binary_arch() {
    local binary="$1"
    local expected_arch="$2"
    
    if ! command_exists file; then
        log_warn "file command not available, skipping architecture check"
        return 0
    fi
    
    local file_output=$(file "$binary")
    
    case "$expected_arch" in
        "x86_64"|"amd64")
            if echo "$file_output" | grep -q -E "(x86-64|x86_64)"; then
                return 0
            fi
            ;;
        "arm64"|"aarch64")
            if echo "$file_output" | grep -q -E "(aarch64|arm64)"; then
                return 0
            fi
            ;;
    esac
    
    log_error "Binary $binary is not for expected architecture $expected_arch"
    log_error "File output: $file_output"
    return 1
}

# Cleanup function
cleanup_test_files() {
    local cleanup_paths=(
        "/tmp/gemini-cli-install*"
        "/tmp/gemini_*"
        "/tmp/test_*"
    )
    
    for path in "${cleanup_paths[@]}"; do
        rm -rf $path 2>/dev/null || true
    done
}

# Test summary
print_test_summary() {
    local passed="$1"
    local total="$2"
    local failed=$((total - passed))
    
    echo "==============================================="
    echo "Test Summary:"
    if [ "$failed" -eq 0 ]; then
        echo -e "All tests passed! ${GREEN}$passed/$total${NC}"
    else
        echo -e "Tests passed: ${GREEN}$passed${NC}"
        echo -e "Tests failed: ${RED}$failed${NC}"
        echo -e "Total tests: $total"
    fi
    echo "==============================================="
}

# Export functions for use in other test scripts
export -f log_info log_warn log_error
export -f check_enhanced command_exists is_executable
export -f check_permissions check_file_size check_output_contains
export -f check_binary_arch cleanup_test_files print_test_summary