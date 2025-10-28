# File System Operations

## File Discovery Patterns

### Find Files by Extension
```bash
# Find all markdown files
find . -type f -name "*.md"

# Find all JavaScript files
find . -type f -name "*.js"

# Find all configuration files
find . -type f \( -name "*.json" -o -name "*.yaml" -o -name "*.yml" \)
```

### Find Directories
```bash
# Find directories by name
find . -type d -name "node_modules"
find . -type d -name "src"
find . -type d -name "config"
```

### Find with Constraints
```bash
# Find files in current directory only
find . -maxdepth 1 -type f -name "*.md"

# Find files modified in last 7 days
find . -type f -mtime -7

# Find files larger than 1MB
find . -type f -size +1M
```

## File Operations

### Copy Operations
```bash
# Copy files preserving structure
cp -r source/ destination/

# Copy with progress
rsync -avh --progress source/ destination/
```

### Move Operations
```bash
# Move files
mv old_name new_name

# Move directories
mv old_dir/ new_dir/
```

### Delete Operations
```bash
# Remove files
rm filename

# Remove directories recursively
rm -rf directory/

# Remove with confirmation
rm -i filename
```

## Directory Operations

### Create Directories
```bash
# Create single directory
mkdir directory_name

# Create nested directories
mkdir -p path/to/nested/directory

# Create multiple directories
mkdir dir1 dir2 dir3
```

### List Directory Contents
```bash
# List files with details
ls -la

# List only directories
ls -d */

# List files by modification time
ls -lt

# List files recursively
ls -R
```

## File Information

### File Properties
```bash
# Show file information
stat filename

# Show file type
file filename

# Show file size
du -h filename

# Show disk usage
du -sh directory/
```

### File Content Operations
```bash
# View file content
cat filename

# View first/last lines
head -n 10 filename
tail -n 10 filename

# Count lines, words, characters
wc filename
```

## Best Practices

1. **Always test destructive operations** (`rm`, `mv`) on copies first
2. **Use `-i` flag** for interactive confirmation on destructive operations
3. **Use `rsync`** for large file operations with progress
4. **Use `find`** for complex file discovery patterns
5. **Use `grep -r`** for text searching instead of `find -exec grep`

## Last Updated
2025-01-27 - Initial creation
