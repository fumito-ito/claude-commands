#!/bin/bash

# Utility functions for DevContainer features

# Detect package manager
detect_package_manager() {
    if command -v apt-get > /dev/null 2>&1; then
        echo "apt"
    elif command -v apk > /dev/null 2>&1; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# Update packages if needed
apt_get_update_if_needed() {
    PKG_MANAGER=$(detect_package_manager)
    
    case $PKG_MANAGER in
        "apt")
            if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
                echo "Running apt-get update..."
                apt-get update -y
            else
                echo "Skipping apt-get update."
            fi
            ;;
        "apk")
            echo "Running apk update..."
            apk update
            ;;
        *)
            echo "Unknown package manager, skipping update."
            ;;
    esac
}

# Check if packages are installed and install if missing
check_packages() {
    PKG_MANAGER=$(detect_package_manager)
    
    case $PKG_MANAGER in
        "apt")
            if ! dpkg -s "$@" > /dev/null 2>&1; then
                apt_get_update_if_needed
                apt-get -y install --no-install-recommends "$@"
            fi
            ;;
        "apk")
            # For Alpine, check if package is installed differently
            for package in "$@"; do
                if ! apk info -e "$package" > /dev/null 2>&1; then
                    echo "Installing $package with apk..."
                    apk add --no-cache "$package"
                fi
            done
            ;;
        *)
            echo "Unknown package manager, cannot install packages: $@"
            exit 1
            ;;
    esac
}

# Export functions
export -f apt_get_update_if_needed
export -f check_packages
export -f detect_package_manager