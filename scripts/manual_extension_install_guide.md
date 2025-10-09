# Manual VS Code Extension Installation Guide

Due to certificate issues preventing automatic installation, here's how to manually install the recommended extensions:

## Extensions to Install

### 1. Python Extension Pack ✅ (Already Installed)
- **Extension ID**: `ms-python.python`
- **Status**: Already installed
- **Description**: Provides Python language support, debugging, and more

### 2. Path Intellisense
- **Extension ID**: `christian-kohler.path-intellisense`
- **Manual Installation**:
  1. Open VS Code
  2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions view
  3. Search for "Path Intellisense"
  4. Click "Install" on the extension by Christian Kohler
- **Description**: Autocompletes filenames in import statements

### 3. Better Comments
- **Extension ID**: `aaron-bond.better-comments`
- **Manual Installation**:
  1. Open VS Code
  2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions view
  3. Search for "Better Comments"
  4. Click "Install" on the extension by Aaron Bond
- **Description**: Improves your code commenting by colorizing different types of comments

### 4. Ruff
- **Extension ID**: `charliermarsh.ruff`
- **Manual Installation**:
  1. Open VS Code
  2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions view
  3. Search for "Ruff"
  4. Click "Install" on the extension by Charlie Marsh
- **Description**: An extremely fast Python linter and code formatter

## Alternative: Direct Marketplace Links

If the search doesn't work, you can use these direct links:

- [Path Intellisense](https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense)
- [Better Comments](https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments)
- [Ruff](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)

## Certificate Issue Resolution

The certificate issue preventing automatic installation might be resolved by:

1. **Corporate Network**: If you're on a corporate network, contact your IT department about VS Code extension installation
2. **Proxy Settings**: Configure VS Code proxy settings if behind a corporate proxy
3. **Firewall**: Ensure VS Code can access the marketplace

## Verification

After manual installation, verify all extensions are installed by running:
```bash
code --list-extensions | grep -E "(path-intellisense|better-comments|ruff)"
```
