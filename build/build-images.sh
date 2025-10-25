#!/usr/bin/env bash
#
# Build script for Python UV Docker images
# Generates Docker images for Python versions 3.8 through 3.14
#

set -e

# Set Docker socket for rootless Docker
export DOCKER_HOST="unix:///run/user/1000/docker.sock"

# Configuration
REGISTRY="${REGISTRY:-ghcr.io/prestonhager}"
IMAGE_NAME="${IMAGE_NAME:-python-uv}"
TAG_PREFIX="${TAG_PREFIX:-}"
CONFIG_ONLY="${CONFIG_ONLY:-false}"

# Python versions to build (latest first)
PYTHON_VERSIONS=(3.14 3.13 3.12 3.11 3.10 3.9 3.8)

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
    
    # Set Docker socket for rootless Docker
    export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
    
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
    
    # Use Python script to generate properly formatted JSON
    python3 generate-egg-config.py
    
    log_success "Generated egg configuration: ${config_file}"
}

# Main execution
main() {
    log_info "Starting Python UV Docker image build process"
    
    if [[ "${CONFIG_ONLY}" == "true" ]]; then
        log_info "Configuration-only mode: Generating egg configuration file"
        generate_egg_config
        log_success "Egg configuration generated: python-uv-egg-custom-images.json"
        return 0
    fi
    
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
    -c, --config-only          Generate egg configuration file only (skip building images)
    -h, --help                 Show this help message

ENVIRONMENT VARIABLES:
    REGISTRY                   Docker registry
    IMAGE_NAME                 Image name
    TAG_PREFIX                 Tag prefix
    PUSH_IMAGES                Set to 'true' to push images
    CONFIG_ONLY                Set to 'true' to generate config only

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
        -c|--config-only)
            CONFIG_ONLY="true"
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
