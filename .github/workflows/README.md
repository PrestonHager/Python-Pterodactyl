# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated building, testing, and releasing of Python UV Docker images for Pterodactyl.

## 📋 Workflows Overview

### 1. **Docker Build, Test, and Release** (`docker-build-test-release.yml`)
**Triggers:** Push to main/feature branches, Pull requests, Manual dispatch

**Features:**
- 🐳 **Multi-platform builds** (linux/amd64, linux/arm64)
- 🧪 **Comprehensive testing** for all Python versions (3.8-3.13)
- 🔒 **Security scanning** with Trivy
- 📦 **Automatic releases** with egg configuration
- 🏷️ **Smart tagging** (version-specific and latest)

**Jobs:**
- `build-and-test`: Builds and tests all Python versions
- `security-scan`: Scans images for vulnerabilities
- `release`: Creates GitHub releases with artifacts

### 2. **Branch Naming Convention Check** (`branch-naming-check.yml`)
**Triggers:** Push to non-main branches, Pull requests

**Features:**
- ✅ **Enforces naming conventions** from [Medium article](https://medium.com/@abhay.pixolo/naming-conventions-for-git-branches-a-cheatsheet-8549feca2534)
- 💬 **Automatic PR comments** for violations
- 🚫 **Blocks merges** for non-compliant branches

**Valid Patterns:**
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `hotfix/description` - Critical fixes
- `release/version` - Release preparation
- `chore/description` - Maintenance
- `docs/description` - Documentation
- `test/description` - Testing
- `refactor/description` - Code refactoring

### 3. **Security and Dependency Updates** (`security-dependency-update.yml`)
**Triggers:** Weekly schedule (Mondays), Manual dispatch

**Features:**
- 🔍 **Weekly security scans** of codebase
- 📊 **Dependency update checks** for Python and UV
- 📝 **Automated issue creation** for maintenance tasks
- 🛡️ **Vulnerability monitoring**

### 4. **Test Build Scripts** (`test-build-scripts.yml`)
**Triggers:** Push to feature branches, Pull requests, Manual dispatch

**Features:**
- ✅ **Script syntax validation**
- 🐳 **Dockerfile validation**
- 📄 **JSON file validation**
- 🧪 **Single image build testing**
- 🧹 **Automatic cleanup**

## 🚀 Usage

### Manual Workflow Dispatch

You can manually trigger workflows with custom parameters:

```bash
# Build specific Python versions
gh workflow run docker-build-test-release.yml \
  -f python_versions="3.11,3.12" \
  -f push_images=true

# Run security scan
gh workflow run security-dependency-update.yml

# Test build scripts
gh workflow run test-build-scripts.yml
```

### Branch Naming Examples

**✅ Good:**
```bash
feature/add-github-actions
bugfix/fix-docker-permissions
hotfix/security-patch
release/v1.2.0
chore/update-dependencies
docs/update-readme
test/add-unit-tests
refactor/cleanup-code
```

**❌ Bad:**
```bash
new-feature
fix-bug
update
patch
```

## 🔧 Configuration

### Environment Variables

The workflows use these environment variables:

- `REGISTRY`: `ghcr.io` (GitHub Container Registry)
- `IMAGE_NAME`: `PrestonHager/python-uv`

### Secrets Required

- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
- No additional secrets required for public repositories

### Registry Access

Images are pushed to GitHub Container Registry (`ghcr.io/PrestonHager/python-uv`) with these tags:

- `3.8`, `3.9`, `3.10`, `3.11`, `3.12`, `3.13` - Version-specific
- `latest` - Points to latest Python version
- `main-<sha>` - Branch-specific builds
- `pr-<number>` - Pull request builds

## 📊 Workflow Status

### Success Criteria

- ✅ All Python versions build successfully
- ✅ All tests pass (Python, UV, entrypoint, permissions, Alpine)
- ✅ Security scan passes
- ✅ Branch naming convention followed
- ✅ JSON files are valid
- ✅ Scripts have valid syntax

### Failure Handling

- ❌ **Build failures**: Workflow stops, no images pushed
- ❌ **Test failures**: Workflow stops, detailed error logs
- ❌ **Security issues**: Reported to GitHub Security tab
- ❌ **Naming violations**: PR comments, merge blocked

## 🔍 Monitoring

### GitHub Security Tab
- Vulnerability scan results
- Dependency security alerts
- Code scanning results

### Actions Tab
- Workflow run history
- Build logs and artifacts
- Performance metrics

### Releases Tab
- Automatic releases with egg configurations
- Release notes and changelog
- Downloadable artifacts

## 🛠️ Troubleshooting

### Common Issues

**Build Failures:**
```bash
# Check Dockerfile syntax
docker buildx build --dry-run .

# Test single version
docker build --build-arg PYTHON_VERSION=3.11 .
```

**Script Errors:**
```bash
# Check syntax
bash -n build-images.sh
bash -n test-images.sh
bash -n entrypoint.sh
```

**JSON Validation:**
```bash
# Validate JSON files
python3 -m json.tool python-uv-egg-simple.json
```

### Debug Mode

Enable debug logging by adding to workflow:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

## 📚 References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Buildx Action](https://github.com/docker/setup-buildx-action)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy-action)
- [Branch Naming Conventions](https://medium.com/@abhay.pixolo/naming-conventions-for-git-branches-a-cheatsheet-8549feca2534)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
