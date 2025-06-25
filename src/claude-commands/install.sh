#!/bin/bash

set -e

# Get the repo from the environment variable
REPO=${REPO:-""}

echo "Installing Claude Commands feature..."

# Create .claude directory in workspace
mkdir -p /workspaces/.claude

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not available. Installing git..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update && apt-get install -y git
    elif command -v apk >/dev/null 2>&1; then
        apk update && apk add git
    else
        echo "Error: Cannot install git. Package manager not found."
        mkdir -p /workspaces/.claude/commands
        echo "Created empty .claude/commands directory due to missing git"
        exit 0
    fi
fi

# If repo is specified, clone it
if [ -n "$REPO" ]; then
    echo "Cloning repository: $REPO"
    
    # Clone the repository to a temporary location
    if git clone "https://github.com/$REPO.git" "/tmp/claude-commands-repo"; then
        # Move the contents to .claude/commands (excluding .git)
        mkdir -p /workspaces/.claude/commands
        
        # Copy all files except .git directory
        rsync -av --exclude='.git' "/tmp/claude-commands-repo/" "/workspaces/.claude/commands/"
        
        # Clean up temporary directory
        rm -rf "/tmp/claude-commands-repo"
        
        echo "Repository cloned successfully to /workspaces/.claude/commands"
    else
        echo "Warning: Failed to clone repository $REPO. Creating empty .claude/commands directory instead."
        mkdir -p /workspaces/.claude/commands
    fi
else
    # Create empty commands directory
    mkdir -p /workspaces/.claude/commands
    echo "Created empty .claude/commands directory"
fi

echo "Claude Commands feature installed successfully!"