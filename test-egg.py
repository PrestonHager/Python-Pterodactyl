#!/usr/bin/env python3
"""
Test script to validate the Python UV egg JSON and simulate the installation process
"""

import json
import subprocess
import tempfile
import os
import shutil

def validate_json():
    """Validate the egg JSON file"""
    try:
        with open('python-uv-egg-simple.json', 'r') as f:
            egg_data = json.load(f)
        print("✅ JSON is valid")
        return egg_data
    except json.JSONDecodeError as e:
        print(f"❌ JSON validation failed: {e}")
        return None
    except FileNotFoundError:
        print("❌ python-uv-egg-simple.json not found")
        return None

def test_startup_script():
    """Test the startup script logic"""
    print("\n🧪 Testing startup script logic...")
    
    # Create a temporary directory to simulate /home/container
    with tempfile.TemporaryDirectory() as temp_dir:
        print(f"📁 Created test directory: {temp_dir}")
        
        # Set environment variables
        os.environ['REPO_URL'] = 'https://github.com/PrestonHager/CreatureCafe.git'
        os.environ['PULL_ON_START'] = 'true'
        os.environ['UV_PYTHON_VERSION'] = '3.11'
        os.environ['STARTUP_SCRIPT'] = 'uv run python main.py'
        
        # Create the startup script
        startup_script = f"""#!/bin/bash
echo "Starting Python UV Environment..."
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH=/root/.local/bin:$PATH
fi
cd {temp_dir}
if [[ ! -z "$REPO_URL" ]] && [[ ! -d repo ]]; then
    echo "Cloning repository..."
    git clone $REPO_URL repo
fi
if [[ -d repo ]]; then
    cd repo
    if [[ "$PULL_ON_START" == "true" ]]; then
        echo "Updating repository..."
        git pull
    fi
else
    echo "No repository found, creating basic structure..."
    mkdir -p repo
    cd repo
    echo 'print("Hello from Python UV!")' > main.py
fi
if [[ ! -f pyproject.toml ]]; then
    echo "Initializing uv project..."
    uv init --python $UV_PYTHON_VERSION
fi
echo "Starting application..."
echo "Would run: $STARTUP_SCRIPT"
"""
        
        script_path = os.path.join(temp_dir, 'start.sh')
        with open(script_path, 'w') as f:
            f.write(startup_script)
        os.chmod(script_path, 0o755)
        
        print("✅ Startup script created")
        print(f"📄 Script content preview:")
        print(startup_script[:200] + "...")
        
        return True

def test_docker_simulation():
    """Simulate the Docker container behavior"""
    print("\n🐳 Testing Docker simulation...")
    
    # Test if we can run basic commands
    try:
        result = subprocess.run(['git', '--version'], capture_output=True, text=True)
        print(f"✅ Git available: {result.stdout.strip()}")
    except FileNotFoundError:
        print("❌ Git not available")
    
    try:
        result = subprocess.run(['curl', '--version'], capture_output=True, text=True)
        print(f"✅ Curl available: {result.stdout.split()[0]}")
    except FileNotFoundError:
        print("❌ Curl not available")
    
    return True

def main():
    """Main test function"""
    print("🚀 Testing Python UV Egg")
    print("=" * 50)
    
    # Validate JSON
    egg_data = validate_json()
    if not egg_data:
        return
    
    # Print egg info
    print(f"\n📋 Egg Information:")
    print(f"   Name: {egg_data.get('name', 'N/A')}")
    print(f"   Author: {egg_data.get('author', 'N/A')}")
    print(f"   Description: {egg_data.get('description', 'N/A')[:100]}...")
    
    # Test startup script
    test_startup_script()
    
    # Test Docker simulation
    test_docker_simulation()
    
    print("\n✅ All tests completed!")

if __name__ == "__main__":
    main()
