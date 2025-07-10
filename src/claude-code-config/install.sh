#!/bin/bash

set -e

# Get the repo and token from the environment variables
REPO=${REPO:-"${CLAUDE_REPO:-""}"}
TOKEN=${TOKEN:-"${CLAUDE_TOKEN:-""}"}
BRANCH=${BRANCH:-"${CLAUDE_BRANCH:-"main"}"}

echo "Installing Claude Repository feature..."

# Store repository settings for runtime use
cat > /tmp/claude-config << EOF
REPO=${REPO}
BRANCH=${BRANCH}
TOKEN=${TOKEN}
EOF

# Create a runtime script that will create the .claude directory at the correct location
cat > /usr/local/bin/claude-setup.sh << 'EOF'
#!/bin/sh

# Load config
. /tmp/claude-config

# Determine the workspace folder (project root) at runtime
if [ -n "$CONTAINERWORKSPACEFOLDER" ]; then
    WORKSPACE_FOLDER="$CONTAINERWORKSPACEFOLDER"
else
    # Find the project directory in /workspaces
    WORKSPACE_FOLDER="/workspaces"
    for dir in /workspaces/*/; do
        if [ -d "$dir" ]; then
            WORKSPACE_FOLDER="${dir%/}"  # Remove trailing slash
            break
        fi
    done
fi

CLAUDE_DIR="${WORKSPACE_FOLDER}/.claude"

# Only create if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
    
    # If repo is specified and not already cloned, clone it
    if [ -n "$REPO" ] && [ -d "/tmp/claude-repo-cache" ]; then
        # Copy the cached repository content
        if [ "$(ls -A /tmp/claude-repo-cache 2>/dev/null)" ]; then
            (cd "/tmp/claude-repo-cache" && tar -cf - .) | (cd "$CLAUDE_DIR" && tar -xf -)
        fi
    fi
    
    # Set proper permissions for devcontainer user
    DEFAULT_USER=${_REMOTE_USER:-"vscode"}
    if id "$DEFAULT_USER" >/dev/null 2>&1; then
        chown -R "$DEFAULT_USER:$DEFAULT_USER" "$CLAUDE_DIR"
        chmod -R 755 "$CLAUDE_DIR"
        # Make files writable by the owner
        find "$CLAUDE_DIR" -type f -exec chmod 644 {} \; 2>/dev/null || true
    else
        chmod -R 777 "$CLAUDE_DIR"
    fi
fi
EOF

chmod +x /usr/local/bin/claude-setup.sh

# For build-time, create the basic structure
# Determine the workspace folder (project root)
# Use CONTAINERWORKSPACEFOLDER if available (this is the project root)
if [ -n "$CONTAINERWORKSPACEFOLDER" ]; then
    WORKSPACE_FOLDER="$CONTAINERWORKSPACEFOLDER"
else
    # Fallback: use /workspaces (this will be the case during build)
    # The actual project directory mounting happens at runtime
    WORKSPACE_FOLDER="/workspaces"
fi

CLAUDE_DIR="${WORKSPACE_FOLDER}/.claude"

# Check if .claude directory already exists
if [ -d "$CLAUDE_DIR" ]; then
    echo ".claude directory already exists at $CLAUDE_DIR"
    echo "Claude Code settings are already installed!"
    exit 0
fi

# Create .claude directory in workspace
mkdir -p "$CLAUDE_DIR"

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
        mkdir -p "$CLAUDE_DIR"
        echo "Created empty .claude directory due to missing git"
        exit 0
    fi
else
    echo "Git is already available at: $(command -v git)"
fi

# Verify git is now available
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git installation failed or git is still not available"
    mkdir -p "$CLAUDE_DIR"
    echo "Created empty .claude directory due to git unavailability"
    exit 0
fi

# If repo is specified, clone it to cache for runtime use
if [ -n "$REPO" ]; then
    echo "Cloning repository: $REPO (branch: $BRANCH)"
    
    # Build clone URL with token if provided
    if [ -n "$TOKEN" ]; then
        CLONE_URL="https://$TOKEN@github.com/$REPO.git"
        echo "Using GitHub token for private repository access"
    else
        CLONE_URL="https://github.com/$REPO.git"
    fi
    
    # Clone the repository to a cache location for runtime use
    if git clone --branch "$BRANCH" "$CLONE_URL" "/tmp/claude-repo"; then
        # Create cache directory for runtime use
        mkdir -p "/tmp/claude-repo-cache"
        # Copy all files except .git directory to cache
        (cd "/tmp/claude-repo" && tar --exclude='.git' -cf - .) | (cd "/tmp/claude-repo-cache" && tar -xf -)
        
        # Clean up temporary directory
        rm -rf "/tmp/claude-repo"
        
        echo "Repository cached for runtime deployment"
        
        # Also create at build-time location for immediate use
        mkdir -p "$CLAUDE_DIR"
        (cd "/tmp/claude-repo-cache" && tar -cf - .) | (cd "$CLAUDE_DIR" && tar -xf -)
        echo "Repository deployed to $CLAUDE_DIR"
    else
        echo "Warning: Failed to clone repository $REPO. Creating empty .claude directory instead."
        mkdir -p "$CLAUDE_DIR"
    fi
else
    # Create empty .claude directory
    mkdir -p "$CLAUDE_DIR"
    echo "Created empty .claude directory"
fi

# Set proper permissions for devcontainer user
# Get the default devcontainer user (usually vscode)
DEFAULT_USER=${_REMOTE_USER:-"vscode"}

# Check if the user exists
if id "$DEFAULT_USER" >/dev/null 2>&1; then
    echo "Setting ownership of .claude directory to $DEFAULT_USER"
    chown -R "$DEFAULT_USER:$DEFAULT_USER" "$CLAUDE_DIR"
    chmod -R 755 "$CLAUDE_DIR"
    # Make files writable by the owner
    find "$CLAUDE_DIR" -type f -exec chmod 644 {} \;
else
    echo "Warning: User $DEFAULT_USER not found. Setting permissions to be world-writable."
    chmod -R 777 "$CLAUDE_DIR"
fi

# Set up shell init to run the runtime setup
# Add to both bash and sh profiles for broader compatibility
if [ -f /etc/bash.bashrc ]; then
    echo '# Claude setup - ensure .claude directory is in the right place' >> /etc/bash.bashrc
    echo '/usr/local/bin/claude-setup.sh' >> /etc/bash.bashrc
fi

# For Alpine and other minimal distributions
if [ -f /etc/profile ]; then
    echo '# Claude setup - ensure .claude directory is in the right place' >> /etc/profile
    echo '/usr/local/bin/claude-setup.sh' >> /etc/profile
fi

echo "Claude Repository feature installed successfully!"