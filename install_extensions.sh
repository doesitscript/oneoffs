#!/bin/bash

# Script to install VS Code extensions globally
# Handles certificate issues by setting NODE_TLS_REJECT_UNAUTHORIZED

echo "Installing VS Code extensions globally..."

# Set environment variable to bypass certificate verification
export NODE_TLS_REJECT_UNAUTHORIZED=0

# List of extensions to install
extensions=(
    "christian-kohler.path-intellisense"
    "aaron-bond.better-comments" 
    "charliermarsh.ruff"
)

# Install each extension
for extension in "${extensions[@]}"; do
    echo "Installing $extension..."
    /opt/homebrew/bin/code --install-extension "$extension"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully installed $extension"
    else
        echo "✗ Failed to install $extension"
    fi
done

# Check if Python Extension Pack is already installed
echo "Checking Python Extension Pack..."
/opt/homebrew/bin/code --list-extensions | grep -q "ms-python.python"
if [ $? -eq 0 ]; then
    echo "✓ Python Extension Pack is already installed"
else
    echo "Installing Python Extension Pack..."
    /opt/homebrew/bin/code --install-extension ms-python.python
fi

echo "Extension installation complete!"

