# YAML Template Feature - Quick Guide

## Overview

The script now generates **ready-to-paste YAML blocks** for missing AD groups, making it easy to update your `sso_groups.yaml` configuration file.

---

## Quick Usage

```bash
# Generate YAML template for missing groups
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template missing_groups.yaml
```

---

## What It Does

Instead of manually creating YAML entries for each missing group, the tool automatically generates properly formatted blocks:

### Input (CSV)
```csv
AccountName,AccountID,ADGroupName
database-sandbox,941677815499,App-AWS-AA-database-sandbox-941677815499-admin
db2dataconnect-dev,856315922280,App-AWS-AA-db2dataconnect-dev-856315922280-admin
```

### Output (YAML Template)
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

---

## Complete Workflow

### 1. Check for Missing Groups
```bash
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

**Output:**
```
Missing Groups: 6
--------------------------------------------------------------------------------
  - App-AWS-AA-database-sandbox-941677815499-admin
  - App-AWS-AA-db2dataconnect-dev-856315922280-admin
  ...
```

### 2. Generate YAML Template
```bash
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml \
  --yaml-template to_add.yaml
```

**Output:**
```
YAML template written to: to_add.yaml
```

### 3. Edit the Template
Open `to_add.yaml` and replace `RI____` with actual ServiceNow RITM numbers:

```yaml
- group_name: App-AWS-AA-database-sandbox-941677815499-admin
  snow_item: RITM0123456  # ← Update this
  account_id: "941677815499"
  scope: account
  permission_set: admin
  description: admin access to a single account
```

### 4. Copy to sso_groups.yaml
Copy the YAML blocks from `to_add.yaml` and paste them into `sso_groups.yaml`.

### 5. Verify
```bash
python compare_ad_groups.py \
  --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml
```

**Expected output:**
```
✓ All CSV groups are present in YAML
```

---

## Template Format

Each generated block follows this structure:

```yaml
- group_name: App-AWS-AA-${AccountName}-${AccountID}-admin
  snow_item: RI____
  account_id: "${AccountID}"
  scope: account
  permission_set: admin
  description: admin access to a single account
```

### Field Descriptions

| Field | Value | Notes |
|-------|-------|-------|
| `group_name` | Full AD group name | Extracted from CSV |
| `snow_item` | `RI____` | **YOU MUST UPDATE THIS** with actual RITM number |
| `account_id` | AWS Account ID | Extracted from CSV or parsed from group name |
| `scope` | `account` | Fixed value for account-level access |
| `permission_set` | `admin` | Default value (can be changed if needed) |
| `description` | Standard text | Default description |

---

## Command Options

```bash
# Save to file
python compare_ad_groups.py \
  --yaml /path/to/sso_groups.yaml \
  --yaml-template output.yaml

# Output to stdout (for piping)
python compare_ad_groups.py \
  --yaml /path/to/sso_groups.yaml \
  --yaml-template /dev/stdout

# With custom CSV
python compare_ad_groups.py \
  --csv custom_groups.csv \
  --yaml /path/to/sso_groups.yaml \
  --yaml-template output.yaml
```

---

## Python API

```python
from compare_ad_groups import find_missing_groups, generate_yaml_template, write_yaml_template
from pathlib import Path

# Find missing groups
result = find_missing_groups(
    'aws_recent.csv',
    '/Users/a805120/develop/aws-access/conf/sso_groups.yaml'
)

# Generate template as string
yaml_content = generate_yaml_template(result)
print(yaml_content)

# Or write directly to file
write_yaml_template(result, Path('missing_groups.yaml'))
```

---

## Automation Example

```bash
#!/bin/bash
# Daily check for missing groups

YAML_PATH="/Users/a805120/develop/aws-access/conf/sso_groups.yaml"
DATE=$(date +%Y%m%d)
OUTPUT_FILE="missing_groups_${DATE}.yaml"

cd /Users/a805120/develop/oneoffs/tools/aft_aws_access
source .venv/bin/activate

# Generate template
python compare_ad_groups.py \
  --yaml "$YAML_PATH" \
  --yaml-template "$OUTPUT_FILE"

if [ -s "$OUTPUT_FILE" ]; then
    echo "✓ Missing groups found! Template generated: $OUTPUT_FILE"
    echo "  Next steps:"
    echo "    1. Edit $OUTPUT_FILE to add RITM numbers"
    echo "    2. Copy blocks to sso_groups.yaml"
    echo "    3. Commit and push changes"
else
    echo "✓ No missing groups - all synchronized!"
    rm -f "$OUTPUT_FILE"
fi
```

---

## Three Output Modes Comparison

| Mode | Flag | Purpose | Output |
|------|------|---------|--------|
| **Text** | (default) | Human-readable report | Statistics + list of missing groups |
| **JSON** | `--json` | Machine-readable data | Structured JSON for automation |
| **YAML Template** | `--yaml-template` | Ready-to-use config blocks | YAML blocks to paste into sso_groups.yaml |

### Use Text when:
- You want a quick visual check
- Generating reports for humans

### Use JSON when:
- Integrating with other tools/scripts
- Need programmatic processing
- Storing results in databases

### Use YAML Template when:
- You need to add missing groups to sso_groups.yaml
- Want to save time on manual formatting
- Ensuring consistent YAML structure

---

## Important Notes

⚠️ **Always update RITM numbers**: The template uses `RI____` as a placeholder. You MUST replace this with actual ServiceNow RITM numbers before adding to production config.

✅ **Template is ready-to-use**: All other fields are automatically populated from the CSV data.

✅ **Maintains consistency**: All blocks follow the same format as existing entries in sso_groups.yaml.

✅ **No manual typing needed**: Copy-paste the blocks directly after updating RITM numbers.

---

## Troubleshooting

### Template is empty
- Check that there are actually missing groups
- Verify CSV file contains AccountID column
- Run without `--yaml-template` first to see missing groups

### Account ID is blank
- Ensure CSV has AccountID column
- Tool will try to parse from group name if CSV data is missing
- Group name must follow pattern: `App-AWS-AA-{name}-{12-digit-id}-{permission}`

### Permission set is wrong
- Template defaults to `admin`
- Edit the generated YAML file to change permission_set if needed
- Common values: `admin`, `reader`, `viewer`, `finops`

---

## See Also

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - All commands and usage examples
- [README.md](README.md) - Complete documentation
- [GET_STARTED.md](GET_STARTED.md) - Quick setup guide

---

**Feature Added**: 2024  
**Compatible with**: Python 3.9+  
**Dependencies**: PyYAML >= 6.0.1