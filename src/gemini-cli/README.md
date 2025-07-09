# Unofficial Gemini CLI DevContainer Feature

This DevContainer feature installs the [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) tool for interacting with Google's Gemini AI models.

## Usage

```json
{
  "features": {
    "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {}
  }
}
```

### Options

| Name | Description | Default Value |
|------|-------------|---------------|
| `version` | Version of Gemini CLI to install | `latest` |

### Example with version specification

```json
{
  "features": {
    "ghcr.io/fumito-ito/devcontainer-features/gemini-cli:1": {
      "version": "v0.1.0"
    }
  }
}
```

## What does this feature do?

- Downloads and installs the Gemini CLI binary for Linux x86_64 or arm64 architectures
- Makes the `gemini` command available globally in your DevContainer
- Supports installation of specific versions or the latest release

## Prerequisites

This feature requires:
- Linux-based DevContainer
- Internet access to download the binary from GitHub releases

## Post-installation

After installation, you can use the Gemini CLI by running:

```bash
gemini --help
```

To configure the CLI with your API key, follow the instructions in the [Gemini CLI documentation](https://github.com/google-gemini/gemini-cli).

## Notes

- The feature automatically detects the system architecture (x86_64 or arm64)
- If `version` is set to "latest", it will fetch the most recent release from GitHub
- The binary is installed to `/usr/local/bin/gemini` and made executable for all users