# Python Project Setup Instructions for AI Assistants

**Purpose:** This guide provides step-by-step instructions for setting up a Python project with modern tooling, virtual environments, and development-friendly configuration in Cursor/VS Code.

**When to use:** Drop this file into any Python project folder, then ask the AI assistant to "follow the setup instructions" or "set up this project according to SETUP_INSTRUCTIONS.md"

---

## 📋 Setup Checklist

1. ✅ Create project-local virtual environment
2. ✅ Set up dependency management (pyproject.toml + requirements.txt)
3. ✅ Create CLI wrapper pattern for easy debugging
4. ✅ Create runner script for quick development
5. ✅ Configure VS Code/Cursor settings
6. ✅ Set up debug configurations
7. ✅ Verify installation

---

## Step 1: Create Virtual Environment

**Goal:** Create a project-local virtual environment using `uv` (modern, fast) or `venv` (traditional).

### Using `uv` (Recommended):
```bash
# Ensure we're in the project root
pwd

# Create venv in project folder (UV_VENV_IN_PROJECT=1)
UV_VENV_IN_PROJECT=1 uv venv

# If uv is not available, install it:
# curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Using `venv` (Fallback):
```bash
python3 -m venv .venv
```

**Verify:**
```bash
ls -la .venv/bin/  # Should show python, activate, etc.
```

---

## Step 2: Set Up Dependency Management

### 2a. Create `pyproject.toml` (Modern Standard)

Create or update `pyproject.toml`:

```toml
[project]
name = "project-name"  # Replace with actual project name
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    # Add your dependencies here
    # Example: "boto3>=1.40.67",
    # Example: "requests>=2.31.0",
]
```

### 2b. Install Dependencies

**Using `uv` (Recommended):**
```bash
# Add dependencies (updates pyproject.toml + installs)
uv add package-name

# Or sync from existing pyproject.toml
uv sync
```

**Using `pip` (Traditional):**
```bash
source .venv/bin/activate  # Activate venv first
pip install -r requirements.txt
```

### 2c. Create/Update `requirements.txt` (For Compatibility)

If using `uv`, generate requirements.txt:
```bash
uv pip compile pyproject.toml -o requirements.txt
```

Or manually create `requirements.txt`:
```txt
# List dependencies here
# Example: boto3>=1.40.67
# Example: requests>=2.31.0
```

---

## Step 3: Create CLI Wrapper Pattern

**Purpose:** Provides a clean argparse interface that can be used programmatically.

Create `_cli_wrapper.py`:

```python
import argparse
from typing import Optional, Any, Dict, List


def build_parser() -> argparse.ArgumentParser:
    """
    Build the argument parser for the main script.
    Customize arguments based on your script's needs.
    """
    p = argparse.ArgumentParser(prog="your_script_name")
    
    # Add your arguments here
    # Example:
    # p.add_argument("--input", required=True, help="Input file path")
    # p.add_argument("--output", help="Output file path")
    # p.add_argument("--verbose", action="store_true", help="Verbose output")
    # p.add_argument("--region", default="us-east-2", help="AWS region")
    # p.add_argument("--profile", help="AWS CLI profile")
    
    return p


def parse_args() -> Dict[str, Any]:
    """
    Parse command-line arguments and return as dictionary.
    This allows programmatic use of CLI arguments.
    """
    args = build_parser().parse_args()
    
    # Convert args to dictionary
    # Adjust based on your argument names
    return dict(
        # input=args.input,
        # output=args.output,
        # verbose=args.verbose,
        # region=args.region,
        # profile=args.profile,
    )
```

**Customize:** Add the actual arguments your main script needs.

---

## Step 4: Modify Main Script for Dual Mode

**Goal:** Make your main script work both as CLI and as a library (callable with keyword arguments).

**Pattern:** Modify your `main()` function to accept optional keyword arguments:

```python
def main(
    # Add your parameters here with defaults
    # Example:
    # input: Optional[str] = None,
    # output: Optional[str] = None,
    # verbose: bool = False,
    # region: Optional[str] = None,
    # profile: Optional[str] = None,
):
    """
    Main entry point. Can be called with keyword arguments or as CLI (uses argparse).
    If key required parameter is provided as kwarg, uses kwargs; otherwise parses sys.argv.
    """
    # If a required parameter is provided, use kwargs; otherwise use argparse (CLI mode)
    # Example: if input is not None:
    if False:  # Replace with actual condition based on your required param
        # Use provided keyword arguments
        class Args:
            pass
        args = Args()
        # Set attributes from kwargs
        # args.input = input
        # args.output = output
        # args.verbose = verbose
        # ... etc
    else:
        # Fall back to argparse for CLI compatibility
        args = _parse_args()

    # Your existing logic here using args.*
    # ...


def _parse_args():
    """Parse command-line arguments using argparse."""
    ap = argparse.ArgumentParser(description="Your script description")
    
    # Add your arguments here (same as CLI wrapper if you want consistency)
    # ap.add_argument("--input", required=True, help="Input file")
    # ...
    
    return ap.parse_args()
```

**Key Point:** Check if a required parameter is provided as a kwarg to determine if called programmatically or from CLI.

---

## Step 5: Create Runner Script

**Purpose:** Quick development entry point with hardcoded config for easy debugging.

Create `runner.py`:

```python
from _cli_wrapper import parse_args  # optional; allows using CLI style if you want

try:
    from your_main_script import main  # Replace with your actual module name
except Exception as e:
    raise SystemExit(f"Could not import main() from your_main_script: {e}")

if __name__ == "__main__":
    # Option A: hardcode params for fast debugging:
    cfg = dict(
        # Add your hardcoded configuration here
        # Example:
        # input="data/input.txt",
        # output="data/output.txt",
        # verbose=True,
        # region="us-east-2",
        # profile="my-profile",
    )

    # Option B: reuse CLI-style args (works in F5 too):
    # cfg = parse_args()  # comment this out if using Option A above

    rc = main(**cfg)
    raise SystemExit(rc if isinstance(rc, int) else 0)
```

**Customize:** 
- Replace `your_main_script` with your actual module name
- Add your configuration parameters to the `cfg` dict

---

## Step 6: Configure VS Code/Cursor

### 6a. Create `.vscode` Directory

```bash
mkdir -p .vscode
```

### 6b. Create `.vscode/settings.json`

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.languageServer": "Pylance",
  "workbench.editor.enablePreview": true,
  "workbench.editor.enablePreviewFromQuickOpen": true,
  "workbench.editor.enablePreviewFromCodeNavigation": true
}
```

**Key Settings:**
- `python.defaultInterpreterPath`: Points to project venv
- `python.terminal.activateEnvironment`: Auto-activates venv in terminal
- `python.languageServer`: Uses Pylance for better IntelliSense
- `workbench.editor.enablePreview`: Single-click preview mode (replaces tabs)

### 6c. Create `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Runner (project venv, hardcoded/CLI)",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/runner.py",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}",
      "python": "${workspaceFolder}/.venv/bin/python",
      "args": [
        // Add default CLI arguments here if using Option B
        // Example: "--input", "data/input.txt",
        // Example: "--region", "us-east-2"
      ]
    },
    {
      "name": "Main script as CLI",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/your_main_script.py",
      "console": "integratedTerminal",
      "cwd": "${workspaceFolder}",
      "python": "${workspaceFolder}/.venv/bin/python",
      "args": [
        // Add default CLI arguments here
        // Example: "--input", "data/input.txt"
      ]
    }
  ]
}
```

**Customize:**
- Replace `your_main_script.py` with your actual script name
- Add default arguments to `args` array if needed

---

## Step 7: Create `.gitignore` (If Not Exists)

Create or update `.gitignore`:

```gitignore
# Virtual Environment
.venv/
venv/
env/
ENV/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python

# IDE
.vscode/launch.json  # Optional: commit settings.json but not launch.json
.idea/

# Environment variables
.env
.env.local

# Lock files (optional - some teams commit these)
# uv.lock
# poetry.lock

# OS
.DS_Store
Thumbs.db
```

---

## Step 8: Verify Installation

Run these sanity checks:

```bash
# 1. Activate venv
source .venv/bin/activate

# 2. Check Python interpreter
python -c "import sys; print('python:', sys.executable)"
# Should show: python: /path/to/project/.venv/bin/python

# 3. Check installed packages
python -c "import boto3; print('boto3:', boto3.__version__)"
# Replace boto3 with your actual dependencies

# 4. Test imports
python -c "from your_main_script import main; print('Imports successful')"
# Replace with your actual module name
```

---

## Step 9: Project Structure Summary

After setup, your project should look like:

```
project-root/
├── .venv/                          # Virtual environment (gitignored)
│   ├── bin/
│   │   ├── python
│   │   └── activate
│   └── lib/python3.x/site-packages/  # Dependencies installed here
│
├── .vscode/                        # VS Code/Cursor config
│   ├── settings.json               # Editor settings
│   └── launch.json                 # Debug configurations
│
├── your_main_script.py             # Main module (your core logic)
├── _cli_wrapper.py                 # CLI argument parser
├── runner.py                       # Development entry point
│
├── pyproject.toml                  # Modern dependency file
├── requirements.txt                # Traditional dependency file
├── uv.lock                         # Lock file (if using uv)
│
├── .gitignore                      # Git ignore rules
└── README.md                       # Project documentation
```

---

## Step 10: Usage Examples

### Running as CLI:
```bash
source .venv/bin/activate
python your_main_script.py --input data.txt --output result.txt
```

### Running via Runner (Hardcoded Config):
```bash
python runner.py
# Edit cfg dict in runner.py to change parameters
```

### Running via Runner (CLI Args):
```bash
python runner.py --input data.txt --output result.txt
# Uncomment cfg = parse_args() in runner.py
```

### Debugging in Cursor:
- Press `F5`
- Select "Runner (project venv, hardcoded/CLI)"
- Set breakpoints and debug!

---

## Troubleshooting

### Issue: "Python interpreter not found"
- **Solution:** Ensure `.venv/bin/python` exists
- **Check:** Run `ls .venv/bin/python`

### Issue: "Module not found" errors
- **Solution:** Activate venv: `source .venv/bin/activate`
- **Check:** Verify packages in `.venv/lib/python3.x/site-packages/`

### Issue: "Pylance not working"
- **Solution:** Install Pylance extension: `code --install-extension ms-python.vscode-pylance`
- **Check:** `.vscode/settings.json` has correct interpreter path

### Issue: "Preview mode not working"
- **Solution:** Check `.vscode/settings.json` has `"workbench.editor.enablePreview": true`
- **Reload:** Cmd+Shift+P → "Reload Window"

---

## Key Concepts for AI Assistants

1. **Virtual Environment:** Isolates project dependencies
2. **Dual Mode:** Main script works as both CLI and library
3. **Runner Pattern:** Quick development with hardcoded config
4. **VS Code Integration:** Proper interpreter and debug setup
5. **Dependency Management:** Both modern (pyproject.toml) and traditional (requirements.txt)

---

## Customization Checklist

When adapting this to a new project:

- [ ] Replace `your_main_script` with actual module name
- [ ] Add actual CLI arguments to `_cli_wrapper.py`
- [ ] Modify `main()` function signature with actual parameters
- [ ] Update `runner.py` config dict with actual values
- [ ] Update `launch.json` program paths
- [ ] Add project-specific dependencies to `pyproject.toml`
- [ ] Update `.gitignore` if needed
- [ ] Update README.md with project-specific instructions

---

**Last Updated:** 2024
**Maintained By:** Project setup automation guide


