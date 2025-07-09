#!/bin/bash

# Performance and installation speed tests

set -e

# Import test library
source dev-container-features-test-lib

# Start timing
START_TIME=$(date +%s)

# Test basic functionality to ensure it's working
check "gemini command exists" bash -c "command -v gemini"

# Test command execution performance
check "gemini --version executes quickly" bash -c "timeout 5 time gemini --version"
check "gemini --help executes quickly" bash -c "timeout 5 time gemini --help"

# Test binary size is reasonable (not too large, not suspiciously small)
check "gemini binary size is reasonable" bash -c "
    SIZE=\$(stat -c %s /usr/local/bin/gemini)
    if [ \$SIZE -lt 1000000 ]; then
        echo 'Binary too small (< 1MB), might be corrupted'
        exit 1
    elif [ \$SIZE -gt 100000000 ]; then
        echo 'Binary too large (> 100MB), might include unnecessary dependencies'
        exit 1
    else
        echo 'Binary size OK: '\$SIZE' bytes'
    fi
"

# Test memory usage during execution
check "gemini memory usage is reasonable" bash -c "
    # Run gemini --version and capture memory usage
    /usr/bin/time -v gemini --version 2>&1 | grep 'Maximum resident set size' | awk '{
        if (\$6 > 100000) {
            print \"Memory usage too high: \" \$6 \" KB\"
            exit 1
        } else {
            print \"Memory usage OK: \" \$6 \" KB\"
        }
    }'
"

# Test concurrent execution (simulate multiple users)
check "gemini handles concurrent execution" bash -c "
    for i in {1..5}; do
        gemini --version &
    done
    wait
    echo 'All concurrent executions completed'
"

# Test startup time
check "gemini starts up quickly" bash -c "
    START=\$(date +%s%N)
    gemini --version > /dev/null
    END=\$(date +%s%N)
    DURATION=\$(( (END - START) / 1000000 ))
    if [ \$DURATION -gt 1000 ]; then
        echo 'Startup too slow: '\$DURATION'ms'
        exit 1
    else
        echo 'Startup time OK: '\$DURATION'ms'
    fi
"

# Calculate total test time
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

check "entire test suite runs in reasonable time" bash -c "
    if [ $TOTAL_TIME -gt 30 ]; then
        echo 'Test suite too slow: ${TOTAL_TIME}s'
        exit 1
    else
        echo 'Test suite time OK: ${TOTAL_TIME}s'
    fi
"

echo "Performance tests completed in ${TOTAL_TIME} seconds!"

# Report results
reportResults