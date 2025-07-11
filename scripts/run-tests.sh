#!/bin/bash

# Comprehensive test runner script for DevContainer Features

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_section() {
    echo -e "${BLUE}[SECTION]${NC} $1"
    echo "=================================================="
}

# Test configuration
TEST_TYPES=(
    "default"
    "cross_platform"
    "edge_cases"
    "integration"
    "performance"
    "security"
    "regression"
    "version_latest"
    "docker_scenarios"
    "version_matrix"
    "manual_verification"
)

BASE_IMAGES=(
    "mcr.microsoft.com/devcontainers/base:ubuntu"
    "mcr.microsoft.com/devcontainers/base:debian"
    "mcr.microsoft.com/devcontainers/base:alpine"
)

FEATURES=(
    "claude-code-config"
    "gemini-cli"
)

# Global variables
FAILED_TESTS=()
PASSED_TESTS=()
SKIPPED_TESTS=()
TOTAL_TESTS=0
START_TIME=$(date +%s)

# Command line argument parsing
QUICK_MODE=false
VERBOSE=false
SELECTED_TESTS=()
SELECTED_IMAGES=()
SELECTED_FEATURES=()

usage() {
    cat << EOF
Usage: $0 [OPTIONS] [TEST_TYPES...]

Options:
    -q, --quick         Run quick tests only (basic functionality)
    -v, --verbose       Enable verbose output
    -i, --image IMAGE   Test with specific base image (can be repeated)
    -t, --test TEST     Run specific test type (can be repeated)
    -f, --feature FEAT  Test specific feature (claude-code-config, gemini-cli, or both)
    -h, --help          Show this help message

Features:
    ${FEATURES[*]}

Test Types:
    ${TEST_TYPES[*]}

Base Images:
    ${BASE_IMAGES[*]}

Examples:
    $0                                          # Run all tests for both features
    $0 --quick                                  # Run basic tests only for both features
    $0 --feature claude-code-config             # Test claude-code-config only
    $0 --feature gemini-cli                     # Test gemini-cli only
    $0 --test default --test security           # Run specific tests for both features
    $0 --image ubuntu --feature claude-code-config # Test claude-code-config with Ubuntu only
    $0 --verbose                                # Run with verbose output for both features

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -i|--image)
            SELECTED_IMAGES+=("$2")
            shift 2
            ;;
        -t|--test)
            SELECTED_TESTS+=("$2")
            shift 2
            ;;
        -f|--feature)
            case "$2" in
                "claude-code-config"|"gemini-cli")
                    SELECTED_FEATURES+=("$2")
                    ;;
                "both")
                    SELECTED_FEATURES=("${FEATURES[@]}")
                    ;;
                *)
                    log_error "Invalid feature: $2. Must be 'claude-code-config', 'gemini-cli', or 'both'"
                    exit 1
                    ;;
            esac
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            SELECTED_TESTS+=("$1")
            shift
            ;;
    esac
done

# Set defaults if nothing selected
if [ ${#SELECTED_FEATURES[@]} -eq 0 ]; then
    SELECTED_FEATURES=("${FEATURES[@]}")
fi

if [ ${#SELECTED_TESTS[@]} -eq 0 ]; then
    if [ "$QUICK_MODE" = true ]; then
        SELECTED_TESTS=("default" "integration")
    else
        SELECTED_TESTS=("${TEST_TYPES[@]}")
    fi
fi

if [ ${#SELECTED_IMAGES[@]} -eq 0 ]; then
    if [ "$QUICK_MODE" = true ]; then
        SELECTED_IMAGES=("mcr.microsoft.com/devcontainers/base:ubuntu")
    else
        SELECTED_IMAGES=("${BASE_IMAGES[@]}")
    fi
fi

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v devcontainer > /dev/null; then
        log_error "DevContainer CLI not found. Install with: npm install -g @devcontainers/cli"
        exit 1
    fi
    
    if ! command -v docker > /dev/null; then
        log_error "Docker not found. Please install Docker."
        exit 1
    fi
    
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon not running. Please start Docker."
        exit 1
    fi
    
    log_info "Prerequisites check passed"
}

# Validate feature structure
validate_feature() {
    local feature="$1"
    log_info "Validating $feature feature structure..."
    
    local errors=0
    
    if [ ! -f "src/$feature/devcontainer-feature.json" ]; then
        log_error "$feature/devcontainer-feature.json not found"
        ((errors++))
    fi
    
    if [ ! -f "src/$feature/install.sh" ]; then
        log_error "$feature/install.sh not found"
        ((errors++))
    fi
    
    if [ ! -x "src/$feature/install.sh" ]; then
        log_error "$feature/install.sh is not executable"
        ((errors++))
    fi
    
    if [ ! -f "src/$feature/README.md" ]; then
        log_warn "$feature/README.md not found"
    fi
    
    if [ $errors -gt 0 ]; then
        log_error "$feature feature structure validation failed"
        exit 1
    fi
    
    log_info "$feature feature structure validation passed"
}

# Make test scripts executable
prepare_tests() {
    local feature="$1"
    log_info "Preparing test scripts for $feature..."
    
    if [ -d "test/$feature" ]; then
        find "test/$feature" -name "*.sh" -exec chmod +x {} \;
    fi
    
    log_info "Test scripts for $feature prepared"
}

# Run a single test
run_test() {
    local feature="$1"
    local test_type="$2"
    local image="$3"
    local test_name="${feature}_${test_type}_${image##*/}"
    
    log_info "Running test: $test_name"
    ((TOTAL_TESTS++))
    
    local cmd="devcontainer features test -f $feature -i $image"
    
    # Add specific test type if it's not default
    if [ "$test_type" != "default" ]; then
        if [ -f "test/$feature/test_${test_type}.sh" ]; then
            cmd="$cmd -t test_${test_type}"
        else
            log_warn "Test file test_${test_type}.sh not found for $feature, running default test"
        fi
    fi
    
    cmd="$cmd ."
    
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd --verbose"
    fi
    
    local output_file="/tmp/devcontainer_test_${test_name}.log"
    
    if eval "$cmd" > "$output_file" 2>&1; then
        PASSED_TESTS+=("$test_name")
        log_info "✓ $test_name PASSED"
        if [ "$VERBOSE" = true ]; then
            cat "$output_file"
        fi
    else
        FAILED_TESTS+=("$test_name")
        log_error "✗ $test_name FAILED"
        echo "Error output:"
        cat "$output_file"
    fi
    
    # Clean up log file
    rm -f "$output_file"
}

# Run scenario tests
run_scenario_tests() {
    log_section "Running scenario tests"
    
    local cmd="devcontainer features test --global-scenarios-only ."
    if [ "$VERBOSE" = true ]; then
        cmd="$cmd --verbose"
    fi
    
    if eval "$cmd"; then
        PASSED_TESTS+=("scenarios")
        log_info "✓ Scenario tests PASSED"
    else
        FAILED_TESTS+=("scenarios")
        log_error "✗ Scenario tests FAILED"
    fi
    
    ((TOTAL_TESTS++))
}

# Generate test report
generate_report() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    log_section "Test Report"
    
    echo "Test Summary:"
    echo "  Total tests: $TOTAL_TESTS"
    echo "  Passed: ${#PASSED_TESTS[@]}"
    echo "  Failed: ${#FAILED_TESTS[@]}"
    echo "  Skipped: ${#SKIPPED_TESTS[@]}"
    echo "  Duration: ${duration}s"
    echo
    
    if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
        echo -e "${GREEN}Passed tests:${NC}"
        for test in "${PASSED_TESTS[@]}"; do
            echo "  ✓ $test"
        done
        echo
    fi
    
    if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
        echo -e "${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  ✗ $test"
        done
        echo
    fi
    
    if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Skipped tests:${NC}"
        for test in "${SKIPPED_TESTS[@]}"; do
            echo "  - $test"
        done
        echo
    fi
    
    # Exit with error if any tests failed
    if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
        log_error "Some tests failed!"
        exit 1
    else
        log_info "All tests passed!"
    fi
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    
    # Clean up any remaining containers
    docker system prune -f --filter label=devcontainer.local_folder > /dev/null 2>&1 || true
    
    # Clean up test artifacts
    rm -f /tmp/devcontainer_test_*.log
}

# Set up cleanup on exit
trap cleanup EXIT

# Main execution
main() {
    log_section "DevContainer Features Test Runner"
    
    echo "Configuration:"
    echo "  Quick mode: $QUICK_MODE"
    echo "  Verbose: $VERBOSE"
    echo "  Selected features: ${SELECTED_FEATURES[*]}"
    echo "  Selected tests: ${SELECTED_TESTS[*]}"
    echo "  Selected images: ${SELECTED_IMAGES[*]}"
    echo
    
    check_prerequisites
    
    # Validate all selected features
    for feature in "${SELECTED_FEATURES[@]}"; do
        validate_feature "$feature"
        prepare_tests "$feature"
    done
    
    # Run individual tests
    for feature in "${SELECTED_FEATURES[@]}"; do
        for test_type in "${SELECTED_TESTS[@]}"; do
            for image in "${SELECTED_IMAGES[@]}"; do
                run_test "$feature" "$test_type" "$image"
            done
        done
    done
    
    # Run scenario tests if not in quick mode
    if [ "$QUICK_MODE" != true ]; then
        run_scenario_tests
    fi
    
    generate_report
}

# Run main function
main "$@"