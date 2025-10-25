# Python UV Pterodactyl Egg

A comprehensive Pterodactyl Egg for running Python applications using the `uv` package manager with Git repository integration and custom Docker images.

## 🚀 Quick Start

### Download the Egg File

**Option 1: Download from GitHub Releases (Recommended)**
1. Go to the [Releases page](https://github.com/PrestonHager/python-uv-pterodactyl-egg/releases)
2. Download the latest `python-uv-egg-github-actions.json` file
3. Import it into your Pterodactyl panel

**Option 2: Generate Locally**
```bash
# Clone the repository
git clone https://github.com/PrestonHager/python-uv-pterodactyl-egg.git
cd python-uv-pterodactyl-egg

# Generate the egg configuration
cd build
./build-images.sh --config-only

# The egg file will be generated as python-uv-egg-custom-images.json
```

### Install in Pterodactyl

1. Import the downloaded JSON file into your Pterodactyl panel
2. Create a new server using this egg
3. Configure the required environment variables
4. Start the server

## 📋 Features

- **Custom Docker Images**: Pre-built Alpine Linux images with Python 3.8-3.14 and UV package manager
- **Git Integration**: Automatic repository cloning and updating from GitHub/GitLab
- **Authentication Support**: Username and personal access token authentication  
- **uv Package Manager**: Fast Python package management and virtual environment creation
- **Flexible Startup**: Configurable startup commands and pre-startup scripts
- **Multi-Python Support**: Python versions 3.8 through 3.14
- **Security Scanning**: Automated vulnerability scanning with Trivy

## 🐳 Docker Images

The egg uses custom Docker images built with Alpine Linux for smaller, more secure containers:

- `ghcr.io/prestonhager/python-uv:3.8` - Python 3.8.x
- `ghcr.io/prestonhager/python-uv:3.9` - Python 3.9.x
- `ghcr.io/prestonhager/python-uv:3.10` - Python 3.10.x
- `ghcr.io/prestonhager/python-uv:3.11` - Python 3.11.x
- `ghcr.io/prestonhager/python-uv:3.12` - Python 3.12.x
- `ghcr.io/prestonhager/python-uv:3.13` - Python 3.13.x
- `ghcr.io/prestonhager/python-uv:3.14` - Python 3.14.x (Latest)

## ⚙️ Configuration

### Required Environment Variables

- `REPO_URL` - Git repository URL (GitHub/GitLab) - *Optional*
- `STARTUP_COMMAND` - Command to run your Python application (default: `uv run python main.py`)

### Optional Environment Variables

- `UV_PYTHON_VERSION` - Python version to use (default: `3.14`, supports 3.8-3.14)
- `ADDITIONAL_PACKAGES` - Additional Python packages to install (space-separated)
- `PULL_ON_START` - Pull latest changes from repository on startup (default: `1`)
- `GIT_USERNAME` - Git username for private repositories
- `GIT_TOKEN` - Git token/password for private repositories

### Example Startup Commands

- `uv run python main.py`
- `uv run uvicorn app.main:app --host 0.0.0.0 --port 8000`
- `uv run python -m myapp`
- `uv run gunicorn app.wsgi:application --bind 0.0.0.0:8000`

## 🏗️ Development

### Project Structure

```
├── build/                    # Build scripts and tools
│   ├── build-images.sh      # Main build script
│   └── test-images.sh       # Image testing script
├── templates/               # Configuration templates
│   └── python-uv-egg-template.json
├── Dockerfile               # Custom Docker image definition
├── entrypoint.sh           # Container entrypoint script
└── .github/workflows/      # GitHub Actions workflows
```

### Building Docker Images

```bash
# Build all Python versions
cd build
./build-images.sh

# Build specific versions
REGISTRY=myregistry.com ./build-images.sh

# Generate configuration only (no Docker builds)
./build-images.sh --config-only
```

### Testing Images

```bash
cd build
./test-images.sh
```

## 🔄 GitHub Actions

The project includes automated GitHub Actions workflows:

- **Build & Test**: Builds Docker images for all Python versions
- **Security Scan**: Scans images for vulnerabilities using Trivy
- **Release**: Creates GitHub releases with egg configuration artifacts

## 📚 Documentation

- `python-uv-egg-documentation.md` - Comprehensive documentation and usage guide
- `python-uv-egg-example.md` - Complete example repository structure and code

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source. Feel free to use, modify, and distribute.

## 👨‍💻 Author

Created by [Preston Hager](https://github.com/PrestonHager) for Pterodactyl panel deployments.

## 🔗 Links

- [GitHub Repository](https://github.com/PrestonHager/python-uv-pterodactyl-egg)
- [Releases](https://github.com/PrestonHager/python-uv-pterodactyl-egg/releases)
- [Issues](https://github.com/PrestonHager/python-uv-pterodactyl-egg/issues)