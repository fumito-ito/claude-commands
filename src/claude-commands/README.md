# Dev Container Features

This repository contains [Dev Container Features](https://containers.dev/implementors/features/), including one that clones GitHub repositories into the `.claude/commands` directory.

## Contents

- `src/claude-commands`: The Claude Commands feature
- `test`: Automated tests for the feature

## Usage

To use this feature in your devcontainer, add it to your `devcontainer.json` file:

```json
"features": {
    "ghcr.io/fumito-ito/devcontainer-features/claude-commands:1.0": {
        "repo": "owner/repository-name",
        "branch": "main"
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `repo` | string | `""` | GitHub repository in `owner/repo` format |
| `branch` | string | `"main"` | Git branch to clone |

## Requirements

The feature automatically installs Git if not already present.

## Building and Testing

You can build and test the feature using the [dev container CLI](https://github.com/devcontainers/cli):

```bash
# Test the feature
devcontainer features test -f claude-commands .

# Publish the feature
devcontainer features publish -n your-username/devcontainer-features .
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.