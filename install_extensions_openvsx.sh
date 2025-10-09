#!/bin/bash

# Script to install VS Code extensions using Open VSX Registry
# This bypasses the Microsoft marketplace certificate issues

echo "Installing VS Code extensions using Open VSX Registry..."

# Create a temporary directory for downloads
TEMP_DIR="/tmp/vscode_extensions_openvsx_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Function to download and install extension from Open VSX
download_and_install_openvsx() {
    local publisher="$1"
    local extension="$2"
    local display_name="$3"
    
    echo "Downloading $display_name from Open VSX..."
    
    # Get the latest version from Open VSX API
    local api_url="https://open-vsx.org/api/${publisher}/${extension}/latest"
    local version=$(curl -s "$api_url" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$version" ]; then
        echo "✗ Could not get version for $display_name"
        return 1
    fi
    
    echo "Latest version: $version"
    
    # Download the VSIX file
    local download_url="https://open-vsx.org/api/${publisher}/${extension}/${version}/file/${publisher}.${extension}-${version}.vsix"
    
    if curl -L -o "$TEMP_DIR/${extension}.vsix" "$download_url"; then
        echo "✓ Downloaded $display_name"
        
        # Install the VSIX file
        if /opt/homebrew/bin/code --install-extension "$TEMP_DIR/${extension}.vsix"; then
            echo "✓ Successfully installed $display_name"
        else
            echo "✗ Failed to install $display_name"
        fi
    else
        echo "✗ Failed to download $display_name"
    fi
}

# Install extensions from Open VSX
download_and_install_openvsx "christian-kohler" "path-intellisense" "Path Intellisense"
download_and_install_openvsx "aaron-bond" "better-comments" "Better Comments"
download_and_install_openvsx "charliermarsh" "ruff" "Ruff"

# Clean up
rm -rf "$TEMP_DIR"

echo "Open VSX extension installation complete!"

