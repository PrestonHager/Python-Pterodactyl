#!/usr/bin/env bash
#
# Build script for Python UV Docker images
# Generates Docker images for Python versions 3.8 through 3.13
#

set -e

# Configuration
REGISTRY="${REGISTRY:-ghcr.io/PrestonHager}"
IMAGE_NAME="${IMAGE_NAME:-python-uv}"
TAG_PREFIX="${TAG_PREFIX:-}"

# Python versions to build
PYTHON_VERSIONS=(3.8 3.9 3.10 3.11 3.12 3.13)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running or not accessible"
        exit 1
    fi
    
    log_info "Docker is available and running"
}

# Build Docker image for a specific Python version
build_image() {
    local python_version=$1
    local image_tag="${REGISTRY}/${IMAGE_NAME}:${TAG_PREFIX}${python_version}"
    
    log_info "Building image for Python ${python_version}..."
    log_info "Image tag: ${image_tag}"
    
    # Build the image
    if docker build \
        --build-arg PYTHON_VERSION=${python_version} \
        --tag "${image_tag}" \
        --file Dockerfile \
        .; then
        log_success "Successfully built ${image_tag}"
        return 0
    else
        log_error "Failed to build ${image_tag}"
        return 1
    fi
}

# Test the built image
test_image() {
    local python_version=$1
    local image_tag="${REGISTRY}/${IMAGE_NAME}:${TAG_PREFIX}${python_version}"
    
    log_info "Testing image ${image_tag}..."
    
    # Test Python version
    local python_test=$(docker run --rm "${image_tag}" python --version 2>&1)
    if [[ $python_test == *"Python ${python_version}"* ]]; then
        log_success "Python version test passed: ${python_test}"
    else
        log_error "Python version test failed: ${python_test}"
        return 1
    fi
    
    # Test uv installation
    local uv_test=$(docker run --rm "${image_tag}" uv --version 2>&1)
    if [[ $uv_test == *"uv"* ]]; then
        log_success "UV installation test passed: ${uv_test}"
    else
        log_error "UV installation test failed: ${uv_test}"
        return 1
    fi
    
    # Test entrypoint
    local startup_test=$(docker run --rm -e STARTUP="echo 'Hello from Python ${python_version} with UV!'" "${image_tag}" 2>&1)
    if [[ $startup_test == *"Hello from Python ${python_version} with UV!"* ]]; then
        log_success "Entrypoint test passed"
    else
        log_error "Entrypoint test failed: ${startup_test}"
        return 1
    fi
    
    return 0
}

# Push image to registry (optional)
push_image() {
    local python_version=$1
    local image_tag="${REGISTRY}/${IMAGE_NAME}:${TAG_PREFIX}${python_version}"
    
    if [[ "${PUSH_IMAGES}" == "true" ]]; then
        log_info "Pushing ${image_tag} to registry..."
        if docker push "${image_tag}"; then
            log_success "Successfully pushed ${image_tag}"
        else
            log_error "Failed to push ${image_tag}"
            return 1
        fi
    else
        log_info "Skipping push (set PUSH_IMAGES=true to enable)"
    fi
}

# Generate egg configuration
generate_egg_config() {
    local config_file="python-uv-egg-custom-images.json"
    
    log_info "Generating egg configuration with custom images..."
    
    cat > "${config_file}" << EOF
{
  "_comment": "Python UV Egg with Custom Docker Images",
  "meta": {
    "version": "1.0.0",
    "update_url": "https://github.com/prestonh/python-uv-pterodactyl-egg"
  },
  "exported_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "name": "Python UV (Custom Images)",
  "description": "Python application server with UV package manager using custom Docker images",
  "author": "prestonh@prestonhager.com",
  "docker_images": {
EOF

    for version in "${PYTHON_VERSIONS[@]}"; do
        local image_tag="${REGISTRY}/${IMAGE_NAME}:${TAG_PREFIX}${version}"
        echo "    \"python-uv-${version}\": \"${image_tag}\"," >> "${config_file}"
    done
    
    # Remove the last comma
    sed -i '$ s/,$//' "${config_file}"
    
    cat >> "${config_file}" << EOF
  },
  "file_denylist": [],
  "startup": "if [[ \${PULL_ON_START} ]]; then git pull; fi; if [[ ! -z \"\${ADDITIONAL_PACKAGES}\" ]]; then uv add \${ADDITIONAL_PACKAGES}; fi; \${STARTUP_COMMAND}",
  "config": {
    "files": "{}",
    "startup": "{\n    \"done\": \")! For help, type \",\n    \"userInteraction\": [\n        \"Go to eula.txt for more info.\"\n    ]\n}",
    "logs": "{}",
    "stop": "^C"
  },
  "scripts": {
    "installation": {
      "script": "#!/bin/ash\n# Python UV Installation Script\n#\n# Server Files: /mnt/server\napk update\napk add --no-cache curl git\nmkdir -p /mnt/server\ncd /mnt/server\n\n# Clone repository if REPO_URL is provided\nif [[ ! -z \"\${REPO_URL}\" ]]; then\n    echo \"Cloning repository from \${REPO_URL}...\"\n    \n    # Handle authentication if credentials are provided\n    if [[ ! -z \"\${GIT_USERNAME}\" ]] && [[ ! -z \"\${GIT_TOKEN}\" ]]; then\n        # Extract domain and path from URL\n        REPO_DOMAIN=\$(echo \${REPO_URL} | sed -E 's|https?://([^/]+).*|\\1|')\n        REPO_PATH=\$(echo \${REPO_URL} | sed -E 's|https?://[^/]+/(.*)|\\1|')\n        AUTH_URL=\"https://\${GIT_USERNAME}:\${GIT_TOKEN}@\${REPO_DOMAIN}/\${REPO_PATH}\"\n        git clone \${AUTH_URL} .\n    else\n        git clone \${REPO_URL} .\n    fi\n    \n    echo \"Repository cloned successfully!\"\nelse\n    echo \"No repository URL provided. Creating empty project structure...\"\n    \n    # Create a basic main.py if it doesn't exist\n    if [[ ! -f main.py ]]; then\n        cat > main.py << 'EOF'\n#!/usr/bin/env python3\nprint(\"Hello from Python UV Environment!\")\nprint(\"Please configure your application in this file.\")\nEOF\n        chmod +x main.py\n    fi\nfi\n\n# Initialize uv project if pyproject.toml doesn't exist\nif [[ ! -f pyproject.toml ]]; then\n    echo \"Initializing uv project...\"\n    uv init --python \${UV_PYTHON_VERSION:-3.11} --name python-app\nfi\n\n# Install additional packages if specified\nif [[ ! -z \"\${ADDITIONAL_PACKAGES}\" ]]; then\n    echo \"Installing additional packages: \${ADDITIONAL_PACKAGES}\"\n    uv add \${ADDITIONAL_PACKAGES}\nfi\n\necho \"Python UV Environment installation completed!\"\necho \"Repository location: /mnt/server\"\necho \"Available commands:\"\necho \"  - uv run python main.py\"\necho \"  - uv add <package-name>\"\necho \"  - uv sync\"\n",
      "container": "ghcr.io/pterodactyl/installers:alpine",
      "entrypoint": "ash"
    }
  },
  "variables": [
    {
      "name": "REPO_URL",
      "description": "Git repository URL (GitHub/GitLab)",
      "env_variable": "REPO_URL",
      "default_value": "",
      "user_viewable": true,
      "user_editable": true,
      "rules": "required|string|max:255",
      "field_type": "text"
    },
    {
      "name": "STARTUP_COMMAND",
      "description": "Command to run your Python application",
      "env_variable": "STARTUP_COMMAND",
      "default_value": "uv run python main.py",
      "user_viewable": true,
      "user_editable": true,
      "rules": "required|string|max:255",
      "field_type": "text"
    },
    {
      "name": "UV_PYTHON_VERSION",
      "description": "Python version to use (default: 3.11, supports 3.8-3.13)",
      "env_variable": "UV_PYTHON_VERSION",
      "default_value": "3.11",
      "user_viewable": true,
      "user_editable": true,
      "rules": "required|string|in:3.8,3.9,3.10,3.11,3.12,3.13",
      "field_type": "text"
    },
    {
      "name": "ADDITIONAL_PACKAGES",
      "description": "Additional Python packages to install (space-separated)",
      "env_variable": "ADDITIONAL_PACKAGES",
      "default_value": "",
      "user_viewable": true,
      "user_editable": true,
      "rules": "nullable|string|max:255",
      "field_type": "text"
    },
    {
      "name": "PULL_ON_START",
      "description": "Pull latest changes from repository on startup",
      "env_variable": "PULL_ON_START",
      "default_value": "1",
      "user_viewable": true,
      "user_editable": true,
      "rules": "required|boolean",
      "field_type": "text"
    },
    {
      "name": "GIT_USERNAME",
      "description": "Git username for private repositories",
      "env_variable": "GIT_USERNAME",
      "default_value": "",
      "user_viewable": true,
      "user_editable": true,
      "rules": "nullable|string|max:255",
      "field_type": "text"
    },
    {
      "name": "GIT_TOKEN",
      "description": "Git token/password for private repositories",
      "env_variable": "GIT_TOKEN",
      "default_value": "",
      "user_viewable": true,
      "user_editable": true,
      "rules": "nullable|string|max:255",
      "field_type": "text"
    }
  ],
  "features": null
}
EOF

    log_success "Generated egg configuration: ${config_file}"
}

# Main execution
main() {
    log_info "Starting Python UV Docker image build process"
    log_info "Building images for Python versions: ${PYTHON_VERSIONS[*]}"
    
    # Check prerequisites
    check_docker
    
    # Build and test each image
    local failed_builds=()
    local successful_builds=()
    
    for version in "${PYTHON_VERSIONS[@]}"; do
        log_info "Processing Python ${version}..."
        
        if build_image "${version}"; then
            if test_image "${version}"; then
                push_image "${version}"
                successful_builds+=("${version}")
            else
                failed_builds+=("${version}")
            fi
        else
            failed_builds+=("${version}")
        fi
        
        echo # Add spacing between versions
    done
    
    # Generate egg configuration
    generate_egg_config
    
    # Summary
    log_info "Build process completed!"
    log_success "Successfully built: ${successful_builds[*]}"
    
    if [[ ${#failed_builds[@]} -gt 0 ]]; then
        log_error "Failed builds: ${failed_builds[*]}"
        exit 1
    else
        log_success "All builds completed successfully!"
    fi
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build custom Python UV Docker images for Pterodactyl

OPTIONS:
    -r, --registry REGISTRY     Docker registry (default: ghcr.io/prestonh)
    -n, --name NAME            Image name (default: python-uv)
    -t, --tag-prefix PREFIX    Tag prefix (default: empty)
    -p, --push                 Push images to registry
    -h, --help                 Show this help message

ENVIRONMENT VARIABLES:
    REGISTRY                   Docker registry
    IMAGE_NAME                 Image name
    TAG_PREFIX                 Tag prefix
    PUSH_IMAGES                Set to 'true' to push images

EXAMPLES:
    $0                                    # Build with defaults
    $0 --registry myregistry.com         # Use custom registry
    $0 --name my-python-uv --push        # Custom name and push
    PUSH_IMAGES=true $0                  # Push using environment variable

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag-prefix)
            TAG_PREFIX="$2"
            shift 2
            ;;
        -p|--push)
            PUSH_IMAGES="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run main function
main
