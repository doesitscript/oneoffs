# Complete Solution: Installing Claude Code Extension for Cursor IDE

## Problem Summary
You're seeing "No available IDEs detected" because the Claude Code extension isn't installed in Cursor IDE. This is happening due to corporate certificate restrictions and network policies.

## Root Cause Analysis
1. **Certificate Issues**: Corporate environment has self-signed certificates blocking marketplace access
2. **Network Restrictions**: Firewall policies may block marketplace.visualstudio.com
3. **Extension ID Confusion**: The correct extension ID is `anthropic.claude-code`, not `Anthropic.claude`

## Complete Solution

### Method 1: Manual Installation (Recommended for Corporate Environments)

**Step 1: Open Cursor IDE**
- Launch Cursor IDE

**Step 2: Access Extensions Panel**
- Press `Cmd+Shift+X` (or go to View → Extensions)

**Step 3: Search for Extension**
- Search for "Claude Code" or "anthropic.claude-code"
- Look for "Claude Code" by Anthropic

**Step 4: Install**
- Click "Install" button
- Wait for installation to complete

**Step 5: Restart**
- Restart Cursor IDE completely

### Method 2: Direct Marketplace URL
If the search doesn't work:
1. Open this URL in your browser: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
2. Click "Install" button
3. It should open in Cursor IDE

### Method 3: Command Line Installation (If Network Allows)
```bash
# Try with certificate bypass
NODE_TLS_REJECT_UNAUTHORIZED=0 cursor --install-extension "anthropic.claude-code"
```

### Method 4: Corporate Network Workarounds

**Option A: VPN Access**
- Connect to a VPN that allows marketplace access
- Try installation methods above

**Option B: IT Department Request**
Ask your IT department to:
1. Whitelist these domains:
   - `marketplace.visualstudio.com`
   - `vscode.blob.core.windows.net`
   - `*.gallerycdn.vsassets.io`
2. Download the extension file for you
3. Provide the `.vsix` file for manual installation

**Option C: Alternative Network**
- Try from a different network (home, mobile hotspot)
- Install the extension
- It will sync to your corporate environment

### Method 5: Manual File Installation
If you can get the extension file:

1. **Download the extension**:
   - Go to: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
   - Click "Download Extension" (right side)
   - Save the `.vsix` file

2. **Install via command line**:
   ```bash
   cursor --install-extension /path/to/downloaded/claude-code.vsix
   ```

## Verification Steps

After installation, verify by:

1. **Check installed extensions**:
   ```bash
   cursor --list-extensions | grep claude
   ```

2. **Test AI features**:
   - Press `Cmd+L` to open AI Chat
   - Press `Cmd+I` to explain code
   - Look for AI suggestions in the editor

3. **Check IDE integration**:
   - The "No available IDEs detected" message should disappear
   - You should see integrated development features

## Troubleshooting

### If Installation Still Fails:

1. **Check Cursor Version**:
   ```bash
   cursor --version
   ```
   Ensure you have a recent version

2. **Clear Extension Cache**:
   ```bash
   rm -rf ~/.cursor/extensions
   ```

3. **Try Different User**:
   ```bash
   sudo cursor --install-extension "anthropic.claude-code"
   ```

4. **Check Permissions**:
   ```bash
   ls -la ~/.cursor/
   ```

### Alternative: Use Built-in Cursor AI
If you can't install the extension, Cursor has built-in AI features:
- `Cmd+K` for inline AI editing
- `Cmd+L` for AI chat (may work without extension)
- `Cmd+I` for code explanations

## Expected Results

After successful installation:
- ✅ Claude Code extension appears in installed extensions
- ✅ AI Chat accessible via `Cmd+L`
- ✅ Code explanations via `Cmd+I`
- ✅ Integrated development features available
- ✅ "No available IDEs detected" message disappears

## Additional Resources

- **Official Documentation**: https://docs.anthropic.com/en/docs/claude-code/getting-started
- **Extension Marketplace**: https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
- **GitHub Repository**: https://github.com/anthropics/claude-code

## Corporate Environment Notes

If you're in a corporate environment:
1. **Document the issue** for your IT team
2. **Request marketplace access** for development tools
3. **Consider using a development VPN** for extension access
4. **Ask IT to pre-approve** common development extensions

The extension is essential for modern AI-assisted development workflows.
