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

### 🤖 OpenAI Codex CLI

Installs the OpenAI Codex CLI tool - a lightweight coding agent that runs in your terminal.

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/codex-cli:1": {
            "version": "latest"
        }
    }
}
```

**Options:**
- `version` (string, default: `latest`): Version of Codex CLI to install

**Note:** Requires OpenAI API key set as `OPENAI_API_KEY` environment variable.

## Usage Examples

### Using Multiple Features Together

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1": {
            "repo": "my-org/my-config-repo"
        },
        "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {},
        "ghcr.io/fumito-ito/devcontainer-features/codex-cli:1": {}
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

### AI CLI Tools Only

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {
            "version": "latest"
        },
        "ghcr.io/fumito-ito/devcontainer-features/codex-cli:1": {
            "version": "latest"
        }
    }
}
```

**Environment Variables:**
- `OPENAI_API_KEY`: Required for Codex CLI
- `GOOGLE_API_KEY`: Required for Gemini CLI (if applicable)

## Development

### Testing

```bash
# Run all tests
make test-all

# Test specific features
make test-claude   # Claude Code Config
make test-gemini   # Gemini CLI
make test-codex    # Codex CLI
make test-all-features  # All features together

# Test with different base images
make test-ubuntu
make test-debian
make test-alpine
```

### Prerequisites

- DevContainer CLI (`npm install -g @devcontainers/cli`)
- Docker with daemon running

### Publishing

Features are automatically published to GitHub Container Registry when changes are pushed to the main branch via GitHub Actions.

**Package URLs:**
- [claude-code-config](https://github.com/users/fumito-ito/packages/container/devcontainer-features%2Fclaude-code-config/settings)
- [gemini-cli](https://github.com/users/fumito-ito/packages/container/devcontainer-features%2Fgemini-cli/settings)
- [codex-cli](https://github.com/users/fumito-ito/packages/container/devcontainer-features%2Fcodex-cli/settings)

## License

MIT License
