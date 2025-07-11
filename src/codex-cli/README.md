# OpenAI Codex CLI DevContainer Feature

This DevContainer feature installs the [OpenAI Codex CLI](https://github.com/openai/codex) tool - a lightweight coding agent that runs in your terminal.

## Usage

```json
{
  "features": {
    "ghcr.io/fumito-ito/devcontainer-features/codex-cli:1": {}
  }
}
```

### Options

| Name | Description | Default Value |
|------|-------------|---------------|
| `version` | Version of Codex CLI to install | `latest` |

### Example with version specification

```json
{
  "features": {
    "ghcr.io/fumito-ito/devcontainer-features/codex-cli:1": {
      "version": "v1.0.0"
    }
  }
}
```

## What does this feature do?

- Installs Node.js (if not already present) as a prerequisite
- Installs the OpenAI Codex CLI via npm (`@openai/codex`)
- Makes the `codex` command available globally in your DevContainer
- Supports installation of specific versions or the latest release

## Prerequisites

This feature requires:
- Linux-based DevContainer (Ubuntu 20.04+, Debian 10+, or Alpine)
- Internet access to download packages
- OpenAI API key (set as environment variable)

## Post-installation

After installation, you need to set your OpenAI API key:

```bash
export OPENAI_API_KEY="your-api-key-here"
```

Then you can use the Codex CLI:

```bash
# Interactive mode
codex

# Run with prompt
codex "explain this codebase to me"

# Full auto mode
codex --full-auto "create a todo-list app"

# Show help
codex --help
```

## Features

- **Interactive mode**: Ask questions and get AI-generated responses
- **Command execution**: Run AI-generated commands in a sandboxed environment
- **Configurable approval**: Control whether commands require approval before execution
- **Security settings**: Sandboxed execution environment for safety

## Configuration

For detailed configuration options, refer to the [OpenAI Codex CLI documentation](https://github.com/openai/codex).

## Notes

- The feature automatically detects the package manager (apt, apk) and installs dependencies accordingly
- Node.js LTS is installed if not already present
- The CLI requires 4-8 GB RAM for optimal performance
- All commands are executed in a sandboxed environment for security