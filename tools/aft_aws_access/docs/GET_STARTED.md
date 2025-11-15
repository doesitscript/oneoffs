# Get Started in 60 Seconds

## Quick Setup

```bash
# 1. Navigate to the project
cd /Users/a805120/develop/oneoffs/tools/aft_aws_access

# 2. Run setup (installs everything)
./setup.sh

# 3. Activate virtual environment
source .venv/bin/activate

# 4. Run the comparison
python compare_ad_groups.py
```

## What It Does

Compares AD groups from `aws_recent.csv` against `sso_groups.yaml` and shows which groups are missing.

## Example Output

```
================================================================================
AD Group Comparison Report
================================================================================
CSV Source: aws_recent.csv
YAML Source: ../aws-access/conf/sso_groups.yaml
Total CSV Groups: 6
Total YAML Groups: 89
Missing Groups: 6
================================================================================

Groups in CSV but NOT in YAML:
--------------------------------------------------------------------------------
  - App-AWS-AA-database-sandbox-941677815499-admin
  - App-AWS-AA-db2dataconnect-dev-856315922280-admin
  - App-AWS-AA-db2dataconnect-prd-619038613613-admin
  - App-AWS-AA-sectigo-dev-525388274604-admin
  - App-AWS-AA-sectigo-qa-396183525533-admin
  - App-AWS-AA-varonis-prd-475936984843-admin
```

## Common Commands

```bash
# Default comparison
python compare_ad_groups.py

# Save to file
python compare_ad_groups.py --output report.txt

# JSON output
python compare_ad_groups.py --json

# Custom paths
python compare_ad_groups.py --csv myfile.csv --yaml myconfig.yaml

# Get help
python compare_ad_groups.py --help
```

## Use in Python

```python
from compare_ad_groups import find_missing_groups

# Compare files
result = find_missing_groups('aws_recent.csv', '../aws-access/conf/sso_groups.yaml')

# Check results
if result.has_missing_groups:
    print(f"Found {result.missing_count} missing groups:")
    for group in result.missing_groups:
        print(f"  - {group}")
else:
    print("✓ All groups synchronized!")
```

## Make Commands

```bash
make help         # Show all commands
make run          # Run comparison
make run-json     # JSON output
make example      # See 7 usage examples
make clean        # Clean up files
```

## Files You Need

1. **aws_recent.csv** - Your CSV with AD groups (must have `ADGroupName` column)
2. **sso_groups.yaml** - YAML config with SSO groups (must have `group_name` field)

## Next Steps

- **Quick Tutorial**: See [QUICKSTART.md](QUICKSTART.md)
- **Full Docs**: See [README.md](README.md)
- **Examples**: Run `python example_usage.py`
- **Install Help**: See [INSTALL.md](INSTALL.md)

## Troubleshooting

**Virtual environment not working?**
```bash
deactivate
uv venv
source .venv/bin/activate
uv pip install -e .
```

**Missing dependencies?**
```bash
source .venv/bin/activate
uv pip install -e .
```

**Files not found?**
```bash
# Check you're in the right directory
pwd
# Should show: /Users/a805120/develop/oneoffs/tools/aft_aws_access

# Verify files exist
ls -l aws_recent.csv
ls -l ../aws-access/conf/sso_groups.yaml
```

---

**That's it! You're ready to compare AD groups.** 🚀

For detailed help: `python compare_ad_groups.py --help`
