# Quick Reference Card

**AFT AWS Access Tools - Command Reference**

---

## Installation (One-Time Setup)

```bash
cd /Users/a805120/develop/oneoffs/tools/aft_aws_acess
./setup.sh
source .venv/bin/activate
```

---

## Basic Usage

### Command Line

```bash
# Activate virtual environment first
source .venv/bin/activate

# Basic comparison (using default paths)
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml

# With custom CSV file
python compare_ad_groups.py \
  --csv my_groups.csv \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml

# JSON output
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --json

# Save to file
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --output report.txt

# JSON to file
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --json \
  --output results.json

# Using installed command
compare-ad-groups --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

---

## Python Module Usage

```python
from compare_ad_groups import find_missing_groups

# Compare groups
result = find_missing_groups(
    'aws_recent.csv',
    '/Users/a805120/develop/aws-access/conf/sso_groups.yaml'
)

# Check results
if result.has_missing_groups:
    print(f"Found {result.missing_count} missing groups:")
    for group in result.missing_groups:
        print(f"  - {group}")
else:
    print("✓ All groups synchronized!")

# Get statistics
print(f"CSV groups: {len(result.csv_groups)}")
print(f"YAML groups: {len(result.yaml_groups)}")

# Export to JSON
import json
data = result.to_dict()
print(json.dumps(data, indent=2))
```

---

## Common Workflows

### 1. Quick Check
```bash
source .venv/bin/activate
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

### 2. Generate Report
```bash
source .venv/bin/activate
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --output "report_$(date +%Y%m%d).txt"
```

### 3. Automation Script
```bash
#!/bin/bash
cd /Users/a805120/develop/oneoffs/tools/aft_aws_acess
source .venv/bin/activate

python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --json \
  --output results.json

# Process results
if [ $? -eq 1 ]; then
    echo "Missing groups found! Check results.json"
else
    echo "All groups synchronized"
fi
```

### 4. Integration Example
```python
#!/usr/bin/env python3
import sys
from pathlib import Path
from compare_ad_groups import find_missing_groups

def check_groups():
    result = find_missing_groups(
        'aws_recent.csv',
        '/Users/a805120/develop/aws-access/conf/sso_groups.yaml'
    )
    
    if result.has_missing_groups:
        print(f"⚠️  {result.missing_count} groups need attention:")
        for group in result.missing_groups:
            print(f"  - {group}")
        
        # Save report
        from compare_ad_groups import write_results
        write_results(result, Path('missing_groups.txt'))
        
        return 1
    else:
        print("✓ All groups synchronized")
        return 0

if __name__ == '__main__':
    sys.exit(check_groups())
```

---

## Make Commands

```bash
make help         # Show all available commands
make setup        # Initial setup
make run          # Run with default settings
make run-json     # Run with JSON output
make example      # Run example usage script
make clean        # Remove generated files
```

---

## File Paths

### Default Locations
- **CSV**: `./aws_recent.csv` (current directory)
- **YAML**: `../aws-access/conf/sso_groups.yaml` (relative path)

### Actual YAML Location
- Full path: `/Users/a805120/develop/aws-access/conf/sso_groups.yaml`

### Always specify the full YAML path when running:
```bash
--yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

---

## Output Formats

### Text Format (Default)
```
================================================================================
AD Group Comparison Report
================================================================================
CSV Source: aws_recent.csv
YAML Source: /Users/a805120/develop/aws-access/conf/sso_groups.yaml
Total CSV Groups: 7
Total YAML Groups: 61
Missing Groups: 7
================================================================================

Groups in CSV but NOT in YAML:
--------------------------------------------------------------------------------
  - App-AWS-AA-database-sandbox-941677815499-admin
  - App-AWS-AA-db2dataconnect-dev-856315922280-admin
  ...
```

### JSON Format (with --json)
```json
{
  "missing_groups": [
    "App-AWS-AA-database-sandbox-941677815499-admin",
    "App-AWS-AA-db2dataconnect-dev-856315922280-admin"
  ],
  "missing_count": 7,
  "total_csv_groups": 7,
  "total_yaml_groups": 61,
  "csv_path": "aws_recent.csv",
  "yaml_path": "/Users/a805120/develop/aws-access/conf/sso_groups.yaml"
}
```

---

## Exit Codes

- **0**: Success, no missing groups
- **1**: Missing groups found OR error occurred

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'yaml'"
```bash
source .venv/bin/activate
uv pip install pyyaml
```

### "FileNotFoundError: CSV file not found"
```bash
# Make sure you're in the project directory
cd /Users/a805120/develop/oneoffs/tools/aft_aws_acess
ls -l aws_recent.csv
```

### "FileNotFoundError: YAML file not found"
```bash
# Always use full path for YAML
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

### Virtual environment not activated
```bash
# Activate it
source .venv/bin/activate

# Verify
which python
# Should show: /Users/a805120/develop/oneoffs/tools/aft_aws_acess/.venv/bin/python
```

---

## Quick Tips

✅ **Always activate venv first**: `source .venv/bin/activate`
✅ **Use full YAML path**: `/Users/a805120/develop/aws-access/conf/sso_groups.yaml`
✅ **Check exit code**: `$?` in bash (0 = success, 1 = missing groups)
✅ **JSON for automation**: Use `--json` for programmatic processing
✅ **Save reports**: Use `--output` to save results

---

**For more help**: `python compare_ad_groups.py --help`
