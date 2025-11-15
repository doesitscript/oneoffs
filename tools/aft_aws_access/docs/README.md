# AFT AWS Access Tools

A Python module for comparing AWS AD group names from CSV exports against SSO group configurations in YAML format.

## Features

- 🔍 Compare AD groups from CSV against YAML configuration
- 📊 Detailed reporting of missing groups
- 🔌 Use as a standalone script or importable module
- 📝 JSON and text output formats
- ✅ Type hints and comprehensive error handling
- 🧪 Designed for integration with other Python projects

## Installation

### Using uv (Recommended)

1. Install uv if you haven't already:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2. Create a virtual environment and install dependencies:
```bash
cd aft_aws_access
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
uv pip install -e .
```

### Using pip

```bash
cd aft_aws_access
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -e .
```

## Usage

### As a Command-Line Script

#### Basic usage (uses default paths):
```bash
python compare_ad_groups.py
```

#### Specify custom file paths:
```bash
python compare_ad_groups.py \
  --csv aws_recent.csv \
  --yaml ../aws-access/conf/sso_groups.yaml
```

#### Save output to a file:
```bash
python compare_ad_groups.py --output results.txt
```

#### Output as JSON:
```bash
python compare_ad_groups.py --json
python compare_ad_groups.py --json --output results.json
```

#### Using the installed command:
```bash
compare-ad-groups --help
```

### As a Python Module

```python
from compare_ad_groups import find_missing_groups, ComparisonResult

# Find missing groups
result = find_missing_groups('aws_recent.csv', 'sso_groups.yaml')

# Check if there are missing groups
if result.has_missing_groups:
    print(f"Found {result.missing_count} missing groups:")
    for group in result.missing_groups:
        print(f"  - {group}")
else:
    print("All groups are present!")

# Access detailed information
print(f"Total CSV groups: {len(result.csv_groups)}")
print(f"Total YAML groups: {len(result.yaml_groups)}")

# Convert to dictionary (useful for serialization)
data = result.to_dict()
```

### Advanced Usage Examples

#### Integration with other scripts:
```python
from pathlib import Path
from compare_ad_groups import find_missing_groups, write_results

def generate_report():
    csv_path = Path("data/aws_recent.csv")
    yaml_path = Path("config/sso_groups.yaml")
    
    result = find_missing_groups(csv_path, yaml_path)
    
    # Write to file
    write_results(result, Path("reports/missing_groups.txt"))
    
    # Return for further processing
    return result.missing_groups

missing = generate_report()
```

#### Automated workflow with error handling:
```python
from compare_ad_groups import find_missing_groups

try:
    result = find_missing_groups(
        csv_path="exports/current.csv",
        yaml_path="configs/production.yaml"
    )
    
    if result.has_missing_groups:
        # Send alert, create ticket, etc.
        notify_team(result.missing_groups)
        
except FileNotFoundError as e:
    print(f"File not found: {e}")
except ValueError as e:
    print(f"Invalid file format: {e}")
```

## File Format Requirements

### CSV Format (aws_recent.csv)
The CSV file must contain an `ADGroupName` column:

```csv
AccountName,AccountID,ADGroupName
varonis-prd,475936984843,App-AWS-AA-varonis-prd-475936984843-admin
db2dataconnect-dev,856315922280,App-AWS-AA-db2dataconnect-dev-856315922280-admin
```

### YAML Format (sso_groups.yaml)
The YAML file should contain a list of group configurations with `group_name` keys:

```yaml
- group_name: App-AWS-global-admin
  snow_item: RITM0214893
  scope: global
  permission_set: admin
  description: global admin access

- group_name: App-AWS-AA-varonis-prd-475936984843-admin
  snow_item: RITM1234567
  account_id: "475936984843"
  scope: account
  permission_set: admin
  description: admin access to a single account
```

## API Reference

### Functions

#### `find_missing_groups(csv_path, yaml_path) -> ComparisonResult`
Main function to compare groups.

**Parameters:**
- `csv_path` (str | Path): Path to CSV file with AD groups
- `yaml_path` (str | Path): Path to YAML file with SSO groups

**Returns:**
- `ComparisonResult`: Object containing comparison results

**Raises:**
- `FileNotFoundError`: If either file doesn't exist
- `ValueError`: If file format is invalid

#### `load_csv_groups(csv_path) -> Set[str]`
Load AD group names from CSV file.

#### `load_yaml_groups(yaml_path) -> Set[str]`
Load group names from YAML configuration.

#### `write_results(result, output_path=None) -> None`
Write comparison results to file or stdout.

### Classes

#### `ComparisonResult`
Dataclass containing comparison results.

**Attributes:**
- `missing_groups` (List[str]): Groups in CSV but not in YAML
- `csv_groups` (Set[str]): All groups from CSV
- `yaml_groups` (Set[str]): All groups from YAML
- `csv_path` (Optional[Path]): Path to CSV file
- `yaml_path` (Optional[Path]): Path to YAML file

**Properties:**
- `has_missing_groups` (bool): Whether any groups are missing
- `missing_count` (int): Number of missing groups

**Methods:**
- `to_dict()` -> dict: Convert result to dictionary

## Development

### Install development dependencies:
```bash
uv pip install -e ".[dev]"
```

### Run tests:
```bash
pytest
```

### Run linting:
```bash
ruff check .
black --check .
mypy compare_ad_groups.py
```

### Format code:
```bash
black .
ruff check --fix .
```

## Exit Codes

When used as a CLI script:
- `0`: Success, no missing groups found
- `1`: Missing groups found or error occurred

## License

Internal use only.

## Contributing

For questions or improvements, please contact the AWS Infrastructure team.