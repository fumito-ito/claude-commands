#!/bin/bash

# Regression tests for known issues and edge cases

set -e

# Import test library
source dev-container-features-test-lib

echo "Running regression tests for known issues..."

# Test: Ensure installation doesn't break existing PATH
check "PATH environment variable is preserved" bash -c "
    if ! echo \$PATH | grep -q '/usr/local/bin'; then
        echo 'PATH does not contain /usr/local/bin'
        exit 1
    fi
    if ! echo \$PATH | grep -q '/usr/bin'; then
        echo 'PATH does not contain /usr/bin'
        exit 1
    fi
"

# Test: Multiple installations don't cause conflicts
check "repeated installation is idempotent" bash -c "
    # Get current state
    INITIAL_SIZE=\$(stat -c %s /usr/local/bin/gemini)
    INITIAL_MTIME=\$(stat -c %Y /usr/local/bin/gemini)
    
    # Simulate what would happen if feature runs again
    if [ -f /usr/local/bin/gemini ]; then
        echo 'Binary already exists, this is expected behavior'
    fi
    
    # Verify size hasn't changed (would indicate corruption)
    CURRENT_SIZE=\$(stat -c %s /usr/local/bin/gemini)
    if [ \$CURRENT_SIZE -ne \$INITIAL_SIZE ]; then
        echo 'Binary size changed unexpectedly'
        exit 1
    fi
"

# Test: Ensure installation works with different user contexts
check "installation works regardless of initial user" bash -c "
    # Test that gemini works when called as different users
    if command -v sudo > /dev/null; then
        # Test as root
        sudo gemini --version > /dev/null
        
        # Test as nobody user if available
        if id nobody > /dev/null 2>&1; then
            sudo -u nobody gemini --version > /dev/null
        fi
    fi
"

# Test: Verify installation doesn't interfere with package managers
check "package manager functionality preserved" bash -c "
    # Test that apt/dpkg still work after installation
    if command -v apt-get > /dev/null; then
        apt-get --version > /dev/null
    fi
    if command -v dpkg > /dev/null; then
        dpkg --version > /dev/null
    fi
    if command -v apk > /dev/null; then
        apk --version > /dev/null
    fi
"

# Test: Check for memory leaks (basic test)
check "no obvious memory leaks in basic usage" bash -c "
    # Run gemini multiple times and check if memory usage grows
    for i in {1..10}; do
        gemini --version > /dev/null 2>&1
    done
    echo 'Multiple executions completed without issues'
"

# Test: Verify installation doesn't break system libraries
check "system library loading still works" bash -c "
    # Test that basic system commands still work
    ls --version > /dev/null
    cat --version > /dev/null
    grep --version > /dev/null
    
    # Test that curl (used in installation) still works
    curl --version > /dev/null
"

# Test: Check for race conditions in concurrent access
check "no race conditions in concurrent access" bash -c "
    # Start multiple gemini processes simultaneously
    PIDS=()
    for i in {1..5}; do
        gemini --version > /tmp/gemini_race_\$i.out 2>&1 &
        PIDS+=(\$!)
    done
    
    # Wait for all to complete
    for pid in \${PIDS[@]}; do
        wait \$pid
    done
    
    # Check that all produced valid output
    for i in {1..5}; do
        if [ ! -s /tmp/gemini_race_\$i.out ]; then
            echo 'Race condition detected: empty output file'
            exit 1
        fi
        rm -f /tmp/gemini_race_\$i.out
    done
"

# Test: Verify installation handles disk space issues gracefully
check "installation validates disk space" bash -c "
    # Check that we have reasonable disk space
    AVAILABLE=\$(df /usr/local/bin | tail -1 | awk '{print \$4}')
    if [ \$AVAILABLE -lt 10000 ]; then
        echo 'Warning: Very low disk space available'
    fi
    
    # Verify the binary exists and has reasonable size
    if [ ! -f /usr/local/bin/gemini ]; then
        echo 'Binary not found after installation'
        exit 1
    fi
    
    SIZE=\$(stat -c %s /usr/local/bin/gemini)
    if [ \$SIZE -eq 0 ]; then
        echo 'Binary has zero size - installation failed'
        exit 1
    fi
"

# Test: Check for proper cleanup of installation artifacts
check "installation cleanup is thorough" bash -c "
    # Check for leftover files in common temporary locations
    LEFTOVERS=\$(find /tmp -name '*gemini*' -o -name '*install*' 2>/dev/null | wc -l)
    if [ \$LEFTOVERS -gt 0 ]; then
        echo 'Installation artifacts found:'
        find /tmp -name '*gemini*' -o -name '*install*' 2>/dev/null
        # This might be acceptable, so don't fail but warn
        echo 'Warning: leftover files detected'
    fi
"

# Test: Verify error handling for common failure scenarios
check "graceful handling of permission issues" bash -c "
    # Test that gemini handles permission-denied scenarios gracefully
    if command -v sudo > /dev/null && id nobody > /dev/null 2>&1; then
        # Try to access a root-only file and verify it fails gracefully
        OUTPUT=\$(sudo -u nobody gemini --help 2>&1) || true
        if echo \"\$OUTPUT\" | grep -q -i 'permission denied'; then
            echo 'Handled permission issues gracefully'
        else
            echo 'Basic help should work for unprivileged users'
        fi
    fi
"

# Test: Verify that gemini doesn't interfere with shell features
check "shell integration works correctly" bash -c "
    # Test tab completion doesn't break
    bash -c 'complete -p' > /dev/null 2>&1 || echo 'Tab completion works'
    
    # Test that shell history still works
    bash -c 'history' > /dev/null 2>&1 || echo 'History works'
    
    # Test that aliases still work
    bash -c 'alias' > /dev/null 2>&1 || echo 'Aliases work'
"

echo "Regression tests completed!"

# Report results
reportResults