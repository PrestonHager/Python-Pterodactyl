# Example Python Application for Pterodactyl UV Egg

This is an example repository structure that demonstrates how to set up a Python application for use with the Pterodactyl UV Egg.

## Repository Structure

```
example-python-app/
├── pyproject.toml          # Project configuration and dependencies
├── requirements.txt        # Alternative dependency file
├── requirements-dev.txt    # Development dependencies
├── pre-start.sh           # Pre-startup script (optional)
├── main.py                # Main application file
├── app/
│   ├── __init__.py
│   ├── main.py
│   └── models.py
├── config/
│   └── settings.py
└── README.md
```

## pyproject.toml

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "example-python-app"
version = "0.1.0"
description = "Example Python Application for Pterodactyl UV Egg"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.100.0",
    "uvicorn[standard]>=0.20.0",
    "python-dotenv>=1.0.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
    "mypy>=1.0.0",
]

[project.scripts]
start = "app.main:main"
```

## requirements.txt

```text
# Core dependencies
fastapi>=0.100.0
uvicorn[standard]>=0.20.0
python-dotenv>=1.0.0
pydantic>=2.0.0

# Additional packages
requests>=2.28.0
aiofiles>=23.0.0
```

## requirements-dev.txt

```text
# Development dependencies
pytest>=7.0.0
pytest-asyncio>=0.21.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
pre-commit>=3.0.0
```

## pre-start.sh

```bash
#!/bin/bash
# Pre-startup script for example Python application

echo "Running pre-startup tasks for example app..."

# Create necessary directories
mkdir -p logs data cache uploads

# Set environment variables
export APP_ENV=${APP_ENV:-production}
export LOG_LEVEL=${LOG_LEVEL:-info}
export DEBUG=${DEBUG:-false}

# Create default configuration if it doesn't exist
if [ ! -f "config/settings.json" ]; then
    echo "Creating default configuration..."
    cat > config/settings.json << EOF
{
    "app_name": "Example Python App",
    "version": "0.1.0",
    "debug": false,
    "host": "0.0.0.0",
    "port": 8000
}
EOF
fi

# Download additional files if needed
# curl -o data/sample.json https://example.com/sample.json

echo "Pre-startup tasks completed successfully!"
```

## main.py

```python
#!/usr/bin/env python3
"""
Main entry point for the example Python application.
This file serves as a simple entry point that can be used
as a STARTUP_SCRIPT in the Pterodactyl panel.
"""

import sys
import os
from pathlib import Path

# Add the app directory to Python path
sys.path.insert(0, str(Path(__file__).parent / "app"))

if __name__ == "__main__":
    # Import and run the main application
    from app.main import main
    main()
```

## app/__init__.py

```python
"""
Example Python Application Package
"""

__version__ = "0.1.0"
__author__ = "Your Name"
__email__ = "your.email@example.com"
```

## app/main.py

```python
"""
Main application module for the example Python app.
"""

import os
import logging
from pathlib import Path
from fastapi import FastAPI
import uvicorn

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="Example Python App",
        description="An example Python application for Pterodactyl UV Egg",
        version="0.1.0"
    )
    
    @app.get("/")
    async def root():
        """Root endpoint."""
        return {
            "message": "Hello from Example Python App!",
            "version": "0.1.0",
            "environment": os.getenv("APP_ENV", "production")
        }
    
    @app.get("/health")
    async def health_check():
        """Health check endpoint."""
        return {"status": "healthy", "service": "example-python-app"}
    
    @app.get("/info")
    async def app_info():
        """Application information endpoint."""
        return {
            "app_name": "Example Python App",
            "version": "0.1.0",
            "python_version": os.sys.version,
            "working_directory": str(Path.cwd()),
            "environment_variables": {
                "APP_ENV": os.getenv("APP_ENV"),
                "LOG_LEVEL": os.getenv("LOG_LEVEL"),
                "DEBUG": os.getenv("DEBUG"),
            }
        }
    
    return app

def main():
    """Main function to run the application."""
    logger.info("Starting Example Python Application...")
    
    # Create the FastAPI app
    app = create_app()
    
    # Get configuration from environment variables
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    logger.info(f"Starting server on {host}:{port}")
    logger.info(f"Debug mode: {debug}")
    
    # Run the application
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info" if not debug else "debug",
        access_log=True
    )

if __name__ == "__main__":
    main()
```

## app/models.py

```python
"""
Data models for the example Python application.
"""

from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class HealthStatus(BaseModel):
    """Health status model."""
    status: str
    service: str
    timestamp: datetime
    version: str

class AppInfo(BaseModel):
    """Application information model."""
    app_name: str
    version: str
    python_version: str
    working_directory: str
    environment_variables: dict
```

## config/settings.py

```python
"""
Configuration settings for the example Python application.
"""

import os
import json
from pathlib import Path
from typing import Dict, Any

class Settings:
    """Application settings."""
    
    def __init__(self):
        self.app_name = os.getenv("APP_NAME", "Example Python App")
        self.version = os.getenv("APP_VERSION", "0.1.0")
        self.debug = os.getenv("DEBUG", "false").lower() == "true"
        self.host = os.getenv("HOST", "0.0.0.0")
        self.port = int(os.getenv("PORT", "8000"))
        self.log_level = os.getenv("LOG_LEVEL", "info")
        
        # Load additional settings from JSON file if it exists
        settings_file = Path("config/settings.json")
        if settings_file.exists():
            with open(settings_file, "r") as f:
                additional_settings = json.load(f)
                for key, value in additional_settings.items():
                    setattr(self, key, value)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert settings to dictionary."""
        return {
            "app_name": self.app_name,
            "version": self.version,
            "debug": self.debug,
            "host": self.host,
            "port": self.port,
            "log_level": self.log_level,
        }

# Global settings instance
settings = Settings()
```

## README.md

```markdown
# Example Python Application

This is an example Python application designed to work with the Pterodactyl UV Egg.

## Features

- FastAPI web framework
- Automatic dependency management with uv
- Health check endpoints
- Configurable through environment variables
- Pre-startup script support

## Pterodactyl Configuration

### Required Environment Variables

- `REPO_URL`: `https://github.com/yourusername/example-python-app.git`
- `STARTUP_SCRIPT`: `python main.py`

### Optional Environment Variables

- `GIT_USERNAME`: Your Git username
- `GIT_TOKEN`: Your Git personal access token
- `PULL_ON_START`: `true`
- `UV_PYTHON_VERSION`: `3.11`
- `UV_VENV_NAME`: `.venv`
- `ADDITIONAL_PACKAGES`: `requests aiofiles`

### Custom Environment Variables

- `APP_ENV`: `production` or `development`
- `LOG_LEVEL`: `info`, `debug`, `warning`, `error`
- `DEBUG`: `true` or `false`
- `HOST`: `0.0.0.0`
- `PORT`: `8000`

## Endpoints

- `GET /` - Root endpoint with welcome message
- `GET /health` - Health check endpoint
- `GET /info` - Application information endpoint

## Local Development

1. Clone the repository
2. Install uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`
3. Create virtual environment: `uv venv`
4. Activate virtual environment: `source .venv/bin/activate`
5. Install dependencies: `uv pip install -e .`
6. Run the application: `python main.py`

## Testing

```bash
# Install development dependencies
uv pip install -e ".[dev]"

# Run tests
pytest

# Format code
black .

# Lint code
flake8 .
```
```

## Usage Instructions

1. **Create a new repository** with the above structure
2. **Push to GitHub/GitLab**
3. **Import the Pterodactyl Egg** (`python-uv-egg.json`)
4. **Create a new server** using the egg
5. **Configure environment variables**:
   - `REPO_URL`: Your repository URL
   - `STARTUP_SCRIPT`: `python main.py`
   - Add Git credentials if needed
6. **Start the server**

The egg will automatically:
- Clone your repository
- Install uv package manager
- Create a Python virtual environment
- Install dependencies
- Run your application

## Customization

You can customize this example by:
- Modifying the FastAPI application in `app/main.py`
- Adding more dependencies to `pyproject.toml`
- Creating additional endpoints
- Adding database connections
- Implementing authentication
- Adding background tasks

This example provides a solid foundation for most Python web applications that can be easily deployed using the Pterodactyl UV Egg.
