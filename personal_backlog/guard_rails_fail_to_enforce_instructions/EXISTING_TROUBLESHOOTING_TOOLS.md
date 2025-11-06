# Existing Guardrail Troubleshooting Tools

**Date**: 2025-01-28  
**Status**: Found comprehensive existing tools

## Summary

You already have **better, more comprehensive troubleshooting tools** than the simple diagnostic script I created. Here are the existing tools you should use:

## Primary Troubleshooting Tools

### 1. Conscious Stack Health Check ⭐ **MOST COMPREHENSIVE**

**Location**: `/Users/a805120/develop/workflows/scripts/setup/mcp_conscious_stack/conscious_stack_health.sh`

**Usage**:
```bash
make conscious-stack-health
```

**What it checks**:
- ✅ MCP Configuration (Guardrail, Memory Keeper, Chat History)
- ✅ Guardrail wrapping configuration
- ✅ Memory Keeper database and data directories
- ✅ Chat History Recorder setup
- ✅ Guardrail source and logs
- ✅ Running processes (Guardrail, Memory Keeper, Chat History)
- ✅ Process relationships (parent/child)
- ✅ Tool configuration
- ✅ Database accessibility
- ✅ Log file analysis

**Output**: Color-coded health check with specific issues and warnings

**This is the BEST tool for comprehensive guardrail troubleshooting.**

---

### 2. Guardrail Tool Availability Test

**Location**: `/Users/a805120/develop/workflows/scripts/test_guardrail_tools.sh`

**Usage**:
```bash
bash /Users/a805120/develop/workflows/scripts/test_guardrail_tools.sh
```

**What it checks**:
- ✅ Guardrail processes running
- ✅ Wrapped server processes (Memory Keeper, Chat History)
- ✅ Guardrail logs for errors
- ✅ Tool name prefixes (expected naming)
- ✅ Expected tool counts (~80 total)
- ✅ Database and log directories
- ✅ Process relationships

**Output**: Detailed test results with expected vs actual tool counts

**Use this to verify tool forwarding is working.**

---

### 3. Fix MCP Guardrail Configuration

**Location**: `/Users/a805120/develop/workflows/scripts/fix_mcp_guardrail.sh`

**Usage**:
```bash
make conscious-stack-fix-guardrail
# OR
bash /Users/a805120/develop/workflows/scripts/fix_mcp_guardrail.sh
```

**What it does**:
- ✅ Checks current Guardrail configuration
- ✅ Detects if Guardrail is wrapping empty array `[]`
- ✅ Fixes wrapping to include Memory Keeper + Chat History Recorder
- ✅ Creates backup before making changes
- ✅ Preserves disabled flags
- ✅ Updates metadata flags

**Output**: Interactive fix with backup creation

**Use this to fix Guardrail configuration issues.**

---

### 4. MCP Health Check (All Servers)

**Location**: `tools/mcp_lifecycle_tools/mcp-manage.sh`

**Usage**:
```bash
make mcp-health
```

**What it checks**:
- All MCP servers (not just Conscious Stack)
- General health across the entire MCP system

**Use this for system-wide MCP health checks.**

---

## Comparison: New vs Existing Tools

### My Simple Diagnostic Script
**Location**: `diagnose_guardrail.sh` (in this directory)

**What it does**:
- Basic configuration checks
- Rule file validation
- Environment variable checks
- Process checks
- Log file checks

**Limitations**:
- Less comprehensive than `conscious_stack_health.sh`
- Doesn't check database accessibility
- Doesn't verify process relationships in detail
- Doesn't check tool forwarding

### Existing Comprehensive Tools ⭐

**`conscious_stack_health.sh`** is **MUCH better** because it:
- ✅ Checks everything my script does AND MORE
- ✅ Validates database accessibility
- ✅ Verifies process relationships
- ✅ Checks tool configuration
- ✅ Provides actionable recommendations
- ✅ Color-coded output with clear status
- ✅ Integrated with Makefile (`make conscious-stack-health`)

---

## Recommended Troubleshooting Workflow

### Step 1: Run Comprehensive Health Check
```bash
cd /Users/a805120/develop/workflows
make conscious-stack-health
```

This will show you:
- What's working ✅
- What's broken ❌
- What needs attention ⚠️

### Step 2: If Guardrail Issues Found, Fix Configuration
```bash
make conscious-stack-fix-guardrail
```

This will:
- Detect configuration issues
- Fix wrapping problems
- Create backups
- Preserve your settings

### Step 3: Test Tool Availability
```bash
bash /Users/a805120/develop/workflows/scripts/test_guardrail_tools.sh
```

This will verify:
- Tools are being forwarded correctly
- Expected tool counts
- Process relationships

### Step 4: Restart Cursor
After fixes, restart Cursor to apply changes:
1. Fully quit Cursor (Cmd+Q)
2. Restart Cursor
3. Run health check again to verify

---

## Key Files for Reference

### Troubleshooting Scripts
- **`conscious_stack_health.sh`** - ⭐ **BEST** - Comprehensive health check
- **`test_guardrail_tools.sh`** - Tool availability testing
- **`fix_mcp_guardrail.sh`** - Configuration fix script

### Documentation
- **`CONSCIOUS_STACK_MAINTENANCE.md`** - Maintenance guide
- **`guardrail_fix_status_report.md`** - Status reports
- **`guardrail_tool_verification_results.md`** - Tool verification results

### Makefile Targets
- `make conscious-stack-health` - Run health check
- `make conscious-stack-fix-guardrail` - Fix Guardrail config
- `make mcp-health` - System-wide MCP health

---

## For Rule Enforcement Issues

The tools above check **configuration and health**, but for **rule enforcement** issues (detection vs blocking), you'll need to:

1. **Check guardrail logs**:
   ```bash
   tail -f ~/.mcp/rule-logs/*.log
   tail -f ~/Library/Logs/Claude/mcp-server-MCP\ Guardrail.log
   ```

2. **Verify rule files are loaded**:
   ```bash
   ls -la ~/.mcp/rules/
   cat ~/.mcp/rules/*.json | jq .
   ```

3. **Test with known violations** (as documented in troubleshooting guide)

4. **Check if guardrail has blocking mode** (may need to review guardrail source code)

---

## Recommendation

**Use `conscious_stack_health.sh` instead of my simple diagnostic script.**

It's:
- ✅ More comprehensive
- ✅ Better integrated (Makefile target)
- ✅ More actionable (specific recommendations)
- ✅ Better maintained (part of conscious stack setup)
- ✅ Includes database checks, process relationships, tool verification

My simple `diagnose_guardrail.sh` is good for quick checks, but `conscious_stack_health.sh` is the **production-grade tool** you should use.

---

## Quick Reference Commands

```bash
# Comprehensive health check (BEST)
make conscious-stack-health

# Fix Guardrail configuration
make conscious-stack-fix-guardrail

# Test tool availability
bash /Users/a805120/develop/workflows/scripts/test_guardrail_tools.sh

# Check guardrail logs
tail -f ~/Library/Logs/Claude/mcp-server-MCP\ Guardrail.log

# Check rule logs
tail -f ~/.mcp/rule-logs/*.log

# Check processes
ps aux | grep -E 'mcp-guard|memory-keeper|chat-history'
```

