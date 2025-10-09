#!/bin/bash

# Script to install Claude Code extension for Cursor IDE using Open VSX Registry
# This bypasses Microsoft marketplace certificate issues

echo "🚀 Installing Claude Code Extension for Cursor IDE (Open VSX Method)..."
echo "====================================================================="

# Set environment variables to handle certificate issues
export NODE_TLS_REJECT_UNAUTHORIZED=0
export ELECTRON_EXTRA_LAUNCH_ARGS='--ignore-certificate-errors-spki-list --ignore-certificate-errors --ignore-ssl-errors'

# Check if Cursor is installed
if ! command -v cursor &> /dev/null; then
    echo "❌ Cursor IDE not found in PATH"
    echo "Please make sure Cursor is installed and accessible via 'cursor' command"
    exit 1
fi

echo "✅ Cursor IDE found"

# Create temporary directory
TEMP_DIR="/tmp/claude_extension_openvsx_$(date +%s)"
mkdir -p "$TEMP_DIR"

# Function to download and install extension from Open VSX
download_and_install_claude() {
    local publisher="Anthropic"
    local extension="claude"
    local display_name="Claude"
    
    echo "🔍 Searching for Claude extension on Open VSX..."
    
    # First, let's check if the extension exists on Open VSX
    local search_url="https://open-vsx.org/api/${publisher}/${extension}"
    
    echo "Checking: $search_url"
    
    # Try to get extension info
    local response=$(curl -s "$search_url")
    
    if echo "$response" | grep -q "error"; then
        echo "❌ Claude extension not found on Open VSX Registry"
        echo ""
        echo "🔧 This means we need to use the manual installation method:"
        echo ""
        echo "📋 Manual Installation Steps:"
        echo "============================="
        echo "1. Open Cursor IDE"
        echo "2. Press Cmd+Shift+X to open Extensions panel"
        echo "3. Search for 'Claude'"
        echo "4. Look for 'Claude' by Anthropic"
        echo "5. Click 'Install'"
        echo "6. Restart Cursor IDE"
        echo ""
        echo "🔗 Direct Extension URL: https://marketplace.visualstudio.com/items?itemName=Anthropic.claude"
        echo ""
        echo "💡 If you can't access the marketplace due to corporate restrictions:"
        echo "   - Try using a VPN or different network"
        echo "   - Contact your IT department about marketplace access"
        echo "   - Ask them to whitelist marketplace.visualstudio.com"
        return 1
    fi
    
    echo "✅ Found Claude extension on Open VSX"
    
    # Get the latest version
    local version=$(echo "$response" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$version" ]; then
        echo "❌ Could not get version information"
        return 1
    fi
    
    echo "📦 Latest version: $version"
    
    # Download the VSIX file
    local download_url="https://open-vsx.org/api/${publisher}/${extension}/${version}/file/${publisher}.${extension}-${version}.vsix"
    
    echo "⬇️  Downloading from: $download_url"
    
    if curl -L -o "$TEMP_DIR/${extension}.vsix" "$download_url"; then
        echo "✅ Downloaded Claude extension successfully"
        
        # Check file size to make sure it's not empty
        local file_size=$(stat -f%z "$TEMP_DIR/${extension}.vsix" 2>/dev/null || stat -c%s "$TEMP_DIR/${extension}.vsix" 2>/dev/null)
        
        if [ "$file_size" -lt 1000 ]; then
            echo "❌ Downloaded file is too small ($file_size bytes), likely corrupted"
            return 1
        fi
        
        echo "📁 File size: $file_size bytes"
        
        # Install the VSIX file
        echo "🔧 Installing extension..."
        if cursor --install-extension "$TEMP_DIR/${extension}.vsix"; then
            echo "✅ Successfully installed Claude extension!"
            echo ""
            echo "🎉 Installation complete!"
            echo ""
            echo "🔄 Please restart Cursor IDE for the extension to take effect"
            echo ""
            echo "💡 After restarting, you should be able to:"
            echo "  - Access AI features via Cmd+L (AI Chat)"
            echo "  - Use Cmd+I for code explanations"
            echo "  - Get integrated development features"
            echo "  - Connect to IDE for integrated development"
            return 0
        else
            echo "❌ Failed to install extension"
            echo ""
            echo "🔧 Troubleshooting:"
            echo "1. Make sure Cursor is completely closed"
            echo "2. Try running: cursor --install-extension \"$TEMP_DIR/${extension}.vsix\""
            echo "3. Check Cursor's extension directory permissions"
            return 1
        fi
    else
        echo "❌ Failed to download Claude extension"
        return 1
    fi
}

# Try to install Claude extension
if download_and_install_claude; then
    echo ""
    echo "🎊 Success! Claude extension has been installed."
else
    echo ""
    echo "⚠️  Automated installation failed. Please use the manual method above."
fi

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "📚 Additional Information:"
echo "========================="
echo "• The Claude extension enables AI-powered code assistance"
echo "• It provides context-aware suggestions and explanations"
echo "• You can access it via Cmd+L (AI Chat) after restarting Cursor"
echo "• The extension integrates with your current workspace"
