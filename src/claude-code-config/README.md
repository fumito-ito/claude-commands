# Claude Code config Feature

This repository contains a [Dev Container Feature](https://containers.dev/implementors/features/) that clones GitHub repositories into the `.claude` directory for Claude integration.

## Contents

- `src/claude-code-config`: The Claude Repository feature
- `test`: Automated tests for the feature

## Usage

To use this feature in your devcontainer, add it to your `devcontainer.json` file:

```json
"features": {
    "ghcr.io/fumito-ito/devcontainer-features/claude-code-config:1.0": {
        "repo": "owner/repository-name",
        "branch": "main",
        "token": "your-github-token"
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `repo` | string | `""` | GitHub repository in `owner/repo` format |
| `branch` | string | `"main"` | Git branch to clone |
| `token` | string | `""` | GitHub Personal Access Token for private repositories (optional) |

## Private Repository Support

To clone private repositories, you need to provide a GitHub Personal Access Token:

1. Create a [Personal Access Token](https://github.com/settings/tokens) with repository access
2. Pass it as the `token` option in your devcontainer configuration

The token will be used securely during the container build process and will not be stored in the final container.

## Requirements

The feature automatically installs Git if not already present.

## Building and Testing

You can build and test the feature using the [dev container CLI](https://github.com/devcontainers/cli):

```bash
# Test the feature
devcontainer features test -f claude-code-config .
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.