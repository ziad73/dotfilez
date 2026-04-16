#!/bin/bash

# Define the root directory
ROOT_DIR="."

echo "Searching for .sh files in $ROOT_DIR..."

# Use -v before the mode change
# We use -name "*.sh" to target your scripts specifically
find "$ROOT_DIR" -type f -name "*.sh" -exec chmod -v +x {} +

echo "Done! All shell scripts are now executable."
