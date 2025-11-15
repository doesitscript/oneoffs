# Installation Guide

Complete installation instructions for AFT AWS Access Tools.

## Prerequisites

- **Python**: Version 3.9 or higher
- **Operating System**: macOS, Linux, or Windows
- **Files Required**:
  - `aws_recent.csv` - CSV file with AD group names
  - Access to `sso_groups.yaml` configuration file

## Quick Install (Recommended)

### 1. Navigate to Project Directory
```bash
cd /Users/a805120/develop/oneoffs/tools/aft_aws_access
```

### 2. Run Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
- ✓ Check for uv installation (install if missing)
- ✓ Create virtual environment
- ✓ Install dependencies
- ✓ Verify installation
- ✓ Check for required files

### 3. Activate Virtual Environment
```bash
source .venv/bin/activate
```

### 4. Verify Installation
```bash
python compare_ad_groups.py --help
```

You're ready to go! See [QUICKSTART.md](QUICKSTART.md) for usage examples.

---

## Manual Installation

### Option 1: Using uv (Faster)

#### Step 1: Install uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Add uv to your PATH (if not done automatically):
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

#### Step 2: Create Virtual Environment
```bash
cd aft_aws_access
uv venv
```

#### Step 3: Activate Virtual Environment

**macOS/Linux:**
```bash
source .venv/bin/activate
```

**Windows (PowerShell):**
```powershell
.venv\Scripts\Activate.ps1
```

**Windows (CMD):**
```cmd
.venv\Scripts\activate.bat
```

#### Step 4: Install Dependencies
```bash
uv pip install -e .
```

#### Step 5 (Optional): Install Development Tools
```bash
uv pip install -e ".[dev]"
```

### Option 2: Using Standard pip

#### Step 1: Create Virtual Environment
```bash
cd aft_aws_access
python -m venv .venv
```

#### Step 2: Activate Virtual Environment

**macOS/Linux:**
```bash
source .venv/bin/activate
```

**Windows:**
```cmd
.venv\Scripts\activate
```

#### Step 3: Upgrade pip
```bash
python -m pip install --upgrade pip
```

#### Step 4: Install Dependencies
```bash
pip install -e .
```

#### Step 5 (Optional): Install Development Tools
```bash
pip install -e ".[dev]"
```

---

## Verification

### Test the Installation

```bash
# Should display help message
python compare_ad_groups.py --help

# Or use the installed command
compare-ad-groups --help
```

### Run a Quick Test

```bash
# Run with default settings
python compare_ad_groups.py
```

Expected output should show:
- CSV and YAML file paths
- Count of groups in each file
- List of missing groups (if any)

### Verify Python Module Import

```bash
python -c "from compare_ad_groups import find_missing_groups; print('✓ Import successful')"
```

---

## Using Make Commands (Optional)

If you have `make` installed, you can use convenient shortcuts:

```bash
# See all available commands
make help

# Setup everything
make setup

# Run the comparison
make run

# Run with JSON output
make run-json

# Run examples
make example

# Format code
make format

# Run linters
make lint

# Clean up generated files
make clean
```

---

## Troubleshooting

### Issue: "uv: command not found"

**Solution:**
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Add to your shell profile for persistence
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
source ~/.bashrc  # or ~/.zshrc
```

### Issue: "No module named 'yaml'"

**Solution:**
```bash
# Activate virtual environment first
source .venv/bin/activate

# Install dependencies
uv pip install -e .
# or
pip install -e .
```

### Issue: Virtual environment activation fails

**macOS/Linux:**
```bash
# Make sure you're in the project directory
cd aft_aws_access

# Check if .venv exists
ls -la .venv

# If not, create it
uv venv
# or
python -m venv .venv

# Then activate
source .venv/bin/activate
```

**Windows:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# If restricted, set to RemoteSigned (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then activate
.venv\Scripts\Activate.ps1
```

### Issue: "FileNotFoundError: CSV file not found"

**Solution:**
```bash
# Check current directory
pwd

# Should be in aft_aws_access directory
# Verify CSV file exists
ls -l aws_recent.csv

# If not, make sure you're in the correct directory
cd /Users/a805120/develop/oneoffs/tools/aft_aws_access
```

### Issue: "FileNotFoundError: YAML file not found"

**Solution:**
```bash
# Check if YAML file exists at expected location
ls -l ../aws-access/conf/sso_groups.yaml

# If not, specify custom path
python compare_ad_groups.py \
  --csv aws_recent.csv \
  --yaml /path/to/your/sso_groups.yaml
```

### Issue: Permission denied on setup.sh

**Solution:**
```bash
chmod +x setup.sh
./setup.sh
```

### Issue: Python version too old

**Solution:**
```bash
# Check Python version
python --version
python3 --version

# Requires Python 3.9+
# Install newer Python or use specific version
python3.9 -m venv .venv
# or
python3.11 -m venv .venv
```

---

## Development Setup

For contributors or advanced users who want to modify the code:

```bash
# 1. Clone/navigate to project
cd aft_aws_access

# 2. Create virtual environment
uv venv

# 3. Activate
source .venv/bin/activate

# 4. Install with dev dependencies
uv pip install -e ".[dev]"

# 5. Verify dev tools
black --version
ruff --version
mypy --version
pytest --version
```

---

## Uninstallation

To completely remove the installation:

```bash
# 1. Deactivate virtual environment
deactivate

# 2. Remove virtual environment
rm -rf .venv

# 3. Remove generated files
rm -f missing_groups_report.txt
rm -f missing_groups_report.json
rm -rf __pycache__
rm -rf *.egg-info
```

---

## Next Steps

After successful installation:

1. **Quick Start**: See [QUICKSTART.md](QUICKSTART.md)
2. **Full Documentation**: See [README.md](README.md)
3. **Examples**: Run `python example_usage.py`
4. **Project Structure**: See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

---

## System Requirements

| Component | Requirement |
|-----------|-------------|
| Python | 3.9 or higher |
| Disk Space | ~50 MB (including virtual environment) |
| Memory | Minimal (< 100 MB) |
| OS | macOS, Linux, Windows |

## Dependencies

### Runtime Dependencies
- `PyYAML` >= 6.0.1

### Development Dependencies (Optional)
- `pytest` >= 7.4.0
- `pytest-cov` >= 4.1.0
- `black` >= 23.7.0
- `ruff` >= 0.0.285
- `mypy` >= 1.5.0
- `types-pyyaml` >= 6.0.12

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review [README.md](README.md) for usage help
3. Contact the AWS Infrastructure team

---

**Installation complete!** 🎉

Run `python compare_ad_groups.py` to start comparing AD groups.