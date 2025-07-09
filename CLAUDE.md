# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains DevContainer features for setting up development environments. It includes two main features:

1. **claude-code-config** - Clones a GitHub repository into the `.claude` directory for Claude Code integration
2. **gemini-cli** - Installs the Google Gemini CLI tool for interacting with Gemini AI models

## Commands

### Testing
- `make test` - Run basic feature tests for gemini-cli
- `make test-all` - Run all tests including scenarios and global tests
- `make test-local` - Test locally with Ubuntu base image
- `make test-scenarios` - Run all defined scenarios
- `make test-ubuntu` / `make test-debian` / `make test-alpine` - Test with specific base images
- `make test-extended` - Run extended test suite including performance, security, and regression tests
- `make validate` - Validate feature configuration files
- `make clean` - Clean up Docker test artifacts

### Development
- `make setup` - Check prerequisites and validate configuration
- `make pre-commit` - Run pre-commit validation checks
- `make debug` - Run tests with verbose output
- `scripts/run-tests.sh` - Comprehensive test runner with various options (quick mode, specific tests, etc.)

### Test Scripts
- `scripts/run-tests.sh --quick` - Run quick tests only
- `scripts/run-tests.sh --verbose` - Run with verbose output
- `scripts/run-tests.sh --test default --test security` - Run specific test types

## Architecture

### DevContainer Features Structure
Each feature follows the standard DevContainer feature structure:
- `src/{feature-name}/devcontainer-feature.json` - Feature configuration with options and metadata
- `src/{feature-name}/install.sh` - Installation script executed during container build
- `src/{feature-name}/README.md` - Feature documentation
- `test/{feature-name}/` - Test scenarios and scripts

### Feature Implementations

#### claude-code-config Feature
- **Purpose**: Clones a GitHub repository into `.claude` directory for Claude Code settings
- **Options**: `repo` (owner/repo format), `branch` (default: main), `token` (for private repos)
- **Install Script**: `src/claude-code-config/install.sh` - Handles git installation, repository cloning, and directory setup

#### gemini-cli Feature  
- **Purpose**: Installs Google Gemini CLI tool for AI model interaction
- **Options**: `version` (default: latest)
- **Install Script**: `src/gemini-cli/install.sh` - Downloads and installs the appropriate binary for the architecture
- **Dependencies**: Uses nanolayer utilities and common-utils feature

### Test Architecture
The testing system uses the DevContainer CLI's testing framework:
- **Global scenarios**: `test/_global/scenarios.json` - Cross-feature test scenarios
- **Feature-specific tests**: Individual test scripts in `test/{feature-name}/`
- **Comprehensive test runner**: `scripts/run-tests.sh` with support for different test types and base images

### Key Files
- `Makefile` - Build automation with comprehensive test targets
- `scripts/run-tests.sh` - Advanced test runner with filtering and reporting
- `src/gemini-cli/library_scripts.sh` - Utility functions for the gemini-cli feature
- Test scenarios validate functionality across Ubuntu, Debian, and Alpine base images

## Development Notes

### Prerequisites
- DevContainer CLI (`npm install -g @devcontainers/cli`)
- Docker with daemon running
- Make (for using Makefile targets)

### Testing Strategy
The project uses a multi-layered testing approach:
1. Basic functionality tests
2. Cross-platform compatibility (Ubuntu, Debian, Alpine)
3. Version matrix testing
4. Security and performance validation
5. Edge case and error handling tests

### Feature Dependencies
- Both features depend on `ghcr.io/devcontainers/features/common-utils`
- gemini-cli uses nanolayer utilities for package management
- claude-code-config handles git installation internally if not available