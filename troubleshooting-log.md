# Troubleshooting Log

## 2025-01-27: Find Command Issues

### Problem
- **Tool**: `find` command with `-exec grep`
- **Error**: Global options warnings and directory separator issues
- **Context**: Searching for Chrome MCP references in markdown files

### Root Cause
1. `find` global options (`-maxdepth`, `-type`) must come before other arguments
2. `find -exec grep` pattern is problematic and inefficient
3. `grep -r` is more reliable for text searching

### Solution Applied
```bash
# Instead of:
find /path -name "*.md" -exec grep -l "pattern" {} \;

# Use:
grep -r -l -i "pattern" . --include="*.md"
```

### Results
- Successfully found 5 markdown files with Chrome MCP references
- No more find command warnings
- More efficient execution

### Prevention
- Always use `grep -r` for text searching
- Test simple patterns before complex ones
- Document working patterns for reuse

## Future Troubleshooting Template

### Problem
- **Tool**: [tool name]
- **Error**: [error message]
- **Context**: [what we were trying to do]

### Root Cause
- [analysis of why it failed]

### Solution Applied
```bash
# Working command
```

### Results
- [what worked]

### Prevention
- [how to avoid this in future]
