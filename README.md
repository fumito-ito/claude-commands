# DevContainer Features

A collection of DevContainer features for enhancing development environments.

## Features

### 🤖 Claude Code Config

Clones a GitHub repository into the `.claude` directory for Claude Code integration.

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1": {
            "repo": "owner/repository-name",
            "branch": "main"
        }
    }
}
```

**Options:**
- `repo` (string): GitHub repository in `owner/repo` format
- `branch` (string, default: `main`): Git branch to clone
- `token` (string, optional): GitHub Personal Access Token for private repositories

### 🔮 Gemini CLI

Installs the Google Gemini CLI tool for interacting with Gemini AI models.

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {
            "version": "latest"
        }
    }
}
```

**Options:**
- `version` (string, default: `latest`): Version of Gemini CLI to install

## Usage Examples

### Using Both Features Together

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1": {
            "repo": "my-org/my-config-repo"
        },
        "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {}
    }
}
```

### Private Repository with Token

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1": {
            "repo": "my-org/private-repo",
            "token": "${localEnv:GITHUB_TOKEN}"
        }
    }
}
```

## Development

### Testing

```bash
# Run all tests
make test-all

# Test specific feature
make test

# Test with different base images
make test-ubuntu
make test-debian
make test-alpine
```

### Prerequisites

- DevContainer CLI (`npm install -g @devcontainers/cli`)
- Docker with daemon running

## License

MIT License
