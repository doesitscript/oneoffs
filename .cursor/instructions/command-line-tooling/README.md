# Command Line Tooling Master Reference

This directory contains organized learnings and best practices for command-line tools encountered during development work.

## Directory Structure

- `find-grep-patterns.md` - Search and discovery patterns
- `git-command-patterns.md` - Git operations and workflows
- `file-system-operations.md` - File/directory operations
- `troubleshooting-log.md` - Common issues and solutions
- `tool-specific-guides/` - Specific tool documentation

## Quick Reference

### Text Search Patterns
```bash
# Search for patterns in specific file types (RECOMMENDED)
grep -r -l -i "pattern" . --include="*.ext"

# Instead of problematic find -exec grep
find . -name "*.ext" -exec grep -l "pattern" {} \;  # AVOID
```

### File Discovery
```bash
# Find files by extension
find . -type f -name "*.ext"

# Find directories
find . -type d -name "pattern"
```

### Process Management
```bash
# Check running processes
ps aux | grep -v grep | grep "process_name"

# Kill processes
pkill -f "process_pattern"
```

## Learning Philosophy

- **Document issues immediately** when troubleshooting
- **Create reusable patterns** for similar tasks
- **Reference previous solutions** before reinventing
- **Test commands** before using in complex workflows

## Last Updated
2025-01-27 - Initial creation with find/grep troubleshooting learnings
