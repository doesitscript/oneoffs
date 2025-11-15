# Quick Start Guide

Get up and running with AFT AWS Access Tools in 5 minutes.

## Prerequisites

- Python 3.9 or higher
- Access to the CSV and YAML files

## Installation

### Option 1: Automated Setup (Recommended)

```bash
cd aft_aws_access
chmod +x setup.sh
./setup.sh
```

The script will:
- Install `uv` if not present
- Create a virtual environment
- Install all dependencies
- Verify the installation

### Option 2: Manual Setup

```bash
cd aft_aws_access

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create virtual environment
uv venv

# Activate virtual environment
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
uv pip install -e .
```

## Quick Usage

### 1. Run with default settings

```bash
# Make sure you're in the aft_aws_access directory
cd aft_aws_access

# Activate virtual environment if not already active
source .venv/bin/activate

# Run the script
python compare_ad_groups.py
```

This will:
- Read `aws_recent.csv` from the current directory
- Read `sso_groups.yaml` from `../aws-access/conf/sso_groups.yaml`
- Display missing groups in the terminal

### 2. Save results to a file

```bash
python compare_ad_groups.py --output missing_groups_report.txt
```

### 3. Get JSON output

```bash
python compare_ad_groups.py --json --output results.json
```

### 4. Use custom file paths

```bash
python compare_ad_groups.py \
  --csv /path/to/your/aws_recent.csv \
  --yaml /path/to/your/sso_groups.yaml
```

## Using as a Python Module

Create a new Python file in your project:

```python
from compare_ad_groups import find_missing_groups

# Compare groups
result = find_missing_groups('aws_recent.csv', '../aws-access/conf/sso_groups.yaml')

# Check results
if result.has_missing_groups:
    print(f"Found {result.missing_count} missing groups:")
    for group in result.missing_groups:
        print(f"  - {group}")
else:
    print("All groups are synchronized!")
```

## Example Output

### Text Format
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

### JSON Format
```json
{
  "missing_groups": [
    "App-AWS-AA-database-sandbox-941677815499-admin",
    "App-AWS-AA-db2dataconnect-dev-856315922280-admin",
    "App-AWS-AA-db2dataconnect-prd-619038613613-admin",
    "App-AWS-AA-sectigo-dev-525388274604-admin",
    "App-AWS-AA-sectigo-qa-396183525533-admin",
    "App-AWS-AA-varonis-prd-475936984843-admin"
  ],
  "missing_count": 6,
  "total_csv_groups": 6,
  "total_yaml_groups": 89,
  "csv_path": "aws_recent.csv",
  "yaml_path": "../aws-access/conf/sso_groups.yaml"
}
```

## Running Examples

```bash
# Run all example use cases
python example_usage.py
```

This will demonstrate:
- Basic usage
- Custom paths
- Individual file loading
- JSON output
- Saving to files
- Conditional processing
- Error handling

## Common Issues

### "Command not found: uv"
Make sure `uv` is in your PATH:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

Or install it:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### "CSV file must contain 'ADGroupName' column"
Verify your CSV has the correct header:
```csv
AccountName,AccountID,ADGroupName
```

### "YAML file must contain a list of group configurations"
Verify your YAML starts with a list:
```yaml
- group_name: App-AWS-global-admin
  # ... other fields
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [example_usage.py](example_usage.py) for integration patterns
- Integrate into your automation workflows

## Help

For detailed help:
```bash
python compare_ad_groups.py --help
```

For questions or issues, contact the AWS Infrastructure team.