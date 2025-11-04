# Multiple Workspaces = Multiple MCP Servers

## Your Current Situation

You have **2 Cursor windows/workspaces** open, and each spawns its own complete set of MCP servers:

```
Cursor Main Process (PID 14460)
│
├─ Extension Host [3-2] (PID 14587) ← Window/Workspace 3
│   └─ 16 MCP servers spawned
│       ├─ vscode-mcp-server (PID 16221)
│       ├─ macos-automator-mcp (PID 16092)
│       ├─ awslabs.cdk-mcp-server (PID 17236)
│       ├─ awslabs.ccapi-mcp-server (PID 17391)
│       ├─ terraform-mcp-server (PID 17546)
│       ├─ awslabs.terraform-mcp-server (PID 17558)
│       ├─ mcp-pandoc (PID 17653)
│       ├─ mcp-mermaid (PID 16895)
│       ├─ evidence-validator (PID 17753)
│       ├─ mcp-guard (PID 17777) ← wraps multiple servers
│       ├─ playwright (PID 18104)
│       ├─ exa-mcp-server (PID 18237)
│       ├─ mcp-ripgrep (PID 18559)
│       ├─ filesystem (PID 18560)
│       └─ terravision-mcp (PID 18645)
│
└─ Extension Host [1-3] (PID 14591) ← Window/Workspace 1
    └─ 5 MCP servers spawned
        ├─ vscode-mcp-server (PID 15545)
        ├─ awslabs.cdk-mcp-server (PID 15790)
        ├─ awslabs.ccapi-mcp-server (PID 15993)
        ├─ terraform-mcp-server (PID 16272)
        └─ awslabs.terraform-mcp-server (PID 16304)
```

## Why This Happens

### 1. **Workspace Isolation**
Each Cursor window/workspace gets its own:
- Extension host process
- Complete MCP server configuration
- Separate stdio communication channels

This is **by design** - Cursor treats each workspace as independent, so:
- ✅ Each workspace can have different MCP configurations
- ✅ MCP servers don't interfere with each other
- ✅ One workspace crash doesn't affect others

### 2. **Complete MCP Server Sets**
Each extension-host spawns **all enabled MCP servers** from your `~/.cursor/mcp.json`:

**Your config has 20+ MCP server definitions**, and each workspace loads them all:
- vscode-mcp-server
- awslabs.cdk-mcp-server  
- awslabs.ccapi-mcp-server
- awslabs.terraform-mcp-server
- terraform-mcp-server
- mcp-guard (which wraps more servers)
- Playwright
- exa-local
- ripgrep
- filesystem
- ...and more

### 3. **The Multiplication Effect**

```
Open 1 workspace  → 16 MCP servers
Open 2 workspaces → 32 MCP servers (16 × 2)
Open 3 workspaces → 48 MCP servers (16 × 3)
+ Orphaned from previous sessions → Even more!
```

## Current State Analysis

### Active MCP Servers (Properly Parented)

**Extension Host [3-2] (PID 14587)** - 16 servers:
- Has the full configuration loaded
- Many servers specific to this workspace's needs

**Extension Host [1-3] (PID 14591)** - 5 servers:
- Smaller subset (likely a simpler project)
- Shared infrastructure servers (AWS, Terraform)

### Duplicate Servers Across Workspaces

Some servers appear in **both** workspaces:
- `vscode-mcp-server`: 2 instances (one per workspace)
- `awslabs.cdk-mcp-server`: 2 instances
- `awslabs.ccapi-mcp-server`: 2 instances  
- `awslabs.terraform-mcp-server`: 2 instances
- `terraform-mcp-server`: 2 instances

**Plus duplicates from orphaned processes:**
- `awslabs.cdk-mcp-server`: 4 total (2 active + 2 orphaned)
- `awslabs.ccapi-mcp-server`: 4 total (2 active + 2 orphaned)
- `vscode-mcp-server`: 4 total (2 active + 2 orphaned)
- `mcp-guard`: 5+ total (1 active + 4 orphaned)

## Why You See So Many MCP Servers

### Combined Factors:

1. **Multiple Workspaces** (Current Issue)
   - 2 workspaces × 16 servers = 32+ server processes

2. **Orphaned Processes** (Previous Sessions)
   - 4+ orphaned mcp-guard processes
   - Additional orphaned AWS/Terraform servers

3. **MCP Guard Wrapping**
   - `mcp-guard` spawns child processes (memory-keeper, chat-history-recorder)
   - Each guard instance = 3 processes (guard + 2 children)

4. **NPX/UV Wrapper Processes**
   - Many servers spawn via `npm exec` or `uv tool uvx`
   - Each = parent wrapper + actual server process
   - Example: `npm exec vscode-mcp-server` → npm process + node process

## Impact

### Resource Usage
- **Memory**: Each MCP server uses ~10-100MB
- **File descriptors**: Each stdio connection uses file handles
- **CPU**: Minimal when idle, but startup overhead

### With Your Setup:
- 21 active MCP processes (properly parented)
- 4+ orphaned processes
- **Total: 25+ MCP server processes running**

## Solutions

### Option 1: Disable Unused MCP Servers (Recommended)
Edit `~/.cursor/mcp.json` and set `"disabled": true` for servers you don't need:

```json
{
  "mcpServers": {
    "mcp-pandoc": {
      "disabled": true,  // ← Add this
      ...
    },
    "mcp-mermaid": {
      "disabled": true,  // ← Only enable if needed
      ...
    }
  }
}
```

### Option 2: Workspace-Specific MCP Config
Some MCP servers support workspace-level configuration, but Cursor currently uses a global `mcp.json` file.

### Option 3: Clean Up Orphaned Processes
```bash
# Kill orphaned MCP processes
ps -ef | awk '$3==1 && /mcp/ {print $2}' | xargs kill
```

### Option 4: Close Unused Workspaces
- Close workspaces you're not actively using
- Each closed workspace = fewer MCP servers

## Recommendations

1. **Audit Your MCP Config**: Disable servers you rarely use
2. **Monitor Resource Usage**: Use `htop` or `Activity Monitor` to see actual impact
3. **Periodic Cleanup**: Run cleanup script for orphaned processes
4. **Workspace Strategy**: Use separate Cursor instances only when needed

## Summary

**Your question answered:**
> "What about when I open more than one workspace and one project has many MCP servers?"

**Answer:** Yes! Each workspace spawns its own complete set of MCP servers. With:
- 2 workspaces open
- 20+ MCP servers configured
- Plus orphaned processes from previous sessions

You end up with **25+ MCP server processes** running simultaneously. This is expected behavior, but you can optimize by:
1. Disabling unused MCP servers
2. Closing unused workspaces  
3. Cleaning up orphaned processes

