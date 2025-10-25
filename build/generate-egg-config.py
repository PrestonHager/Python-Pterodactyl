#!/usr/bin/env python3
"""
Python UV Egg Configuration Generator

This script generates a properly formatted Pterodactyl egg JSON configuration
by parsing the template and inserting dynamic values with correct JSON escaping.
"""

import json
import sys
import os
from datetime import datetime, timezone
from typing import Dict, List, Any


def generate_egg_config(
    python_versions: List[str],
    registry: str = "ghcr.io",
    image_name: str = "prestonhager/python-uv",
    tag_prefix: str = ""
) -> Dict[str, Any]:
    """Generate the egg configuration with proper JSON formatting."""
    
    # Load the template
    template_path = os.path.join(os.path.dirname(__file__), "..", "python-uv-egg-simple.json")
    with open(template_path, 'r') as f:
        config = json.load(f)
    
    # Update metadata
    config["exported_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S+00:00")
    
    # Generate docker images
    docker_images = {}
    for version in python_versions:
        image_tag = f"{registry}/{image_name}:{tag_prefix}{version}"
        docker_images[f"python-uv-{version}"] = image_tag
    
    config["docker_images"] = docker_images
    
    return config


def main():
    """Main function to generate the egg configuration."""
    # Default Python versions (latest first)
    python_versions = ["3.14", "3.13", "3.12", "3.11", "3.10", "3.9", "3.8"]
    
    # Get environment variables
    registry = os.environ.get("REGISTRY", "ghcr.io")
    image_name = os.environ.get("IMAGE_NAME", "prestonhager/python-uv")
    tag_prefix = os.environ.get("TAG_PREFIX", "")
    
    # Generate configuration
    config = generate_egg_config(python_versions, registry, image_name, tag_prefix)
    
    # Output file path
    output_file = os.path.join(os.path.dirname(__file__), "python-uv-egg-custom-images.json")
    
    # Write the configuration
    with open(output_file, 'w') as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Generated egg configuration: {output_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
