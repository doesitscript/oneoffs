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

# ⭐ NEW: Generate YAML template for missing groups
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template missing_groups.yaml

# Using installed command
compare-ad-groups --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

---

## YAML Template Output (NEW!)

### Generate YAML blocks ready to copy into sso_groups.yaml

```bash
# Save to file
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template missing_groups_template.yaml

# Output to stdout
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template /dev/stdout
```

### Example Output Format

```yaml
- group_name: App-AWS-AA-database-sandbox-941677815499-admin
  snow_item: RI____
  account_id: "941677815499"
  scope: account
  permission_set: admin
  description: admin access to a single account

- group_name: App-AWS-AA-db2dataconnect-dev-856315922280-admin
  snow_item: RI____
  account_id: "856315922280"
  scope: account
  permission_set: admin
  description: admin access to a single account
```

**Note:** You'll need to fill in the `snow_item` field (replace `RI____` with actual RITM number).

---

## Python Module Usage

```python
from compare_ad_groups import find_missing_groups, generate_yaml_template

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

# Generate YAML template
if result.has_missing_groups:
    yaml_template = generate_yaml_template(result)
    print(yaml_template)
    
    # Or save to file
    from pathlib import Path
    Path('missing_groups.yaml').write_text(yaml_template)

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

### 2. Generate YAML Template for Missing Groups
```bash
source .venv/bin/activate
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template missing_groups.yaml

# Then edit missing_groups.yaml to add RITM numbers
# Copy contents to sso_groups.yaml
```

### 3. Generate Report
```bash
source .venv/bin/activate
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --output "report_$(date +%Y%m%d).txt"
```

### 4. Automation Script
```bash
#!/bin/bash
cd /Users/a805120/develop/oneoffs/tools/aft_aws_acess
source .venv/bin/activate

# Generate YAML template if missing groups found
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template missing_groups_$(date +%Y%m%d).yaml

# Also get JSON for processing
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --json \
  --output results.json

# Process results
if [ $? -eq 1 ]; then
    echo "Missing groups found! Check missing_groups_*.yaml"
    echo "Don't forget to update RITM numbers!"
else
    echo "All groups synchronized"
fi
```

### 5. Complete Workflow
```bash
# 1. Check for missing groups
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml

# 2. Generate YAML template
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template to_add.yaml

# 3. Edit to_add.yaml - replace RI____ with actual RITM numbers

# 4. Copy blocks from to_add.yaml to sso_groups.yaml

# 5. Verify
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

### 6. Integration Example
```python
#!/usr/bin/env python3
import sys
from pathlib import Path
from compare_ad_groups import find_missing_groups, write_yaml_template

def check_and_generate_template():
    result = find_missing_groups(
        'aws_recent.csv',
        '/Users/a805120/develop/aws-access/conf/sso_groups.yaml'
    )
    
    if result.has_missing_groups:
        print(f"⚠️  {result.missing_count} groups need attention:")
        for group in result.missing_groups:
            print(f"  - {group}")
        
        # Generate YAML template
        template_path = Path('missing_groups_template.yaml')
        write_yaml_template(result, template_path)
        print(f"\n✓ YAML template generated: {template_path}")
        print("  Next steps:")
        print("    1. Edit the file to add RITM numbers (replace RI____)")
        print("    2. Copy the blocks to sso_groups.yaml")
        
        return 1
    else:
        print("✓ All groups synchronized")
        return 0

if __name__ == '__main__':
    sys.exit(check_and_generate_template())
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

## Command-Line Options

```
Usage: compare_ad_groups.py [-h] [--csv CSV] [--yaml YAML] [--output OUTPUT] 
                           [--json] [--yaml-template YAML_TEMPLATE]

Options:
  --csv CSV                    Path to CSV file with AD groups
  --yaml YAML                  Path to YAML file with SSO groups
  --output OUTPUT              Output file for text/JSON results
  --json                       Output results as JSON
  --yaml-template FILE         Generate YAML template for missing groups
  -h, --help                   Show help message
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

### 1. Text Format (Default)
```
================================================================================
AD Group Comparison Report
================================================================================
CSV Source: aws_recent.csv
YAML Source: /Users/a805120/develop/aws-access/conf/sso_groups.yaml
Total CSV Groups: 6
Total YAML Groups: 61
Missing Groups: 6
================================================================================

Groups in CSV but NOT in YAML:
--------------------------------------------------------------------------------
  - App-AWS-AA-database-sandbox-941677815499-admin
  - App-AWS-AA-db2dataconnect-dev-856315922280-admin
  ...
```

### 2. JSON Format (with --json)
```json
{
  "missing_groups": [
    "App-AWS-AA-database-sandbox-941677815499-admin",
    "App-AWS-AA-db2dataconnect-dev-856315922280-admin"
  ],
  "missing_count": 6,
  "total_csv_groups": 6,
  "total_yaml_groups": 61,
  "csv_path": "aws_recent.csv",
  "yaml_path": "/Users/a805120/develop/aws-access/conf/sso_groups.yaml"
}
```

### 3. YAML Template Format (with --yaml-template) ⭐ NEW
```yaml
- group_name: App-AWS-AA-database-sandbox-941677815499-admin
  snow_item: RI____
  account_id: "941677815499"
  scope: account
  permission_set: admin
  description: admin access to a single account

- group_name: App-AWS-AA-db2dataconnect-dev-856315922280-admin
  snow_item: RI____
  account_id: "856315922280"
  scope: account
  permission_set: admin
  description: admin access to a single account
```

**Remember to update `snow_item` before adding to sso_groups.yaml!**

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
✅ **YAML template for easy updates**: Use `--yaml-template` to generate ready-to-use blocks
✅ **Don't forget RITM numbers**: Replace `RI____` with actual ServiceNow RITM numbers
✅ **Save reports**: Use `--output` to save results

---

## Best Practice Workflow

1. **Detect missing groups:**
   ```bash
   python compare_ad_groups.py --yaml /path/to/sso_groups.yaml
   ```

2. **Generate YAML template:**
   ```bash
   python compare_ad_groups.py --yaml /path/to/sso_groups.yaml \
     --yaml-template missing_groups.yaml
   ```

3. **Edit template:**
   - Open `missing_groups.yaml`
   - Replace `RI____` with actual RITM numbers

4. **Add to sso_groups.yaml:**
   - Copy the blocks from `missing_groups.yaml`
   - Paste into `sso_groups.yaml`

5. **Verify:**
   ```bash
   python compare_ad_groups.py --yaml /path/to/sso_groups.yaml
   ```
   Should show: "✓ All CSV groups are present in YAML"

---

**For more help**: `python compare_ad_groups.py --help`
