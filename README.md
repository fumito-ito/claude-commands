# Dev Container Feature: Claude Code config

A Dev Container feature that clones a GitHub repository into the `.claude` directory for Claude integration.

## Usage

Add this feature to your `devcontainer.json`:

```json
{
    "features": {
        "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1": {
            "repo": "owner/repository-name"
        }
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `repo` | string | `""` | GitHub repository in `owner/repo` format |
| `branch` | string | `"main"` | Git branch to clone |
| `token` | string | `""` | GitHub Personal Access Token for private repositories |

## License

MIT License
