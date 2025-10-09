# Manual Claude Extension Installation Guide

## Problem
You're seeing "No available IDEs detected" because the Claude Code extension isn't installed in Cursor IDE.

## Why This Happens
- Corporate certificate restrictions
- Network policies blocking marketplace access
- Security policies requiring manual approval

## Solution: Manual Installation

### Method 1: Through Cursor IDE Extensions Panel
1. Open Cursor IDE
2. Press `Cmd+Shift+X` (or go to View → Extensions)
3. Search for "Claude"
4. Find "Claude" by Anthropic
5. Click "Install"
6. Restart Cursor IDE

### Method 2: Direct Marketplace URL
If the search doesn't work, try opening this URL directly:
```
https://marketplace.visualstudio.com/items?itemName=Anthropic.claude
```

### Method 3: Download and Install Manually
If you have access to download files:

1. **Download the extension**:
   - Go to: https://marketplace.visualstudio.com/items?itemName=Anthropic.claude
   - Click "Download Extension" (right side of the page)
   - Save the `.vsix` file

2. **Install the extension**:
   ```bash
   cursor --install-extension /path/to/downloaded/claude.vsix
   ```

### Method 4: Corporate Network Workarounds
If you're behind a corporate firewall:

1. **Use a VPN** to access the marketplace
2. **Contact IT** to whitelist these domains:
   - `marketplace.visualstudio.com`
   - `vscode.blob.core.windows.net`
   - `*.gallerycdn.vsassets.io`

3. **Ask IT** to download and provide the extension file

## Verification
After installation, you should be able to:
- Press `Cmd+L` to open AI Chat
- Press `Cmd+I` to explain code
- See AI suggestions in the editor
- Connect to IDE for integrated development features

## Troubleshooting
If installation fails:
1. Make sure Cursor is completely closed
2. Check file permissions
3. Try running with `sudo` (if needed)
4. Verify the downloaded file isn't corrupted

## Alternative: Use Cursor's Built-in AI
If you can't install the extension, Cursor has built-in AI features:
- `Cmd+K` for inline AI editing
- `Cmd+L` for AI chat (may work without extension)
- `Cmd+I` for code explanations

The extension just provides additional integration and features.
