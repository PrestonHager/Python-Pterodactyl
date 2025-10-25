# Python UV Egg Testing Guide

## 🚨 Problem Identified
The installation and runtime containers use different mount points:
- **Installation container**: `/mnt/server` (files persist here)
- **Runtime container**: `/home/container` (files are accessible here)

The files DO persist between installation and runtime, but we need to use the correct paths!

## ✅ Solution: Correct Mount Points

The key insight is that files created in `/mnt/server` during installation are accessible in `/home/container` during runtime.

## 📋 Testing Steps

### 1. Test the Minimal Egg First
Upload `python-uv-test-minimal.json` to your Pterodactyl panel first. This is a simplified version that should work without 500 errors.

### 2. Verify the Startup Script
After uploading and creating a server:
1. Check if `start.sh` file exists in `/home/container/`
2. Check if it has content (not 0 bytes)
3. Check if it's executable

### 3. Test Repository Cloning
Set these environment variables:
- `REPO_URL`: `https://github.com/PrestonHager/CreatureCafe.git`
- `PULL_ON_START`: `true`
- `UV_PYTHON_VERSION`: `3.11`
- `STARTUP_SCRIPT`: `uv run python main.py`

### 4. Expected Behavior
**During Installation:**
1. Clone your repository to `/mnt/server/repo/`
2. Install `uv` package manager
3. Initialize UV project with `pyproject.toml`
4. Install additional packages if specified

**During Runtime:**
1. Install `uv` if not present (fallback)
2. Navigate to `/home/container/repo/` (same files as `/mnt/server/repo/`)
3. Pull latest changes if `PULL_ON_START=true`
4. Install any new packages
5. Run your startup script

## 🔧 Key Differences in the Test Egg

1. **Simplified JSON**: Removed complex escaping that was causing 500 errors
2. **Minimal Variables**: Only essential variables to reduce complexity
3. **Single Docker Image**: Only Python 3.11 to simplify testing
4. **Simplified Installation**: Basic installation script that just echoes success

## 🐳 Docker Testing Alternative

If you want to test locally, you can simulate the Pterodactyl environment:

```bash
# Create a test container
docker run -it --rm -v $(pwd):/test python:3.11-slim bash

# Inside the container, test the startup script logic
cd /test
# Set environment variables
export REPO_URL="https://github.com/PrestonHager/CreatureCafe.git"
export PULL_ON_START="true"
export UV_PYTHON_VERSION="3.11"
export STARTUP_SCRIPT="uv run python main.py"

# Test the startup script
bash start.sh
```

## 📝 Next Steps

1. **Upload the minimal test egg** and verify it works
2. **Test with your repository** to ensure cloning works
3. **Gradually add features** back to the full egg once the basic version works
4. **Add authentication** if needed for private repositories

## 🎯 Success Criteria

- ✅ No 500 errors when uploading the egg
- ✅ `start.sh` file is created with content
- ✅ Repository is cloned to `/mnt/server/repo/` during installation
- ✅ Repository is accessible at `/home/container/repo/` during runtime
- ✅ UV environment is initialized
- ✅ Application starts successfully

The key insight is that **files persist between installation and runtime** - we just need to use the correct mount points!
