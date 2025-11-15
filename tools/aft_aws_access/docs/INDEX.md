# AFT AWS Access Tools - Documentation Index

**Quick Access Guide to All Project Documentation**

---

## 🚀 Getting Started (Start Here!)

### For First-Time Users
1. **[GET_STARTED.md](GET_STARTED.md)** - 60-second quickstart ⭐ **START HERE**
2. **[QUICKSTART.md](QUICKSTART.md)** - 5-minute tutorial with examples
3. **[INSTALL.md](INSTALL.md)** - Detailed installation guide

### Quick Reference
- **[README.md](README.md)** - Complete project documentation
- **[SUMMARY.md](SUMMARY.md)** - Project overview and features

---

## 📚 Documentation by Topic

### Installation & Setup
| Document | Description | Length |
|----------|-------------|--------|
| [GET_STARTED.md](GET_STARTED.md) | Ultra-quick 60-second start | 1 page |
| [INSTALL.md](INSTALL.md) | Complete installation instructions | 401 lines |
| [QUICKSTART.md](QUICKSTART.md) | Step-by-step tutorial | 201 lines |

### Usage & Examples
| Document | Description | Length |
|----------|-------------|--------|
| [README.md](README.md) | Full API documentation | 250 lines |
| [example_usage.py](example_usage.py) | 7 working code examples | 222 lines |

### Architecture & Development
| Document | Description | Length |
|----------|-------------|--------|
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | Architecture and design | 278 lines |
| [SUMMARY.md](SUMMARY.md) | Project overview | 398 lines |

---

## 📖 Documentation by Use Case

### "I want to start using this right now"
→ [GET_STARTED.md](GET_STARTED.md)

### "I need to install this properly"
→ [INSTALL.md](INSTALL.md)

### "I want to see examples"
→ [example_usage.py](example_usage.py)

### "I need the API reference"
→ [README.md](README.md) (see API Reference section)

### "I want to understand the architecture"
→ [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

### "I want a complete overview"
→ [SUMMARY.md](SUMMARY.md)

### "I'm having problems"
→ [INSTALL.md](INSTALL.md) (see Troubleshooting section)

---

## 🔧 Source Code Files

### Core Module
- **[compare_ad_groups.py](compare_ad_groups.py)** - Main module (291 lines)
  - Can be used as script or imported as module
  - Contains all comparison logic
  - Full type hints and error handling

### Configuration
- **[pyproject.toml](pyproject.toml)** - Project configuration
- **[Makefile](Makefile)** - Task automation
- **[setup.sh](setup.sh)** - Automated setup script
- **[.gitignore](.gitignore)** - Git ignore patterns

### Testing
- **[tests/test_compare_ad_groups.py](tests/test_compare_ad_groups.py)** - Unit tests (397 lines)
- **[tests/__init__.py](tests/__init__.py)** - Test package init

---

## 🎯 Quick Commands

### Installation
```bash
./setup.sh                    # Automated setup
make setup                    # Alternative setup
source .venv/bin/activate     # Activate environment
```

### Running
```bash
python compare_ad_groups.py              # Basic run
python compare_ad_groups.py --json       # JSON output
python example_usage.py                  # See examples
make run                                 # Using Make
```

### Help
```bash
python compare_ad_groups.py --help       # CLI help
make help                                # Make commands
```

---

## 📊 Documentation Statistics

| Category | Files | Lines |
|----------|-------|-------|
| Core Code | 1 | 291 |
| Examples | 1 | 222 |
| Tests | 1 | 397 |
| Documentation | 6 | 1,779 |
| Configuration | 4 | 326 |
| **Total** | **13** | **3,015** |

---

## 🗂️ Complete File Listing

```
aft_aws_access/
├── Documentation (6 files)
│   ├── GET_STARTED.md          # 60-second quickstart
│   ├── QUICKSTART.md           # 5-minute tutorial
│   ├── INSTALL.md              # Installation guide
│   ├── README.md               # Complete documentation
│   ├── PROJECT_STRUCTURE.md   # Architecture
│   ├── SUMMARY.md              # Project overview
│   └── INDEX.md                # This file
│
├── Source Code (2 files)
│   ├── compare_ad_groups.py    # Main module
│   └── example_usage.py        # Usage examples
│
├── Configuration (4 files)
│   ├── pyproject.toml          # Python project config
│   ├── Makefile                # Task automation
│   ├── setup.sh                # Setup script
│   └── .gitignore              # Git ignores
│
├── Tests (2 files)
│   ├── tests/__init__.py
│   └── tests/test_compare_ad_groups.py
│
└── Data (1 file)
    └── aws_recent.csv          # Input data
```

---

## 🎓 Learning Path

### Beginner (Never used Python tools before)
1. Read [GET_STARTED.md](GET_STARTED.md)
2. Run `./setup.sh`
3. Try `python compare_ad_groups.py`
4. Read [QUICKSTART.md](QUICKSTART.md) for more

### Intermediate (Want to use as a module)
1. Read [README.md](README.md) API Reference section
2. Review [example_usage.py](example_usage.py)
3. Try integrating into your project
4. Check [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for architecture

### Advanced (Want to contribute/modify)
1. Read [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
2. Review [tests/test_compare_ad_groups.py](tests/test_compare_ad_groups.py)
3. Check [SUMMARY.md](SUMMARY.md) for design decisions
4. Install dev dependencies: `uv pip install -e ".[dev]"`

---

## 🔍 Find Information Quickly

| I need to... | Go to... |
|--------------|----------|
| Install the tool | [INSTALL.md](INSTALL.md) |
| Start using it immediately | [GET_STARTED.md](GET_STARTED.md) |
| See code examples | [example_usage.py](example_usage.py) |
| Understand the API | [README.md](README.md) |
| Learn the architecture | [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) |
| Fix installation problems | [INSTALL.md](INSTALL.md) - Troubleshooting |
| Run tests | [tests/test_compare_ad_groups.py](tests/test_compare_ad_groups.py) |
| Understand design decisions | [SUMMARY.md](SUMMARY.md) |
| Get CLI help | Run `python compare_ad_groups.py --help` |

---

## 📞 Support

- **Quick Help**: `python compare_ad_groups.py --help`
- **Examples**: `python example_usage.py`
- **Make Commands**: `make help`
- **Contact**: AWS Infrastructure team

---

## 🎯 Most Important Files

**For Using the Tool:**
1. [GET_STARTED.md](GET_STARTED.md) - Start here
2. [compare_ad_groups.py](compare_ad_groups.py) - The actual tool
3. [example_usage.py](example_usage.py) - How to use it

**For Understanding the Tool:**
1. [README.md](README.md) - What it does and how
2. [SUMMARY.md](SUMMARY.md) - Complete overview
3. [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - How it's built

---

**Version**: 0.1.0  
**Last Updated**: 2024  
**Python Version**: 3.9+

---

*Navigate documentation efficiently with this index!*