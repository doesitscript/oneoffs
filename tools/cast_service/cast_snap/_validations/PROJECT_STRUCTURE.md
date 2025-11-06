# Python Project Structure & Ecosystem Guide

## 📁 Your Project Layout

```
cast_snap/
├── .venv/                          # Virtual environment (isolated Python environment)
│   ├── bin/                        # Executables (python, pip, boto3 scripts)
│   │   ├── python                  # Python interpreter for this project
│   │   ├── activate                # Script to activate the venv
│   │   └── ...                     # Other tools
│   └── lib/
│       └── python3.10/
│           └── site-packages/      # 📦 WHERE PACKAGES LIVE (boto3, etc.)
│               ├── boto3/
│               ├── botocore/
│               └── ...
│
├── .vscode/                        # VS Code/Cursor configuration
│   ├── settings.json               # Editor settings (Python interpreter path, etc.)
│   └── launch.json                 # Debug configurations (F5 to run)
│
├── __pycache__/                    # Compiled Python bytecode (auto-generated)
│
├── cast_snapshot_tool.py           # 🔧 MAIN MODULE: Core snapshot logic
├── _cli_wrapper.py                 # 🔧 CLI PARSER: Argument parsing helper
├── runner.py                       # 🚀 ENTRY POINT: Quick debug runner
├── main.py                         # (Legacy placeholder - not used)
│
├── pyproject.toml                  # 📋 MODERN DEPENDENCY FILE (uv/pip uses this)
├── requirements.txt                # 📋 TRADITIONAL DEPENDENCY FILE (pip)
├── uv.lock                         # 🔒 LOCKFILE: Exact package versions (uv)
│
└── README.md                       # Documentation
```

---

## 🎯 Key Concepts

### 1. **Virtual Environment (.venv/)**
**What it is:** An isolated Python environment for your project.

**Why it matters:**
- Keeps project dependencies separate from system Python
- Prevents version conflicts between projects
- Makes your project portable and reproducible

**How it works:**
```bash
# Activate (makes .venv/bin/python the default)
source .venv/bin/activate

# Now when you run:
python some_script.py  # Uses .venv/bin/python
pip install boto3      # Installs to .venv/lib/.../site-packages/
```

**Where Cursor looks:**
- `.vscode/settings.json` tells Cursor: "Use `.venv/bin/python` as the interpreter"
- This is why IntelliSense and debugging work correctly

---

### 2. **Package Installation Locations**

| Where | What Goes There | How to Install |
|-------|----------------|----------------|
| **`.venv/lib/python3.10/site-packages/`** | Project packages (boto3, etc.) | `uv add boto3` or `pip install boto3` (when venv active) |
| **System Python** (`/usr/bin/python3`) | System-wide packages | ❌ Don't use (requires sudo) |
| **User site-packages** (`~/.local/lib/`) | User-level packages | ❌ Don't use (can cause conflicts) |

**✅ Always install to project venv:**
```bash
source .venv/bin/activate  # Activate first!
uv add boto3               # or: pip install boto3
```

---

### 3. **Dependency Files Explained**

#### **`pyproject.toml`** (Modern Standard)
```toml
[project]
name = "cast-snap"
requires-python = ">=3.10"
dependencies = [
    "boto3>=1.40.67",
    "black>=25.9.0",
]
```
- **Format:** TOML (like YAML but stricter)
- **Purpose:** Defines project metadata AND dependencies
- **Used by:** `uv`, `pip` (modern), `poetry`, `pdm`
- **Best for:** Modern Python projects

#### **`requirements.txt`** (Traditional)
```txt
boto3>=1.33.0
python-dotenv>=1.0.0
```
- **Format:** Simple text file, one package per line
- **Purpose:** Just lists dependencies
- **Used by:** `pip install -r requirements.txt`
- **Best for:** Legacy projects or simple dependency lists

#### **`uv.lock`** (Lock File)
- **Format:** TOML with exact versions
- **Purpose:** Locks EXACT versions of all packages (including transitive dependencies)
- **Used by:** `uv` (like `package-lock.json` in Node.js)
- **Why it matters:** Ensures everyone gets the same versions

**When to use which:**
- ✅ **Use `pyproject.toml`** if using `uv` or modern tooling
- ✅ **Use `requirements.txt`** if team uses traditional `pip`
- ✅ **Keep both** for compatibility (you can sync them)

---

### 4. **Module Structure**

#### **`cast_snapshot_tool.py`** - Core Logic
- **Type:** Python module (can be imported)
- **Main function:** `main()` - Does the actual snapshot work
- **Can be called:** 
  - As CLI: `python cast_snapshot_tool.py --policy cast-daily`
  - As library: `from cast_snapshot_tool import main; main(policy="cast-daily")`

#### **`_cli_wrapper.py`** - CLI Parser
- **Type:** Helper module
- **Purpose:** Provides argument parsing without full argparse setup
- **Used by:** `runner.py` when you want CLI-style args

#### **`runner.py`** - Development Entry Point
- **Type:** Script (run directly)
- **Purpose:** Quick way to run with hardcoded config
- **Workflow:** Edit the `cfg` dict → Run → Debug easily

---

### 5. **How Python Finds Modules**

When you write `import boto3`, Python searches in this order:

1. **Current directory** (where your script is)
2. **PYTHONPATH** environment variable
3. **Site-packages** (`.venv/lib/python3.10/site-packages/`)
4. **Standard library** (built-in modules)

**Your project:**
```python
# runner.py can do this because files are in same directory:
from cast_snapshot_tool import main
from _cli_wrapper import parse_args
```

**Installed packages:**
```python
# boto3 is found because it's in .venv/lib/.../site-packages/
import boto3
```

---

### 6. **VS Code/Cursor Configuration**

#### **`.vscode/settings.json`**
```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.languageServer": "Pylance"
}
```

**What each setting does:**
- `defaultInterpreterPath`: Tells Cursor which Python to use
  - `${workspaceFolder}` = your project root
  - So it uses `.venv/bin/python` (project venv)
- `activateEnvironment`: Auto-activates venv in terminal
- `languageServer`: Uses Pylance for better IntelliSense

#### **`.vscode/launch.json`**
- Defines debug configurations (F5 to run)
- `"python"` field: Which Python to use for debugging
- `"args"`: Command-line arguments to pass

---

### 7. **Package Managers: `uv` vs `pip`**

#### **`uv`** (Modern, Fast)
```bash
uv venv                    # Create venv
uv add boto3               # Add dependency (updates pyproject.toml + installs)
uv sync                    # Install all dependencies from pyproject.toml
uv remove boto3            # Remove dependency
```
- ⚡ **Fast:** Written in Rust, much faster than pip
- 📦 **Manages:** Both venv and dependencies
- 🔒 **Locking:** Creates `uv.lock` automatically

#### **`pip`** (Traditional)
```bash
pip install boto3          # Install package
pip install -r requirements.txt  # Install from file
pip freeze > requirements.txt    # Export current packages
```
- 🐌 **Slower:** Pure Python
- 📦 **Manages:** Just packages (venv is separate)
- 📝 **No lockfile:** `requirements.txt` is just a list

**Your project uses `uv`** (modern approach)

---

### 8. **Common Workflows**

#### **Adding a New Dependency**
```bash
# Option 1: Using uv (recommended)
uv add requests  # Updates pyproject.toml + installs

# Option 2: Using pip
source .venv/bin/activate
pip install requests
pip freeze > requirements.txt  # Update requirements.txt
```

#### **Setting Up Project Fresh**
```bash
# Clone repo
git clone ...
cd cast_snap

# Create venv and install dependencies
uv venv
source .venv/bin/activate  # or: uv sync (auto-activates)
uv sync                     # Installs from pyproject.toml
```

#### **Running Your Code**
```bash
# Option 1: Direct (CLI mode)
python cast_snapshot_tool.py --policy cast-daily --region us-east-2

# Option 2: Via runner (hardcoded config)
python runner.py

# Option 3: Via runner (CLI args)
python runner.py --policy cast-daily --filter tag:Role=CASTServer
```

---

### 9. **File Naming Conventions**

| Pattern | Meaning | Example |
|---------|---------|---------|
| `*.py` | Python module/script | `cast_snapshot_tool.py` |
| `_*.py` | "Private" module (convention, not enforced) | `_cli_wrapper.py` |
| `__pycache__/` | Compiled bytecode (auto-generated) | Ignore in git |
| `.venv/` | Virtual environment | Ignore in git |
| `.vscode/` | Editor config | Usually commit this |

---

### 10. **Import Paths Explained**

```python
# Absolute import (from project root)
from cast_snapshot_tool import main

# If you had a package structure:
# myproject/
#   ├── utils/
#   │   └── helpers.py
#   └── main.py
#
# In main.py:
from utils.helpers import some_function  # Relative to project root
```

**Current project structure (flat):**
- All `.py` files are in root
- No packages/subdirectories
- Simple imports work directly

---

## 🎓 Best Practices

1. **Always use a venv** - Never install packages globally
2. **Keep dependency files in sync** - `pyproject.toml` and `requirements.txt`
3. **Commit lock files** - `uv.lock` ensures reproducible builds
4. **Don't commit venv** - Add `.venv/` to `.gitignore`
5. **Use `uv` for new projects** - It's faster and modern
6. **Set interpreter in Cursor** - Ensures correct Python/IntelliSense

---

## 🔍 Where Cursor Looks for Things

1. **Python Interpreter:** `.vscode/settings.json` → `python.defaultInterpreterPath`
2. **Packages:** `.venv/lib/python3.10/site-packages/` (when venv is active)
3. **Your Code:** Current directory (where `.py` files are)
4. **Dependencies:** `pyproject.toml` or `requirements.txt`
5. **Debug Config:** `.vscode/launch.json`

---

## 🚀 Quick Reference

```bash
# Activate venv
source .venv/bin/activate

# Add package
uv add package_name

# Run script
python runner.py

# Debug in Cursor
# Press F5 → Select "Runner (project venv, hardcoded/CLI)"
```

---

This structure follows modern Python project best practices and works well with both traditional `pip` workflows and modern `uv` workflows!

