# Find and Grep Patterns

## Problem: Find Command Issues

### Issue Encountered (2025-01-27)
**Problem**: `find` command failing with warnings about global options and directory separators
**Command that failed**:
```bash
find /Users/a805120/develop/workflows -name "*.md" -exec grep -l -i "chrome.*mcp\|browser.*mcp\|chrome.*automation\|browser.*automation" {} \;
```

**Error messages**:
```
find: warning: '-name' matches against basenames only, but the given pattern contains a directory separator ('/'), thus the expression will evaluate to false all the time. Did you mean '-wholename'?
find: warning: you have specified the global option -maxdepth after the argument -name, but global options are not positional, i.e., -maxdepth affects tests specified before it as well as those specified after it. Please specify global options before other arguments.
```

## Solution: Use Grep Instead

### Recommended Pattern
```bash
# Search for patterns in specific file types (RECOMMENDED)
grep -r -l -i "pattern" . --include="*.ext"
```

### Working Example
```bash
# Search for Chrome MCP references in markdown files
grep -r -l -i "chrome.*mcp\|browser.*mcp\|chrome.*automation\|browser.*automation" . --include="*.md"
```

**Results**: Successfully found 5 files containing Chrome/browser MCP automation references

## Best Practices

### Text Search Patterns
```bash
# Basic recursive search
grep -r "pattern" .

# Case-insensitive search
grep -r -i "pattern" .

# List files containing pattern
grep -r -l "pattern" .

# Search specific file types
grep -r "pattern" . --include="*.ext"

# Exclude certain files/directories
grep -r "pattern" . --exclude="*.log" --exclude-dir="node_modules"
```

### Find Command Patterns (When Needed)
```bash
# Find files by extension
find . -type f -name "*.ext"

# Find directories
find . -type d -name "pattern"

# Find with max depth
find . -maxdepth 2 -type f -name "*.ext"

# Find and execute (use sparingly)
find . -name "*.ext" -exec command {} \;
```

## Common Pitfalls

1. **Avoid `find -exec grep`** - Use `grep -r` instead
2. **Global options first** - Put `-maxdepth`, `-type` before `-name` in find
3. **Test simple patterns first** - Verify basic syntax before complex patterns
4. **Use `--include`** - More reliable than `find` for file type filtering

## Tool Selection Guide

| Task | Recommended Tool | Command Pattern |
|------|------------------|-----------------|
| Search text in files | `grep` | `grep -r -l "pattern" . --include="*.ext"` |
| Find files by name | `find` | `find . -type f -name "*.ext"` |
| Find directories | `find` | `find . -type d -name "pattern"` |
| Complex file operations | `find` | `find . -name "*.ext" -exec command {} \;` |

## Last Updated
2025-01-27 - Initial creation with find/grep troubleshooting learnings
