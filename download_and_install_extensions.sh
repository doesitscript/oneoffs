#!/bin/bash

# Script to download and install VS Code extensions manually
# This bypasses the certificate issue by downloading VSIX files directly

echo "Downloading and installing VS Code extensions manually..."

# Create a temporary directory for downloads
TEMP_DIR="/tmp/vscode_extensions_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Function to download and install extension
download_and_install() {
    local extension_id="$1"
    local extension_name="$2"
    
    echo "Downloading $extension_name ($extension_id)..."
    
    # Download the VSIX file
    local download_url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${extension_id%%.*}/vsextensions/${extension_id##*.}/latest/vspackage"
    
    # Use curl with -k to ignore certificate issues
    if curl -k -L -o "$TEMP_DIR/${extension_name}.vsix" "$download_url"; then
        echo "✓ Downloaded $extension_name"
        
        # Install the VSIX file
        if /opt/homebrew/bin/code --install-extension "$TEMP_DIR/${extension_name}.vsix"; then
            echo "✓ Successfully installed $extension_name"
        else
            echo "✗ Failed to install $extension_name"
        fi
    else
        echo "✗ Failed to download $extension_name"
    fi
}

# Install extensions
download_and_install "christian-kohler.path-intellisense" "path-intellisense"
download_and_install "aaron-bond.better-comments" "better-comments"
download_and_install "charliermarsh.ruff" "ruff"

# Clean up
rm -rf "$TEMP_DIR"

echo "Manual extension installation complete!"