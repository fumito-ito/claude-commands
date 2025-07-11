#!/bin/bash
set -e

# Import the utils
source ./library_scripts.sh

# Detect package manager early
PKG_MANAGER=$(detect_package_manager)
echo "Detected package manager: $PKG_MANAGER"

VERSION=${VERSION:-"latest"}

echo "Installing OpenAI Codex CLI..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    USERNAME="${USERNAME:-"automatic"}"
else
    USERNAME=$(whoami)
fi

# Determine the appropriate non-root user
determine_user_details() {
    if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
        USERNAME=""
        POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
        for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
            if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
                USERNAME=${CURRENT_USER}
                break
            fi
        done
        if [ "${USERNAME}" = "" ]; then
            USERNAME=root
        fi
    elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
        USERNAME=root
    fi
}

determine_user_details

# Get the home directory
if [ "${USERNAME}" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/${USERNAME}"
fi

# Install dependencies
echo "Installing dependencies..."
apt_get_update_if_needed
check_packages curl ca-certificates

# Install Node.js if not present
if ! command -v node > /dev/null 2>&1; then
    echo "Installing Node.js..."
    PKG_MANAGER=$(detect_package_manager)
    
    case $PKG_MANAGER in
        "apt")
            # Install Node.js from NodeSource repository
            curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
            apt-get install -y nodejs
            ;;
        "apk")
            # For Alpine, install Node.js directly
            apk add --no-cache nodejs npm
            ;;
        *)
            echo "Unknown package manager, cannot install Node.js"
            exit 1
            ;;
    esac
fi

# Install codex-cli using npm
echo "Installing OpenAI Codex CLI using npm..."
if [ "${VERSION}" = "latest" ]; then
    npm install -g @openai/codex
else
    npm install -g @openai/codex@${VERSION}
fi

# Verify installation
if command -v codex > /dev/null 2>&1; then
    echo "OpenAI Codex CLI installed successfully!"
    codex --version
else
    echo "Failed to install OpenAI Codex CLI"
    exit 1
fi

echo "Installation complete!"
echo "Note: You will need to set your OpenAI API key:"
echo "export OPENAI_API_KEY=\"your-api-key-here\""