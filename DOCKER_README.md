# Python UV Docker Images for Pterodactyl

This directory contains custom Docker images for Python applications with UV package manager, designed specifically for Pterodactyl game panel.

## Overview

The custom Docker images are based on the official [Pterodactyl yolks](https://raw.githubusercontent.com/pterodactyl/yolks/refs/heads/master/python/3.11/Dockerfile) but with the following enhancements:

- **Alpine Linux Base**: Uses `python:3.x-alpine` for smaller image size and better security
- **Shell Entrypoint**: Uses `/bin/ash` entrypoint instead of Python directly
- **UV Package Manager**: Pre-installed UV package manager for faster Python package management
- **Multiple Python Versions**: Support for Python 3.8 through 3.13
- **Pterodactyl Compatible**: Follows Pterodactyl container patterns and conventions

## Files

- `Dockerfile` - Multi-version Docker image definition
- `entrypoint.sh` - Custom entrypoint script based on Pterodactyl yolks
- `build-images.sh` - Automated build script for all Python versions
- `python-uv-egg-custom-images.json` - Generated egg configuration (created by build script)

## Quick Start

### 1. Build All Images

```bash
# Build all Python versions (3.8-3.13)
./build-images.sh

# Build and push to registry
./build-images.sh --push

# Use custom registry
./build-images.sh --registry myregistry.com --name my-python-uv
```

### 2. Build Single Image

```bash
# Build specific Python version
docker build --build-arg PYTHON_VERSION=3.11 --tag python-uv:3.11 .
```

### 3. Test Image

```bash
# Test Python and UV installation
docker run --rm python-uv:3.11 python --version
docker run --rm python-uv:3.11 uv --version

# Test entrypoint
docker run --rm -e STARTUP="echo 'Hello from Python with UV!'" python-uv:3.11
```

## Image Features

### Pre-installed Software
- Python (3.8, 3.9, 3.10, 3.11, 3.12, or 3.13)
- UV package manager
- Git
- curl
- ca-certificates
- Alpine Linux base system

### Container User
- Non-root user: `container`
- Home directory: `/home/container`
- Working directory: `/home/container`

### Environment Variables
- `TZ` - Timezone (defaults to UTC)
- `INTERNAL_IP` - Internal Docker IP
- `STARTUP` - Startup command (processed by entrypoint)

## Usage in Pterodactyl

### 1. Upload Custom Egg

Use the generated `python-uv-egg-custom-images.json` file in your Pterodactyl panel.

### 2. Configure Server Variables

- `REPO_URL` - Git repository URL
- `STARTUP_COMMAND` - Command to run your application
- `UV_PYTHON_VERSION` - Python version (3.8-3.13)
- `ADDITIONAL_PACKAGES` - Extra packages to install
- `PULL_ON_START` - Pull latest changes on startup
- `GIT_USERNAME` / `GIT_TOKEN` - Private repository credentials

### 3. Example Startup Commands

```bash
# Run a Python script
uv run python main.py

# Run with specific Python version
uv run --python 3.11 python app.py

# Run a module
uv run python -m myapp

# Run with arguments
uv run python main.py --port 8080 --debug
```

## Build Script Options

```bash
./build-images.sh [OPTIONS]

OPTIONS:
    -r, --registry REGISTRY     Docker registry (default: ghcr.io/prestonh)
    -n, --name NAME            Image name (default: python-uv)
    -t, --tag-prefix PREFIX    Tag prefix (default: empty)
    -p, --push                 Push images to registry
    -h, --help                 Show help message

ENVIRONMENT VARIABLES:
    REGISTRY                   Docker registry
    IMAGE_NAME                 Image name
    TAG_PREFIX                 Tag prefix
    PUSH_IMAGES                Set to 'true' to push images
```

## Registry Configuration

### GitHub Container Registry (Default)

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Build and push
./build-images.sh --push
```

### Docker Hub

```bash
# Login to Docker Hub
docker login

# Build and push
REGISTRY=docker.io/USERNAME ./build-images.sh --push
```

### Private Registry

```bash
# Build and push to private registry
REGISTRY=myregistry.com ./build-images.sh --push
```

## Differences from Standard Python Images

| Feature | Standard Python | Custom Python UV |
|---------|----------------|------------------|
| Base Image | python:3.x-slim | python:3.x-alpine |
| Entrypoint | `python` | `/bin/ash /entrypoint.sh` |
| Package Manager | pip | UV (pre-installed) |
| User | root | container (non-root) |
| Working Directory | `/` | `/home/container` |
| Startup Processing | Direct execution | Variable substitution |
| Pterodactyl Integration | Manual | Built-in |
| Package Installation | apt | apk |

## Troubleshooting

### Build Issues

```bash
# Check Docker is running
docker info

# Clean up failed builds
docker system prune -f

# Build with verbose output
docker build --progress=plain --build-arg PYTHON_VERSION=3.11 .
```

### Runtime Issues

```bash
# Check container logs
docker logs <container_id>

# Debug entrypoint
docker run --rm -it python-uv:3.11 /bin/bash

# Test startup command
docker run --rm -e STARTUP="echo 'test'" python-uv:3.11
```

### UV Issues

```bash
# Check UV installation
docker run --rm python-uv:3.11 uv --version

# Test UV commands
docker run --rm python-uv:3.11 uv init --help
```

## Contributing

1. Fork the repository
2. Make your changes
3. Test with `./build-images.sh`
4. Submit a pull request

## License

Based on Pterodactyl yolks (MIT License)
Custom modifications by prestonh@prestonhager.com
