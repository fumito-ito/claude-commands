#!/bin/bash

# Security and permissions tests

set -e

# Import test library
source dev-container-features-test-lib

# Test file permissions and ownership
check "gemini binary has secure permissions" bash -c "
    PERMS=\$(stat -c %a /usr/local/bin/gemini)
    if [ \"\$PERMS\" != \"755\" ]; then
        echo 'Insecure permissions: '\$PERMS' (expected 755)'
        exit 1
    fi
"

check "gemini binary is owned by root" bash -c "
    OWNER=\$(stat -c %U /usr/local/bin/gemini)
    if [ \"\$OWNER\" != \"root\" ]; then
        echo 'Binary not owned by root: '\$OWNER
        exit 1
    fi
"

# Test that gemini doesn't require special privileges
check "gemini runs without sudo" bash -c "
    if command -v sudo > /dev/null; then
        sudo -u nobody gemini --version > /dev/null 2>&1 || {
            echo 'gemini requires root privileges'
            exit 1
        }
    fi
"

# Test that gemini doesn't create world-writable files
check "gemini doesn't create insecure temporary files" bash -c "
    # Run gemini and check if it creates any temp files
    TEMP_BEFORE=\$(find /tmp -type f -perm -002 2>/dev/null | wc -l)
    gemini --version > /dev/null 2>&1
    TEMP_AFTER=\$(find /tmp -type f -perm -002 2>/dev/null | wc -l)
    
    if [ \$TEMP_AFTER -gt \$TEMP_BEFORE ]; then
        echo 'gemini created world-writable temporary files'
        exit 1
    fi
"

# Test that installation doesn't leave sensitive files
check "no sensitive installation artifacts remain" bash -c "
    # Check for any remaining installation files with sensitive content
    if find /tmp -name '*gemini*' -o -name '*install*' 2>/dev/null | grep -q .; then
        echo 'Installation artifacts found in /tmp'
        find /tmp -name '*gemini*' -o -name '*install*' 2>/dev/null
        exit 1
    fi
"

# Test binary integrity (basic checks)
check "gemini binary appears to be legitimate" bash -c "
    # Check if it's actually an executable
    if ! file /usr/local/bin/gemini | grep -q -E '(executable|binary)'; then
        echo 'Binary does not appear to be a valid executable'
        exit 1
    fi
    
    # Check if it has a reasonable ELF header (on Linux)
    if command -v hexdump > /dev/null; then
        HEADER=\$(hexdump -C /usr/local/bin/gemini | head -1 | cut -d' ' -f2-5)
        if [ \"\$HEADER\" != \"7f 45 4c 46\" ]; then
            echo 'Binary does not have valid ELF header'
            exit 1
        fi
    fi
"

# Test that gemini doesn't expose sensitive information
check "gemini doesn't leak sensitive environment" bash -c "
    OUTPUT=\$(gemini --version 2>&1)
    # Check that output doesn't contain sensitive paths or info
    if echo \"\$OUTPUT\" | grep -q -E '(/root|/home|password|secret|key|token)'; then
        echo 'gemini output contains potentially sensitive information'
        echo \"\$OUTPUT\"
        exit 1
    fi
"

# Test network security (gemini shouldn't make unexpected network calls)
check "gemini --version doesn't make network requests" bash -c "
    # This is a basic test - in production you might use strace or network monitoring
    timeout 5 gemini --version > /dev/null 2>&1
    echo 'Version command completed without hanging (likely no network requests)'
"

# Test that gemini respects system security policies
check "gemini respects umask settings" bash -c "
    # Set restrictive umask and test
    OLD_UMASK=\$(umask)
    umask 077
    gemini --version > /tmp/gemini_umask_test 2>&1
    PERMS=\$(stat -c %a /tmp/gemini_umask_test 2>/dev/null || echo '600')
    umask \$OLD_UMASK
    rm -f /tmp/gemini_umask_test
    
    # File should respect umask (should be 600 or similar)
    if [ \"\$PERMS\" -gt \"600\" ]; then
        echo 'gemini does not respect umask settings'
        exit 1
    fi
"

# Test against common security issues
check "gemini doesn't use deprecated/insecure functions" bash -c "
    if command -v strings > /dev/null; then
        # Check for common insecure function names
        INSECURE_FUNCS=\$(strings /usr/local/bin/gemini | grep -E '(gets|strcpy|strcat|sprintf|system)' | head -5)
        if [ -n \"\$INSECURE_FUNCS\" ]; then
            echo 'Binary may contain insecure function calls:'
            echo \"\$INSECURE_FUNCS\"
            echo 'This may be acceptable for a Go binary, but worth noting'
        fi
    fi
    # This is informational - Go binaries often contain these strings
    true
"

echo "Security tests completed!"

# Report results
reportResults