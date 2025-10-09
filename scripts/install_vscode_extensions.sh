#!/bin/bash

# Install VS Code extensions globally
# This script installs the recommended extensions for the workspace

echo "Installing VS Code extensions globally..."

# Python Extension Pack
echo "Installing Python Extension Pack..."
code --install-extension ms-python.python

# Path Intellisense
echo "Installing Path Intellisense..."
code --install-extension christian-kohler.path-intellisense

# Better Comments
echo "Installing Better Comments..."
code --install-extension aaron-bond.better-comments

# Ruff
echo "Installing Ruff..."
code --install-extension charliermarsh.ruff

echo "All extensions installed successfully!"
echo ""
echo "Installed extensions:"
echo "- Python Extension Pack (ms-python.python)"
echo "- Path Intellisense (christian-kohler.path-intellisense)"
echo "- Better Comments (aaron-bond.better-comments)"
echo "- Ruff (charliermarsh.ruff)"
