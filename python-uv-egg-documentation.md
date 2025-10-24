# Python UV Environment - Pterodactyl Egg

A comprehensive Pterodactyl Egg for running Python applications using the `uv` package manager with Git repository integration.

## Features

- **Git Integration**: Automatic repository cloning and updating from GitHub/GitLab
- **Authentication Support**: Username and personal access token authentication
- **uv Package Manager**: Fast Python package management and virtual environment creation
- **Flexible Startup**: Configurable startup commands and pre-startup scripts
- **Dependency Management**: Support for `pyproject.toml`, `requirements.txt`, and `requirements-dev.txt`
- **Environment Variables**: Comprehensive configuration through Pterodactyl panel
- **Logging**: Detailed logging with timestamps and color coding

## Installation

1. Import the `python-uv-egg.json` file into your Pterodactyl panel
2. Create a new server using this egg
3. Configure the required environment variables
4. Start the server

## Required Environment Variables

### `REPO_URL` (Required)
- **Description**: Git repository URL (GitHub/GitLab)
- **Example**: `https://github.com/username/repository.git`
- **Rules**: Required, string, max 255 characters

### `STARTUP_SCRIPT` (Required)
- **Description**: Command to run your Python application
- **Examples**:
  - `python main.py`
  - `uvicorn app.main:app --host 0.0.0.0 --port 8000`
  - `python -m myapp`
  - `gunicorn app.wsgi:application --bind 0.0.0.0:8000`
- **Rules**: Required, string, max 500 characters

## Optional Environment Variables

### `GIT_USERNAME` (Optional)
- **Description**: Git username for repository authentication
- **Example**: `myusername`
- **Rules**: Optional, string, max 100 characters

### `GIT_TOKEN` (Optional)
- **Description**: Git personal access token for authentication
- **Example**: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
- **Rules**: Optional, string, max 255 characters

### `PULL_ON_START` (Optional)
- **Description**: Whether to pull latest changes from repository on startup
- **Default**: `true`
- **Options**: `true`, `false`
- **Rules**: Required, boolean

### `UV_PYTHON_VERSION` (Optional)
- **Description**: Python version to use with uv
- **Default**: `3.11`
- **Options**: `3.8`, `3.9`, `3.10`, `3.11`, `3.12`, `3.13`
- **Rules**: Required, string, must be one of the allowed values

### `UV_VENV_NAME` (Optional)
- **Description**: Virtual environment directory name
- **Default**: `.venv`
- **Rules**: Required, string, max 50 characters

### `ADDITIONAL_PACKAGES` (Optional)
- **Description**: Additional Python packages to install (space-separated)
- **Example**: `requests fastapi uvicorn`
- **Rules**: Optional, string, max 500 characters

## Repository Structure

Your Git repository should contain one or more of the following files:

### Dependency Files (in order of preference)
1. `pyproject.toml` - Modern Python project configuration
2. `requirements.txt` - Standard Python requirements
3. `requirements-dev.txt` - Development requirements

### Optional Files
- `pre-start.sh` - Custom pre-startup script (will be executed before the main application)
- `README.md` - Project documentation

## Example Repository Structure

```
my-python-app/
├── pyproject.toml          # Project configuration and dependencies
├── requirements.txt        # Alternative dependency file
├── requirements-dev.txt    # Development dependencies
├── pre-start.sh           # Pre-startup script (optional)
├── main.py                # Main application file
├── app/
│   ├── __init__.py
│   ├── main.py
│   └── models.py
└── README.md
```

## Example pyproject.toml

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-python-app"
version = "0.1.0"
description = "My Python Application"
requires-python = ">=3.11"
dependencies = [
    "requests>=2.28.0",
    "fastapi>=0.100.0",
    "uvicorn[standard]>=0.20.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
]

[project.scripts]
start = "myapp.main:main"
```

## Example requirements.txt

```text
# Python dependencies
requests>=2.28.0
fastapi>=0.100.0
uvicorn[standard]>=0.20.0
python-dotenv>=1.0.0
```

## Example pre-start.sh

```bash
#!/bin/bash
# Pre-startup script - runs before the main application

echo "Running pre-startup tasks..."

# Create necessary directories
mkdir -p logs data cache

# Set environment variables
export DEBUG=true
export LOG_LEVEL=info

# Download additional files
# curl -o config.json https://example.com/config.json

echo "Pre-startup tasks completed"
```

## Startup Process

1. **System Dependencies**: Installs Git, curl, build tools, and Python development headers
2. **uv Installation**: Downloads and installs the uv package manager
3. **Git Setup**: Configures Git credentials if provided
4. **Repository Management**: Clones or updates the repository
5. **Virtual Environment**: Creates a Python virtual environment using uv
6. **Dependency Installation**: Installs packages from dependency files
7. **Additional Packages**: Installs any additional specified packages
8. **Pre-startup**: Runs custom pre-startup script if present
9. **Application Start**: Executes the main startup command

## Common Startup Commands

### FastAPI Application
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Django Application
```bash
python manage.py runserver 0.0.0.0:8000
```

### Flask Application
```bash
python app.py
```

### Custom Module
```bash
python -m myapp
```

### Gunicorn (Production)
```bash
gunicorn app.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

## Git Authentication Setup

### GitHub Personal Access Token
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate a new token with appropriate permissions (repo, read:org, etc.)
3. Use your GitHub username and the token as `GIT_USERNAME` and `GIT_TOKEN`

### GitLab Personal Access Token
1. Go to GitLab Settings → Access Tokens
2. Create a new token with appropriate scopes (read_repository, etc.)
3. Use your GitLab username and the token as `GIT_USERNAME` and `GIT_TOKEN`

## Troubleshooting

### Common Issues

1. **Repository Access Denied**
   - Verify `GIT_USERNAME` and `GIT_TOKEN` are correct
   - Ensure the token has appropriate permissions
   - Check if the repository URL is correct

2. **Dependencies Not Installing**
   - Verify dependency files exist in the repository
   - Check if package names are correct
   - Ensure Python version compatibility

3. **Startup Script Fails**
   - Verify the `STARTUP_SCRIPT` command is correct
   - Check if the main application file exists
   - Ensure all required dependencies are installed

4. **Virtual Environment Issues**
   - Check if `UV_PYTHON_VERSION` is supported
   - Verify `UV_VENV_NAME` doesn't conflict with existing directories
   - Ensure sufficient disk space

### Logs

The startup script provides detailed logging with timestamps and color coding:
- **Green**: Success messages
- **Yellow**: Warnings
- **Red**: Errors

Check the server console output for detailed information about the startup process.

## Security Considerations

- Store sensitive tokens securely in Pterodactyl environment variables
- Use minimal required permissions for Git tokens
- Regularly rotate access tokens
- Consider using SSH keys for production deployments

## Performance Tips

- Use `pyproject.toml` for better dependency resolution
- Pin dependency versions for reproducible builds
- Use `requirements-dev.txt` for development-only dependencies
- Consider using Docker layer caching for faster builds

## Support

For issues or questions:
1. Check the server console logs
2. Verify all environment variables are set correctly
3. Test the repository and startup command locally
4. Check the Pterodactyl panel logs for additional information
