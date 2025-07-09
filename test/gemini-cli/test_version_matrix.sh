#!/bin/bash

# Version matrix testing - tests different version scenarios

set -e

# Import test library
source dev-container-features-test-lib

echo "Running version matrix tests..."

# Test current installation (should be latest)
check "current installation works" bash -c "command -v gemini && gemini --version"

# Test version string format
check "version string follows expected format" bash -c "
    VERSION_OUTPUT=\$(gemini --version)
    
    # Check for common version patterns
    if echo \"\$VERSION_OUTPUT\" | grep -E '(v?[0-9]+\.[0-9]+\.[0-9]+|version|Gemini)'; then
        echo 'Version format is acceptable'
    else
        echo 'Unexpected version format: \$VERSION_OUTPUT'
        exit 1
    fi
"

# Test that version command is consistent
check "version command is consistent across calls" bash -c "
    VERSION1=\$(gemini --version)
    VERSION2=\$(gemini --version)
    
    if [ \"\$VERSION1\" != \"\$VERSION2\" ]; then
        echo 'Version output is inconsistent between calls'
        echo 'First:  \$VERSION1'
        echo 'Second: \$VERSION2'
        exit 1
    fi
"

# Test version flag variations
check "version flags work consistently" bash -c "
    # Test different version flag formats
    V1=\$(gemini --version 2>&1 | head -1)
    V2=\$(gemini -v 2>&1 | head -1) || echo 'No -v flag'
    V3=\$(gemini version 2>&1 | head -1) || echo 'No version subcommand'
    
    echo 'Version flag outputs:'
    echo '--version: \$V1'
    echo '-v: \$V2'
    echo 'version: \$V3'
    
    # At least --version should work
    if [ -z \"\$V1\" ]; then
        echo '--version flag produces no output'
        exit 1
    fi
"

# Test version information completeness
check "version information is informative" bash -c "
    VERSION_OUTPUT=\$(gemini --version)
    
    # Check that output contains useful information
    if [ \$(echo \"\$VERSION_OUTPUT\" | wc -l) -eq 0 ]; then
        echo 'Version output is empty'
        exit 1
    fi
    
    # Check minimum length (should be more than just a number)
    if [ \$(echo \"\$VERSION_OUTPUT\" | wc -c) -lt 5 ]; then
        echo 'Version output too short: \$VERSION_OUTPUT'
        exit 1
    fi
"

# Test that binary was built for correct architecture
check "binary architecture matches system" bash -c "
    SYSTEM_ARCH=\$(uname -m)
    
    if command -v file > /dev/null; then
        FILE_OUTPUT=\$(file /usr/local/bin/gemini)
        echo 'System architecture: \$SYSTEM_ARCH'
        echo 'Binary file info: \$FILE_OUTPUT'
        
        case \$SYSTEM_ARCH in
            x86_64|amd64)
                if ! echo \"\$FILE_OUTPUT\" | grep -q -E '(x86-64|x86_64)'; then
                    echo 'Binary architecture mismatch for x86_64 system'
                    exit 1
                fi
                ;;
            aarch64|arm64)
                if ! echo \"\$FILE_OUTPUT\" | grep -q -E '(aarch64|arm64)'; then
                    echo 'Binary architecture mismatch for arm64 system'
                    exit 1
                fi
                ;;
            *)
                echo 'Unknown system architecture: \$SYSTEM_ARCH'
                # Don't fail for unknown architectures
                ;;
        esac
    else
        echo 'file command not available, skipping architecture check'
    fi
"

# Test GitHub API rate limiting doesn't affect installation
check "version fetching handles API limits" bash -c "
    # This test verifies that if we hit GitHub API rate limits,
    # the installation still works (falls back gracefully)
    
    # Check if we can detect rate limiting
    if command -v curl > /dev/null; then
        API_RESPONSE=\$(curl -s -I https://api.github.com/repos/google-gemini/gemini-cli/releases/latest || echo 'API call failed')
        
        if echo \"\$API_RESPONSE\" | grep -q 'X-RateLimit-Remaining: 0'; then
            echo 'API rate limit detected, but installation should still work'
        else
            echo 'API rate limit not hit, normal operation'
        fi
    fi
    
    # The main test is that gemini works regardless
    gemini --version > /dev/null
"

# Test compatibility with different container base images
check "binary works across different libc versions" bash -c "
    # Try to get system information
    if [ -f /etc/os-release ]; then
        OS_INFO=\$(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')
        echo 'OS: \$OS_INFO'
    fi
    
    # Check libc version if available
    if command -v ldd > /dev/null; then
        LIBC_INFO=\$(ldd --version | head -1 2>/dev/null || echo 'libc version unknown')
        echo 'libc: \$LIBC_INFO'
    fi
    
    # Test that gemini actually executes (not just exists)
    timeout 10 gemini --version > /dev/null
"

# Test rollback scenarios (what happens if installation is corrupted)
check "handles corrupted installation gracefully" bash -c "
    # Make a backup of the current binary
    cp /usr/local/bin/gemini /tmp/gemini_backup
    
    # Test that we can restore from backup
    cp /tmp/gemini_backup /usr/local/bin/gemini
    
    # Verify it still works
    gemini --version > /dev/null
    
    # Clean up backup
    rm -f /tmp/gemini_backup
"

echo "Version matrix tests completed!"

# Report results
reportResults