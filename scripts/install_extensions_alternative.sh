#!/bin/bash

# Alternative VS Code Extension Installation Script
# This script provides multiple approaches to install the required extensions

echo "VS Code Extension Installation - Alternative Methods"
echo "=================================================="
echo ""

# Check if VS Code is available
if ! command -v code &> /dev/null; then
    echo "❌ VS Code CLI not found. Please ensure VS Code is installed and 'code' command is in PATH."
    exit 1
fi

echo "✅ VS Code CLI found"
echo ""

# Check current extensions
echo "Current extensions status:"
echo "-------------------------"

# Check Python Extension Pack
if code --list-extensions | grep -q "ms-python.python"; then
    echo "✅ Python Extension Pack (ms-python.python) - INSTALLED"
else
    echo "❌ Python Extension Pack (ms-python.python) - NOT INSTALLED"
fi

# Check Path Intellisense
if code --list-extensions | grep -q "christian-kohler.path-intellisense"; then
    echo "✅ Path Intellisense (christian-kohler.path-intellisense) - INSTALLED"
else
    echo "❌ Path Intellisense (christian-kohler.path-intellisense) - NOT INSTALLED"
fi

# Check Better Comments
if code --list-extensions | grep -q "aaron-bond.better-comments"; then
    echo "✅ Better Comments (aaron-bond.better-comments) - INSTALLED"
else
    echo "❌ Better Comments (aaron-bond.better-comments) - NOT INSTALLED"
fi

# Check Ruff
if code --list-extensions | grep -q "charliermarsh.ruff"; then
    echo "✅ Ruff (charliermarsh.ruff) - INSTALLED"
else
    echo "❌ Ruff (charliermarsh.ruff) - NOT INSTALLED"
fi

echo ""
echo "Installation Methods:"
echo "===================="
echo ""
echo "Method 1: Manual Installation (Recommended)"
echo "1. Open VS Code"
echo "2. Press Ctrl+Shift+X (or Cmd+Shift+X on Mac)"
echo "3. Search for each extension and click Install:"
echo "   - Path Intellisense"
echo "   - Better Comments" 
echo "   - Ruff"
echo ""
echo "Method 2: Direct Marketplace Links"
echo "- Path Intellisense: https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense"
echo "- Better Comments: https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments"
echo "- Ruff: https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff"
echo ""
echo "Method 3: Try CLI installation with different approaches"
echo ""

# Try installing with different certificate handling
echo "Attempting CLI installation with certificate workarounds..."

# Method 3a: Try with --force and different environment
echo "Trying Path Intellisense..."
if code --install-extension christian-kohler.path-intellisense --force 2>/dev/null; then
    echo "✅ Path Intellisense installed successfully"
else
    echo "❌ Path Intellisense installation failed"
fi

echo "Trying Better Comments..."
if code --install-extension aaron-bond.better-comments --force 2>/dev/null; then
    echo "✅ Better Comments installed successfully"
else
    echo "❌ Better Comments installation failed"
fi

echo "Trying Ruff..."
if code --install-extension charliermarsh.ruff --force 2>/dev/null; then
    echo "✅ Ruff installed successfully"
else
    echo "❌ Ruff installation failed"
fi

echo ""
echo "Final Status Check:"
echo "==================="

# Re-check extensions
if code --list-extensions | grep -q "christian-kohler.path-intellisense"; then
    echo "✅ Path Intellisense - NOW INSTALLED"
else
    echo "❌ Path Intellisense - STILL NOT INSTALLED (use manual method)"
fi

if code --list-extensions | grep -q "aaron-bond.better-comments"; then
    echo "✅ Better Comments - NOW INSTALLED"
else
    echo "❌ Better Comments - STILL NOT INSTALLED (use manual method)"
fi

if code --list-extensions | grep -q "charliermarsh.ruff"; then
    echo "✅ Ruff - NOW INSTALLED"
else
    echo "❌ Ruff - STILL NOT INSTALLED (use manual method)"
fi

echo ""
echo "If any extensions are still not installed, please use the manual installation method."
echo "The certificate issue appears to be related to your network/proxy configuration."
