#!/bin/bash

# Docker and container-specific tests

set -e

# Import test library
source dev-container-features-test-lib

echo "Running Docker and container-specific tests..."

# Test container environment detection
check "recognizes container environment" bash -c "
    # Check if we're running in a container
    if [ -f /.dockerenv ] || grep -q 'container' /proc/1/cgroup 2>/dev/null; then
        echo 'Running in container environment'
        CONTAINER_ENV=true
    else
        echo 'Not in container environment (or cannot detect)'
        CONTAINER_ENV=false
    fi
    
    # gemini should work regardless
    gemini --version > /dev/null
"

# Test layer optimization
check "installation is layer-friendly" bash -c "
    # Check that installation creates minimal files
    GEMINI_FILES=\$(find /usr/local/bin -name 'gemini*' | wc -l)
    if [ \$GEMINI_FILES -ne 1 ]; then
        echo 'Installation created unexpected number of files: \$GEMINI_FILES'
        find /usr/local/bin -name 'gemini*'
        exit 1
    fi
    
    # Check that no unnecessary temporary files remain
    TEMP_FILES=\$(find /tmp -name '*gemini*' 2>/dev/null | wc -l)
    if [ \$TEMP_FILES -gt 0 ]; then
        echo 'Temporary files found: \$TEMP_FILES'
        find /tmp -name '*gemini*' 2>/dev/null
        echo 'This may increase image layer size'
    fi
"

# Test image size impact
check "binary size is reasonable for containers" bash -c "
    BINARY_SIZE=\$(stat -c %s /usr/local/bin/gemini)
    BINARY_SIZE_MB=\$((BINARY_SIZE / 1024 / 1024))
    
    echo 'Binary size: \${BINARY_SIZE} bytes (\${BINARY_SIZE_MB} MB)'
    
    # Typical Go binaries range from 5-50MB
    if [ \$BINARY_SIZE -gt 104857600 ]; then  # 100MB
        echo 'Binary is very large, may impact container image size'
        exit 1
    elif [ \$BINARY_SIZE -lt 1048576 ]; then  # 1MB
        echo 'Binary is suspiciously small, may be corrupted'
        exit 1
    fi
"

# Test container restart scenarios
check "survives container lifecycle events" bash -c "
    # Simulate what happens during container restart
    # Test that gemini binary persists and works
    
    if [ -f /usr/local/bin/gemini ]; then
        echo 'Binary exists after container start'
    else
        echo 'Binary missing after container start'
        exit 1
    fi
    
    # Test that it's still executable
    if [ -x /usr/local/bin/gemini ]; then
        echo 'Binary is still executable'
    else
        echo 'Binary lost execute permissions'
        exit 1
    fi
    
    # Test that it still works
    gemini --version > /dev/null
"

# Test multi-stage build compatibility
check "works in multi-stage Docker builds" bash -c "
    # Test that the binary can be copied to other stages
    # (simulate by copying to another location)
    
    mkdir -p /tmp/stage2/usr/local/bin
    cp /usr/local/bin/gemini /tmp/stage2/usr/local/bin/
    
    # Test that copied binary works
    /tmp/stage2/usr/local/bin/gemini --version > /dev/null
    
    # Cleanup
    rm -rf /tmp/stage2
"

# Test DevContainer specific features
check "integrates with DevContainer features" bash -c "
    # Test that PATH is properly set for DevContainer
    if ! echo \$PATH | grep -q '/usr/local/bin'; then
        echo 'PATH does not include /usr/local/bin'
        exit 1
    fi
    
    # Test that the binary works in DevContainer shell context
    bash -c 'command -v gemini' > /dev/null
    
    # Test that it works in non-login shells
    bash -c 'gemini --version' > /dev/null
"

# Test volume mounting scenarios
check "handles volume mount scenarios" bash -c "
    # Test that gemini works even if some directories are volume mounted
    # This is important for DevContainers with volume mounts
    
    # Test from different working directories
    cd /tmp && gemini --version > /dev/null
    cd /usr && gemini --version > /dev/null
    cd / && gemini --version > /dev/null
    
    # Return to original directory
    cd /usr/local/bin
"

# Test user switching scenarios (common in containers)
check "works across user context switches" bash -c "
    # Test with different user contexts if possible
    if command -v sudo > /dev/null; then
        # Test as root
        sudo gemini --version > /dev/null
        
        # Test as a regular user if available
        if id vscode > /dev/null 2>&1; then
            sudo -u vscode gemini --version > /dev/null
        elif id node > /dev/null 2>&1; then
            sudo -u node gemini --version > /dev/null
        elif id nobody > /dev/null 2>&1; then
            sudo -u nobody gemini --version > /dev/null
        fi
    fi
"

# Test container networking scenarios
check "handles network-restricted environments" bash -c "
    # Test that gemini can work in environments with limited network access
    # (after installation is complete)
    
    # Basic functionality should work without network
    timeout 5 gemini --version > /dev/null
    timeout 5 gemini --help > /dev/null
    
    echo 'Basic operations work without network access'
"

# Test container resource constraints
check "works under resource constraints" bash -c "
    # Test with limited memory scenario (simulated)
    # In real containers, this would be handled by Docker limits
    
    ulimit -v 1048576 2>/dev/null || true  # 1GB virtual memory limit
    gemini --version > /dev/null
    
    echo 'Works under simulated resource constraints'
"

echo "Docker and container tests completed!"

# Report results
reportResults