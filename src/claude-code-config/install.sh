#!/bin/bash

set -e

# Get the repo and token from the environment variables
REPO=${REPO:-"${CLAUDE_REPO:-""}"}
TOKEN=${TOKEN:-"${CLAUDE_TOKEN:-""}"}
BRANCH=${BRANCH:-"${CLAUDE_BRANCH:-"main"}"}

echo "Installing Claude Repository feature..."

# Check if .claude directory already exists
if [ -d "/workspaces/.claude" ]; then
    echo ".claude directory already exists at /workspaces/.claude"
    echo "Claude Code settings are already installed!"
    exit 0
fi

# Create .claude directory in workspace
mkdir -p /workspaces/.claude

# Check if git is available and install if needed
echo "Checking for git availability..."
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not available. Installing git..."
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update && apt-get install -y git
    elif command -v apk >/dev/null 2>&1; then
        apk update && apk add git
    else
        echo "Error: Cannot install git. Package manager not found."
        mkdir -p /workspaces/.claude
        echo "Created empty .claude directory due to missing git"
        exit 0
    fi
else
    echo "Git is already available at: $(command -v git)"
fi

# Verify git is now available
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git installation failed or git is still not available"
    mkdir -p /workspaces/.claude
    echo "Created empty .claude directory due to git unavailability"
    exit 0
fi

# If repo is specified, clone it
if [ -n "$REPO" ]; then
    echo "Cloning repository: $REPO (branch: $BRANCH)"
    
    # Build clone URL with token if provided
    if [ -n "$TOKEN" ]; then
        CLONE_URL="https://$TOKEN@github.com/$REPO.git"
        echo "Using GitHub token for private repository access"
    else
        CLONE_URL="https://github.com/$REPO.git"
    fi
    
    # Clone the repository to a temporary location
    if git clone --branch "$BRANCH" "$CLONE_URL" "/tmp/claude-repo"; then
        # Copy all files except .git directory directly to .claude
        (cd "/tmp/claude-repo" && tar --exclude='.git' -cf - .) | (cd "/workspaces/.claude" && tar -xf -)
        
        # Clean up temporary directory
        rm -rf "/tmp/claude-repo"
        
        echo "Repository cloned successfully to /workspaces/.claude"
    else
        echo "Warning: Failed to clone repository $REPO. Creating empty .claude directory instead."
        mkdir -p /workspaces/.claude
    fi
else
    # Create empty .claude directory
    mkdir -p /workspaces/.claude
    echo "Created empty .claude directory"
fi

echo "Claude Repository feature installed successfully!"