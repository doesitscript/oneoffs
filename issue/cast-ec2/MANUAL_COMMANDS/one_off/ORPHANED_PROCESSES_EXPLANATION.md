# Why MCP Server Processes Become Orphaned and Accumulate

## The Process Lifecycle Problem

### Normal Operation (Healthy State)

```
Time T0: Cursor starts up
┌─────────────────────────────────────────┐
│ PID 1 (launchd - macOS init process)   │
│                                         │
│   └─ PID 14460 (Cursor.app)            │
│         │                               │
│         └─ PID 14587 (extension-host)   │
│               │                         │
│               └─ PID 17777 (mcp-guard)  │ ← Properly parented
│                     │                   │
│                     ├─ child processes  │
│                     └─ grandchildren... │
└─────────────────────────────────────────┘
```

**Key Points:**
- Each process has a **Parent Process ID (PPID)**
- Child processes inherit their parent's process group
- When you kill a parent, normally children should also terminate

### What Happens During Restart/Crash

```
Time T1: Cursor extension-host crashes or restarts
┌─────────────────────────────────────────┐
│ PID 1 (launchd)                         │
│                                         │
│   ├─ PID 14460 (Cursor.app)            │ ← Still running
│   │     └─ [NEW] PID 14587 ← Restarted │
│   │           └─ [NEW] PID 17777       │
│   │                                     │
│   └─ [ORPHANED] PID 17678 ← Old process│
│         │                               │ ← PPID now = 1!
│         └─ Its children still running   │
└─────────────────────────────────────────┘
```

## Why Processes Become Orphaned

### 1. **Unix Process Reparenting**
   - When a parent process dies, the kernel automatically **reparents** orphaned children to PID 1 (init/launchd)
   - This is standard Unix behavior - PID 1 becomes the "ultimate parent" of all orphaned processes
   - The reparenting happens **immediately** when the parent dies

### 2. **Why MCP Servers Don't Die Automatically**
   
   **MCP servers are designed to be long-running:**
   - They handle stdio communication with Cursor
   - They maintain state (connections, caches, etc.)
   - They're **not designed** to detect when their parent disappears
   
   **The process is still alive because:**
   - It's in a "sleeping" state (state 'S'), waiting for input
   - It hasn't crashed - it's just waiting on a pipe/stdio that will never get input
   - launchd (PID 1) doesn't automatically kill orphaned processes - it just collects them

### 3. **Common Scenarios That Create Orphans**

```
Scenario A: Extension Host Restart
├─ Cursor restarts extension-host for plugin updates
├─ Old extension-host process dies
├─ MCP servers it spawned → become orphans
└─ New extension-host starts → spawns NEW MCP servers

Scenario B: Cursor Crash/Force Quit
├─ User force-quits Cursor or it crashes
├─ Cursor main process dies
├─ Extension-host processes die
├─ MCP servers become orphans
└─ When Cursor restarts → spawns entirely NEW set

Scenario C: Plugin/Extension Reload
├─ Extension reloads to apply changes
├─ Extension-host may restart the plugin worker
├─ Old MCP server process becomes orphan
└─ New one starts
```

## Why They Accumulate Over Time

### The Accumulation Pattern

```
Session 1 (1:35 AM): Cursor starts
├─ Spawns: mcp-guard (PID 44456), mcp-guard (PID 46839)
└─ Cursor restarts → these become orphans

Session 2 (3:02 AM): Cursor starts again  
├─ Spawns: mcp-guard (PID 19983)
├─ Previous orphans still running (44456, 46839)
└─ Cursor restarts → 19983 becomes orphan

Session 3 (3:48 AM): Current session
├─ Spawns: mcp-guard (PID 17678), mcp-guard (PID 17777)
├─ Previous orphans still running (44456, 46839, 19983)
└─ If this session restarts → 17678 becomes orphan

Result: 4+ orphaned processes consuming resources
```

### Why They Don't Self-Cleanup

1. **No Signal Handling**: Most MCP servers don't implement `SIGPIPE` handlers
   - When parent dies, the stdio pipe breaks
   - Without proper signal handling, the process keeps waiting

2. **No Heartbeat/Health Checks**: 
   - MCP servers don't poll their parent
   - They assume the parent is alive as long as they're running

3. **launchd Doesn't Kill Them**:
   - launchd (PID 1) only reaps zombie processes
   - These are **living processes**, not zombies
   - launchd won't kill them unless explicitly configured

## Evidence from Your System

### Current Process Tree
```bash
# Healthy process (properly parented)
PID 17777, PPID 14587 (extension-host) ← Active
State: S (sleeping, waiting for input)

# Orphaned processes (reparented to launchd)
PID 17678, PPID 1 (launchd) ← ORPHANED from 3:48 AM
PID 19983, PPID 1 (launchd) ← ORPHANED from 3:02 AM  
PID 44456, PPID 1 (launchd) ← ORPHANED from 1:35 AM
PID 46839, PPID 1 (launchd) ← ORPHANED from 1:35 AM
```

All are in state **'S'** (sleeping/interruptible), meaning:
- They're still alive and consuming memory
- They're waiting on stdio pipes that will never receive data
- They won't terminate until explicitly killed

## Solutions

### Immediate Fix
```bash
# Find all orphaned MCP processes
ps -ef | awk '$3==1 && /mcp/ {print $2}'

# Kill them (they're safe to kill - parent is gone)
ps -ef | awk '$3==1 && /mcp/ {print $2}' | xargs kill
```

### Long-term Prevention
1. **MCP Server Improvements**: MCP servers should detect when stdin closes and exit gracefully
2. **Process Group Management**: Cursor could use process groups to ensure cleanup
3. **Periodic Cleanup Script**: Regular cron job to clean up orphaned MCP processes
4. **Better Signal Handling**: MCP servers should handle `SIGPIPE` and exit when parent dies

## Summary

The accumulation happens because:
1. ✅ **Unix behavior**: Orphaned processes get reparented to PID 1 (normal)
2. ✅ **MCP design**: Servers are long-running and don't detect parent death
3. ✅ **No cleanup**: launchd doesn't automatically kill living orphaned processes
4. ✅ **Restart patterns**: Each Cursor restart creates new processes but leaves old ones

This is a **process lifecycle management issue**, not a bug in Cursor or MCP - it's how Unix processes behave by design. The fix requires explicit cleanup either by MCP servers detecting orphaned state, or by manual/system cleanup.

