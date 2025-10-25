#!/usr/bin/env bash
#
# Test script for Python UV Docker images
# Tests basic functionality of the custom Docker images
#

set -e

# Configuration
REGISTRY="${REGISTRY:-ghcr.io/prestonh}"
IMAGE_NAME="${IMAGE_NAME:-python-uv}"
TAG_PREFIX="${TAG_PREFIX:-}"

# Test Python versions
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

# Test a specific image
test_image() {
    local python_version=$1
    local image_tag="${REGISTRY}/${IMAGE_NAME}:${TAG_PREFIX}${python_version}"
    
    log_info "Testing image: ${image_tag}"
    
    # Test 1: Python version
    log_info "  Testing Python version..."
    local python_output=$(docker run --rm "${image_tag}" python --version 2>&1)
    if [[ $python_output == *"Python ${python_version}"* ]]; then
        log_success "  ✓ Python version correct: ${python_output}"
    else
        log_error "  ✗ Python version incorrect: ${python_output}"
        return 1
    fi
    
    # Test 2: UV installation
    log_info "  Testing UV installation..."
    local uv_output=$(docker run --rm "${image_tag}" uv --version 2>&1)
    if [[ $uv_output == *"uv"* ]]; then
        log_success "  ✓ UV installed: ${uv_output}"
    else
        log_error "  ✗ UV not found: ${uv_output}"
        return 1
    fi
    
    # Test 3: Entrypoint functionality
    log_info "  Testing entrypoint..."
    local startup_output=$(docker run --rm -e STARTUP="echo 'Hello from Python ${python_version} with UV!'" "${image_tag}" 2>&1)
    if [[ $startup_output == *"Hello from Python ${python_version} with UV!"* ]]; then
        log_success "  ✓ Entrypoint working correctly"
    else
        log_error "  ✗ Entrypoint failed: ${startup_output}"
        return 1
    fi
    
    # Test 4: Working directory
    log_info "  Testing working directory..."
    local wd_output=$(docker run --rm -e STARTUP="pwd" "${image_tag}" 2>&1)
    if [[ $wd_output == *"/home/container"* ]]; then
        log_success "  ✓ Working directory correct: ${wd_output}"
    else
        log_error "  ✗ Working directory incorrect: ${wd_output}"
        return 1
    fi
    
    # Test 5: User permissions
    log_info "  Testing user permissions..."
    local user_output=$(docker run --rm -e STARTUP="whoami" "${image_tag}" 2>&1)
    if [[ $user_output == *"container"* ]]; then
        log_success "  ✓ User correct: ${user_output}"
    else
        log_error "  ✗ User incorrect: ${user_output}"
        return 1
    fi
    
    # Test 6: UV project initialization
    log_info "  Testing UV project initialization..."
    local uv_init_output=$(docker run --rm -e STARTUP="uv init --help" "${image_tag}" 2>&1)
    if [[ $uv_init_output == *"Usage: uv init"* ]] || [[ $uv_init_output == *"Create a new Python project"* ]]; then
        log_success "  ✓ UV init command available"
    else
        log_error "  ✗ UV init command failed: ${uv_init_output}"
        return 1
    fi
    
    # Test 7: Alpine package manager
    log_info "  Testing Alpine package manager..."
    local apk_output=$(docker run --rm -e STARTUP="apk --version" "${image_tag}" 2>&1)
    if [[ $apk_output == *"apk-tools"* ]]; then
        log_success "  ✓ Alpine package manager available: ${apk_output}"
    else
        log_error "  ✗ Alpine package manager not found: ${apk_output}"
        return 1
    fi
    
    log_success "All tests passed for Python ${python_version}"
    return 0
}

# Test all images
test_all_images() {
    local failed_tests=()
    local successful_tests=()
    
    log_info "Starting comprehensive image testing..."
    log_info "Testing Python versions: ${PYTHON_VERSIONS[*]}"
    
    for version in "${PYTHON_VERSIONS[@]}"; do
        echo
        log_info "Testing Python ${version}..."
        
        if test_image "${version}"; then
            successful_tests+=("${version}")
        else
            failed_tests+=("${version}")
        fi
    done
    
    echo
    log_info "Test Summary:"
    log_success "Successful tests: ${successful_tests[*]}"
    
    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        log_error "Failed tests: ${failed_tests[*]}"
        return 1
    else
        log_success "All tests passed!"
        return 0
    fi
}

# Quick test (single version)
quick_test() {
    local version=${1:-3.11}
    log_info "Running quick test for Python ${version}..."
    test_image "${version}"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND]

Test Python UV Docker images

COMMANDS:
    all                     Test all Python versions (default)
    quick [VERSION]         Quick test for specific version (default: 3.11)
    help                    Show this help message

OPTIONS:
    -r, --registry REGISTRY     Docker registry (default: ghcr.io/prestonh)
    -n, --name NAME            Image name (default: python-uv)
    -t, --tag-prefix PREFIX    Tag prefix (default: empty)

ENVIRONMENT VARIABLES:
    REGISTRY                   Docker registry
    IMAGE_NAME                 Image name
    TAG_PREFIX                 Tag prefix

EXAMPLES:
    $0                                    # Test all versions
    $0 quick 3.11                        # Quick test Python 3.11
    $0 --registry myregistry.com          # Test with custom registry
    REGISTRY=myregistry.com $0           # Test using environment variable

EOF
}

# Parse command line arguments
COMMAND="all"
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
        all)
            COMMAND="all"
            shift
            ;;
        quick)
            COMMAND="quick"
            VERSION="$2"
            shift 2
            ;;
        help|--help|-h)
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

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not in PATH"
    exit 1
fi

if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running or not accessible"
    exit 1
fi

# Execute command
case $COMMAND in
    all)
        test_all_images
        ;;
    quick)
        quick_test "$VERSION"
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac
