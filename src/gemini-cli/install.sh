#!/bin/bash
set -e

# Import the utils
source ./library_scripts.sh

# Nanolayer utilities
. /tmp/library-scripts/nanolayer-utils.sh

VERSION=${VERSION:-"latest"}

echo "Installing Gemini CLI..."

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

# Create temporary directory
TEMP_DIR="/tmp/gemini-cli-install"
mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}

# Determine architecture
ARCHITECTURE=$(uname -m)
case ${ARCHITECTURE} in
    x86_64) ARCH="x86_64" ;;
    amd64) ARCH="x86_64" ;;
    aarch64) ARCH="arm64" ;;
    arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${ARCHITECTURE}"; exit 1 ;;
esac

# Determine OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Get the latest release if version is "latest"
if [ "${VERSION}" = "latest" ]; then
    echo "Fetching latest version..."
    LATEST_VERSION=$(curl -s https://api.github.com/repos/google-gemini/gemini-cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "${LATEST_VERSION}" ]; then
        echo "Failed to get latest version"
        exit 1
    fi
    VERSION=${LATEST_VERSION}
fi

echo "Installing Gemini CLI version: ${VERSION}"

# Download the binary
BINARY_NAME="gemini-${OS}-${ARCH}"
if [ "${OS}" = "linux" ]; then
    DOWNLOAD_URL="https://github.com/google-gemini/gemini-cli/releases/download/${VERSION}/gemini-${OS}-${ARCH}"
else
    echo "Unsupported OS: ${OS}"
    exit 1
fi

echo "Downloading from: ${DOWNLOAD_URL}"
curl -L -o gemini "${DOWNLOAD_URL}"

# Make executable
chmod +x gemini

# Install to /usr/local/bin
mv gemini /usr/local/bin/

# Verify installation
if command -v gemini > /dev/null 2>&1; then
    echo "Gemini CLI installed successfully!"
    gemini --version
else
    echo "Failed to install Gemini CLI"
    exit 1
fi

# Clean up
cd /
rm -rf ${TEMP_DIR}

echo "Installation complete!"