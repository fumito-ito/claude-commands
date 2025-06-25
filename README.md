# Dev Container Feature: Claude Commands

A Dev Container feature that automatically clones a GitHub repository into the `.claude/commands` directory when the container starts. This is useful for integrating Claude-specific commands or configurations into your development environment.

## Features

- 🚀 Automatically clones any GitHub repository during container initialization
- 📁 Places repository contents in `.claude/commands` directory
- 🌟 Configurable repository and branch selection
- 🧹 Excludes `.git` directory from the final destination
- 🛡️ Robust error handling and cleanup
- 📦 Works with any Dev Container base image

## Usage

Add this feature to your `devcontainer.json`:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-commands:1": {
            "repo": "owner/repository-name",
            "branch": "main"
        }
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `repo` | string | `""` | GitHub repository in `owner/repo` format (e.g., `microsoft/vscode`) |
| `branch` | string | `"main"` | Git branch to clone |

## Examples

### Basic Usage

```json
{
    "features": {
        "ghcr.io/your-username/devcontainer-features/claude-commands:1": {
            "repo": "your-org/claude-commands"
        }
    }
}
```

### With Specific Branch

```json
{
    "features": {
        "ghcr.io/your-username/devcontainer-features/claude-commands:1": {
            "repo": "your-org/claude-commands",
            "branch": "development"
        }
    }
}
```

## Directory Structure

After the container starts, your workspace will have:

```
/workspaces/your-project/
├── .claude/
│   └── commands/
│       ├── (contents of cloned repository)
│       ├── script1.sh
│       ├── config.json
│       └── ...
├── src/
├── .devcontainer/
│   └── devcontainer.json
└── ...
```

## How It Works

1. **Container Initialization**: When the Dev Container starts, this feature runs during the setup phase
2. **Repository Validation**: Validates the repository format (`owner/repo`)
3. **Git Installation**: Automatically installs Git if not present
4. **Workspace Detection**: Finds the appropriate workspace directory (typically `/workspaces/<project-name>`)
5. **Directory Creation**: Creates `.claude/commands` directory if it doesn't exist
6. **Repository Cloning**: Shallow clones the specified repository and branch
7. **Content Copying**: Copies all files except the `.git` directory to `.claude/commands`
8. **Cleanup**: Removes temporary files and directories

## Requirements

- Any Dev Container base image
- Internet access for cloning repositories
- Git (automatically installed if missing)

## Error Handling

The feature includes comprehensive error handling:

- **Invalid Repository Format**: Validates `owner/repo` format
- **Network Issues**: Handles clone failures gracefully
- **Missing Git**: Automatically installs Git on supported systems
- **Cleanup**: Ensures temporary directories are always cleaned up

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test with different base images
5. Submit a pull request

## License

MIT License - see LICENSE file for details
