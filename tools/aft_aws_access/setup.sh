#!/bin/bash
# Setup script for AFT AWS Access Tools
# This script sets up the virtual environment and installs dependencies using uv

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "AFT AWS Access Tools - Setup"
echo "========================================="
echo ""

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv is not installed."
    echo ""
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Source the uv environment
    export PATH="$HOME/.cargo/bin:$PATH"

    if ! command -v uv &> /dev/null; then
        echo "❌ Failed to install uv. Please install manually:"
        echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
        exit 1
    fi
fi

echo "✓ uv is installed"
echo ""

# Create virtual environment
echo "Creating virtual environment..."
if [ -d ".venv" ]; then
    echo "⚠️  Virtual environment already exists. Skipping creation."
else
    uv venv
    echo "✓ Virtual environment created"
fi
echo ""

# Activate virtual environment and install
echo "Installing dependencies..."
source .venv/bin/activate

# Install PyYAML directly first
uv pip install pyyaml>=6.0.1

# Then install the package
uv pip install -e .

echo "✓ Dependencies installed"
echo ""

# Optional: Install development dependencies
read -p "Install development dependencies? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing development dependencies..."
    uv pip install -e ".[dev]"
    echo "✓ Development dependencies installed"
    echo ""
fi

# Verify installation
echo "Verifying installation..."
python -c "import yaml; print('✓ PyYAML imported successfully')"
python -c "from compare_ad_groups import find_missing_groups; print('✓ Module imported successfully')"
echo ""

# Check if CSV file exists
echo "Checking for required files..."
if [ -f "aws_recent.csv" ]; then
    echo "✓ aws_recent.csv found"
else
    echo "⚠️  aws_recent.csv not found (expected in current directory)"
fi

# Check for YAML file in common locations
YAML_FOUND=false
if [ -f "../aws-access/conf/sso_groups.yaml" ]; then
    echo "✓ sso_groups.yaml found at ../aws-access/conf/sso_groups.yaml"
    YAML_FOUND=true
elif [ -f "/Users/a805120/develop/aws-access/conf/sso_groups.yaml" ]; then
    echo "✓ sso_groups.yaml found at /Users/a805120/develop/aws-access/conf/sso_groups.yaml"
    YAML_FOUND=true
fi

if [ "$YAML_FOUND" = false ]; then
    echo "⚠️  sso_groups.yaml not found in common locations"
    echo "   You'll need to specify the path with --yaml when running"
fi
echo ""

echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Activate the virtual environment:"
echo "     source .venv/bin/activate"
echo ""
echo "  2. Run the script:"
if [ "$YAML_FOUND" = true ]; then
    if [ -f "../aws-access/conf/sso_groups.yaml" ]; then
        echo "     python compare_ad_groups.py"
    else
        echo "     python compare_ad_groups.py --yaml /Users/a805120/develop/aws-access/conf/sso_groups.yaml"
    fi
else
    echo "     python compare_ad_groups.py --csv aws_recent.csv --yaml /path/to/sso_groups.yaml"
fi
echo ""
echo "  3. Or use the installed command:"
echo "     compare-ad-groups --help"
echo ""
echo "For more information, see README.md"
echo ""
