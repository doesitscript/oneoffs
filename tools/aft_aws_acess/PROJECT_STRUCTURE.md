# Project Structure

This document provides an overview of the AFT AWS Access Tools project structure and organization.

## Directory Layout

```
aft_aws_acess/
├── README.md                    # Comprehensive documentation
├── QUICKSTART.md               # Quick start guide
├── PROJECT_STRUCTURE.md        # This file
├── pyproject.toml              # Python project configuration and dependencies
├── Makefile                    # Convenient command shortcuts
├── setup.sh                    # Automated setup script
├── .gitignore                  # Git ignore patterns
│
├── compare_ad_groups.py        # Main module - core functionality
├── example_usage.py            # Example usage demonstrations
│
├── aws_recent.csv              # Input: CSV with AD groups (user-provided)
└── .venv/                      # Virtual environment (created during setup)
```

## File Descriptions

### Core Module

**`compare_ad_groups.py`** (291 lines)
- Main Python module containing all comparison logic
- Can be used as a standalone script or imported as a module
- Features:
  - `ComparisonResult` dataclass for structured results
  - `load_csv_groups()` - Parse CSV file
  - `load_yaml_groups()` - Parse YAML file
  - `find_missing_groups()` - Main comparison function
  - `write_results()` - Output formatter
  - `main()` - CLI entry point
- Fully typed with type hints
- Comprehensive error handling
- Command-line argument parsing

### Documentation

**`README.md`** (250 lines)
- Complete project documentation
- Installation instructions (uv and pip)
- Usage examples (CLI and module)
- API reference
- File format requirements
- Development guidelines

**`QUICKSTART.md`** (201 lines)
- Fast-track setup guide
- Common usage patterns
- Example outputs
- Troubleshooting tips
- 5-minute getting started guide

**`PROJECT_STRUCTURE.md`** (This file)
- Project organization overview
- File descriptions
- Architecture notes
- Design decisions

### Configuration

**`pyproject.toml`** (65 lines)
- Python project metadata
- Dependency management (PyYAML)
- Development dependencies (pytest, black, ruff, mypy)
- Entry point configuration (`compare-ad-groups` command)
- Tool configurations (black, ruff, mypy, pytest)
- Build system configuration

**`.gitignore`** (68 lines)
- Python artifacts (__pycache__, *.pyc)
- Virtual environments (.venv/)
- IDE files (.vscode/, .idea/)
- Testing artifacts (.pytest_cache/, .coverage)
- Generated reports (*.txt, *.json)
- Type checking caches (.mypy_cache/)

### Setup & Automation

**`setup.sh`** (102 lines)
- Automated environment setup
- Checks for uv installation
- Creates virtual environment
- Installs dependencies
- Validates installation
- Interactive prompts for dev dependencies

**`Makefile`** (91 lines)
- Common task automation
- Commands:
  - `make setup` - Full setup
  - `make run` - Run comparison
  - `make run-json` - JSON output
  - `make example` - Run examples
  - `make test` - Run tests
  - `make lint` - Code quality checks
  - `make format` - Code formatting
  - `make clean` - Cleanup

### Examples

**`example_usage.py`** (222 lines)
- Demonstrates 7 different usage patterns:
  1. Basic usage
  2. Custom paths
  3. Individual file loading
  4. JSON output
  5. Save to file
  6. Conditional processing
  7. Error handling
- Runnable script for learning and testing

## Data Files

### Input Files

**`aws_recent.csv`** (User-provided)
- Format: CSV with headers
- Required column: `ADGroupName`
- Optional columns: `AccountName`, `AccountID`
- Example:
  ```csv
  AccountName,AccountID,ADGroupName
  varonis-prd,475936984843,App-AWS-AA-varonis-prd-475936984843-admin
  ```

**`../aws-access/conf/sso_groups.yaml`** (External reference)
- Format: YAML list
- Required field: `group_name`
- Optional fields: `snow_item`, `account_id`, `scope`, `permission_set`, `description`
- Example:
  ```yaml
  - group_name: App-AWS-global-admin
    snow_item: RITM0214893
    scope: global
    permission_set: admin
  ```

### Output Files (Generated)

**`missing_groups_report.txt`** (Optional)
- Text format comparison report
- Contains summary and missing groups list
- Generated with `--output` flag

**`missing_groups_report.json`** (Optional)
- JSON format comparison results
- Structured data for programmatic use
- Generated with `--json --output` flags

## Architecture

### Design Principles

1. **Modularity**: Core logic separated from CLI interface
2. **Reusability**: Designed for import by other Python projects
3. **Type Safety**: Full type hints for better IDE support
4. **Error Handling**: Comprehensive exception handling
5. **Documentation**: Extensive inline and external docs
6. **Testing**: Structure supports easy unit testing
7. **Standards**: Follows Python best practices (PEP 8, type hints)

### Data Flow

```
CSV File → load_csv_groups() → Set[str] (csv_groups)
                                    ↓
                              find_missing_groups()
                                    ↓
YAML File → load_yaml_groups() → Set[str] (yaml_groups)
                                    ↓
                            ComparisonResult
                                    ↓
                    ┌───────────────┴───────────────┐
                    ↓                               ↓
            write_results()                   to_dict()
                    ↓                               ↓
              Text Output                     JSON Output
```

### Dependencies

**Runtime:**
- `PyYAML` (>=6.0.1) - YAML parsing

**Development (optional):**
- `pytest` - Testing framework
- `pytest-cov` - Coverage reporting
- `black` - Code formatting
- `ruff` - Fast linting
- `mypy` - Type checking
- `types-pyyaml` - Type stubs for PyYAML

**Python Version:**
- Requires Python 3.9 or higher
- Uses modern Python features:
  - Type hints with `|` union operator
  - Dataclasses
  - pathlib.Path
  - f-strings

## Usage Patterns

### As a CLI Tool
```bash
python compare_ad_groups.py [options]
compare-ad-groups [options]  # After installation
```

### As a Python Module
```python
from compare_ad_groups import find_missing_groups

result = find_missing_groups('csv_path', 'yaml_path')
```

### Programmatic Integration
```python
from compare_ad_groups import (
    find_missing_groups,
    ComparisonResult,
    load_csv_groups,
    load_yaml_groups,
    write_results,
)
```

## Development Workflow

1. **Setup**: `./setup.sh` or `make setup`
2. **Develop**: Edit code in `compare_ad_groups.py`
3. **Test**: `make test` (when tests are added)
4. **Lint**: `make lint`
5. **Format**: `make format`
6. **Run**: `make run`

## Extension Points

The module is designed to be extended:

1. **Custom Loaders**: Add new file format parsers
2. **Additional Comparisons**: Extend `ComparisonResult` with more metrics
3. **Output Formats**: Add new output formatters
4. **Filters**: Add filtering capabilities
5. **Validation**: Add group name validation rules

## Best Practices for Users

1. **Virtual Environment**: Always use the provided .venv
2. **Dependencies**: Install via uv for best performance
3. **Imports**: Import specific functions for clarity
4. **Error Handling**: Always wrap calls in try/except
5. **Type Hints**: Leverage type hints in your code

## Future Enhancements

Potential additions:
- Unit tests in `tests/` directory
- CI/CD pipeline configuration
- Additional output formats (Excel, HTML)
- Configuration file support
- Logging framework integration
- Performance optimizations for large files
- Interactive mode
- Diff generation for YAML updates

## Version History

- v0.1.0 - Initial release
  - Basic CSV/YAML comparison
  - CLI and module interfaces
  - Text and JSON output
  - Comprehensive documentation