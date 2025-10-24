# Python UV Pterodactyl Egg

A comprehensive Pterodactyl Egg for running Python applications using the `uv` package manager with Git repository integration.

## Overview

This egg provides a complete solution for deploying Python applications in Pterodactyl with:

- **Git Integration**: Automatic repository cloning and updating from GitHub/GitLab
- **Authentication Support**: Username and personal access token authentication  
- **uv Package Manager**: Fast Python package management and virtual environment creation
- **Flexible Startup**: Configurable startup commands and pre-startup scripts
- **Dependency Management**: Support for `pyproject.toml`, `requirements.txt`, and `requirements-dev.txt`
- **Environment Variables**: Comprehensive configuration through Pterodactyl panel
- **Logging**: Detailed logging with timestamps and color coding

## Files

- `python-uv-egg.json` - The main Pterodactyl Egg configuration file
- `python-uv-egg-documentation.md` - Comprehensive documentation and usage guide
- `python-uv-egg-example.md` - Complete example repository structure and code

## Quick Start

1. Import the `python-uv-egg.json` file into your Pterodactyl panel
2. Create a new server using this egg
3. Configure the required environment variables:
   - `REPO_URL`: Your Git repository URL
   - `STARTUP_SCRIPT`: Command to run your application
4. Add Git credentials if needed
5. Start the server

## Required Environment Variables

- `REPO_URL` - Git repository URL (GitHub/GitLab)
- `STARTUP_SCRIPT` - Command to run your Python application

## Optional Environment Variables

- `GIT_USERNAME` - Git username for authentication
- `GIT_TOKEN` - Git personal access token
- `PULL_ON_START` - Whether to pull latest changes on startup (default: true)
- `UV_PYTHON_VERSION` - Python version to use (default: 3.11)
- `UV_VENV_NAME` - Virtual environment name (default: .venv)
- `ADDITIONAL_PACKAGES` - Additional packages to install (space-separated)

## Example Startup Commands

- `python main.py`
- `uvicorn app.main:app --host 0.0.0.0 --port 8000`
- `python -m myapp`
- `gunicorn app.wsgi:application --bind 0.0.0.0:8000`

## Documentation

For detailed documentation, see `python-uv-egg-documentation.md`.

For a complete example, see `python-uv-egg-example.md`.

## License

This project is open source. Feel free to use, modify, and distribute.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Author

Created by prestonh for Pterodactyl panel deployments.
