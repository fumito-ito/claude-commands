#!/bin/bash

# Utility functions for DevContainer features

# Update apt packages if needed
apt_get_update_if_needed() {
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    else
        echo "Skipping apt-get update."
    fi
}

# Check if packages are installed and install if missing
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Export functions
export -f apt_get_update_if_needed
export -f check_packages