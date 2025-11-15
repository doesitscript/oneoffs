# Project Structure

This document summarizes the standardized layout for the `aft_aws_access` project after the reorganization. The goals are:
- Make functional code easy to find and package (src layout)
- Group scripts, data, and diagrams logically
- Keep investigations self-contained and reproducible
- Preserve older/assumption-era work while clearly highlighting the current direction (bfh_mgmt)
- Normalize paths across documentation

---

## Top-level Layout (overview)

```
aft_aws_access/
├─ src/
│  └─ aft_aws_access/
│     └─ compare_ad_groups.py           # Main functional module (CLI-enabled)
├─ tests/                               # Tests (pytest)
├─ scripts/                             # General-purpose operational scripts (shell/CLI)
├─ data/
│  ├─ raw/                              # Input/evidence (CloudTrail JSON, identity dumps, etc.)
│  ├─ derived/                          # Generated artifacts (e.g., summaries, CSV)
│  └─ reference/
│     └─ account_diagrams_data/         # Static inputs for diagrams/evidence
├─ diagrams/
│  ├─ lifecycle_bfh_mgmt/               # New lifecycle diagram suite
│  └─ generated/                        # Other generated architecture diagrams
├─ docs/
│  ├─ archive/
│  │  └─ pre_bfh_mgmt/                  # Early/assumption-era content (SCIM-first guidance, etc.)
│  ├─ presentations/                    # Slide-like artifacts
│  ├─ README.md                         # Project overview (moved from root)
│  ├─ README_TLDR.md
│  ├─ QUICK_REFERENCE.md / .txt
│  ├─ ROADMAP.md
│  ├─ RESEARCH_SUMMARY.md
│  ├─ PROJECT_STRUCTURE.md
│  ├─ INSTALL.md
│  ├─ GET_STARTED.md
│  ├─ INDEX.md
│  ├─ SUMMARY.md
│  └─ DIAGRAM_DOCUMENTATION.md
├─ investigations/
│  └─ 20241114_scim_investigation/
│     ├─ scripts/                       # Investigation-specific scripts (runbooks/automation)
│     ├─ raw_data/                      # Collected evidence per account (JSON/TXT)
│     ├─ logs/                          # Investigation logs/outputs
│     ├─ PICKUP_SUMMARY.md              # High-level handoff summary
│     ├─ EXPLAINED_FOR_USER.md          # Detailed explanations/answers
│     ├─ LIFECYCLE_DIAGRAMS_GUIDE.md    # Lifecycle diagram set documentation
│     └─ ... (additional reports)
├─ config/
│  ├─ .env.sailpoint
│  └─ .env.sailpoint.investigation
├─ tooling/
│  └─ serena/                           # Dev/agent tooling metadata
├─ pyproject.toml                       # Packaging config (src layout, CLI entrypoint)
├─ Makefile                             # Dev convenience targets (lint/test/format/etc.)
└─ .venv/                               # Local virtual environment (ignored by Git)
```

---

## Conventions

- Functional Python code uses a `src/` layout:
  - Package: `src/aft_aws_access`
  - Primary module: `src/aft_aws_access/compare_ad_groups.py`
  - Console script: `compare-ad-groups`
    - Entry point: `aft_aws_access.compare_ad_groups:main`
- Tests live under `tests/` and run with `pytest`.
- Shell/operational scripts live under `scripts/`.
- Investigation automation scripts are grouped under `investigations/<date>/scripts/`.
- Data is split by lifecycle:
  - `data/raw/` = inputs/evidence (never manually edited)
  - `data/derived/` = generated outputs (summaries/CSV/etc.)
  - `data/reference/` = static content used as inputs (e.g., for diagrams)
- Diagrams:
  - `diagrams/lifecycle_bfh_mgmt/` = the new lifecycle diagram set
  - `diagrams/generated/` = all other generated diagrams
- Documentation lives under `docs/`, with historical/assumption-era items under `docs/archive/pre_bfh_mgmt/`.

---

## Packaging and CLI

Packaging is configured for a src layout in `pyproject.toml`:
- Package modules: `src/aft_aws_access/`
- Console script:
  - Name: `compare-ad-groups`
  - Entry: `aft_aws_access.compare_ad_groups:main`

Examples:
- Run directly:
  ```
  python -m aft_aws_access.compare_ad_groups --csv data/derived/aws_recent.csv --yaml path/to/sso_groups.yaml
  ```
- Use the console script (after editable install):
  ```
  compare-ad-groups --csv data/derived/aws_recent.csv --yaml path/to/sso_groups.yaml
  ```

---

## Data Lifecycle

- Inputs (CloudTrail, identity store dumps, evidence) → `data/raw/`
- Processing/analysis scripts read from `data/raw/`
- Summaries and aggregates write to `data/derived/`
- Static inputs for diagrams and reference live under `data/reference/`

Guideline:
- Do not manually edit files in `data/raw/` or `data/derived/`
- Prefer generating/updating them via scripts

---

## Diagrams

- Lifecycle suite: `diagrams/lifecycle_bfh_mgmt/`
  - Includes: current solution architecture, implementation phases, seven-day activity, months of production evidence, coexistence proof, before/after, and complete workflow
- Other generated architecture diagrams: `diagrams/generated/`
  - Old `generated-diagrams/` paths have been normalized to `diagrams/`
  - Duplicate extensions like `.png.png` have been fixed to `.png`

---

## Investigations

Canonical, date-stamped investigation directory:
- `investigations/20241114_scim_investigation/`
  - `scripts/` for runbooks and automation (e.g., `BFH_MGMT_INSPECT_YOUR_SETUP.sh`, `QUICK_CHECK_COMMANDS.sh`)
  - `raw_data/` for account-specific evidence
  - `logs/` for capture of script outputs
  - Documentation:
    - `PICKUP_SUMMARY.md` (start here)
    - `EXPLAINED_FOR_USER.md`, `FINAL_20_ACCOUNT_INVESTIGATION_REPORT.md`, etc.
    - `LIFECYCLE_DIAGRAMS_GUIDE.md`
- New work should either:
  - Extend this investigation (if it’s the same effort window), or
  - Create a new date-stamped folder for a separate effort

---

## Scripts

- General scripts:
  - `scripts/` contains environment-agnostic helper scripts (e.g., resource collection, sync checks)
- Investigation-specific scripts:
  - Should live under `investigations/<date>/scripts/` and reference files relative to that investigation directory

---

## Documentation

- All top-level docs consolidated in `docs/`
- Early SCIM-first assumptions archived in `docs/archive/pre_bfh_mgmt/` for historical context
- Presentations (slide-like artifacts) in `docs/presentations/`
- This file: `docs/STRUCTURE.md` is the canonical reference for layout

---

## Config and Tooling

- Environment files live under `config/` (`.env.sailpoint`, etc.)
- Dev/agent tooling metadata lives under `tooling/serena/`

---

## Testing

- Tests in `tests/`
- Run:
  ```
  pytest
  ```
- Coverage target configured for `aft_aws_access` in `pyproject.toml`

---

## Common Tasks

- Create and activate venv:
  ```
  uv venv
  source .venv/bin/activate
  ```
- Install (editable):
  ```
  uv pip install -e ".[dev]"
  ```
- Lint/format:
  ```
  make lint
  make format
  ```
- Run the comparison tool:
  ```
  compare-ad-groups --csv data/derived/aws_recent.csv --yaml path/to/sso_groups.yaml
  ```

---

## Backwards Compatibility (paths)

- Old path: `generated-diagrams/` → New path: `diagrams/`
- Old absolute folder typo: `aft_aws_acess` → Correct: `aft_aws_access`
- Documentation references have been updated accordingly

---

## Adding New Content

- Code: add new modules under `src/aft_aws_access/` and tests under `tests/`
- Scripts: place general scripts under `scripts/`; investigation-specific scripts under that investigation’s `scripts/`
- Data: place inputs in `data/raw/` and write outputs to `data/derived/`; static inputs go under `data/reference/`
- Diagrams: lifecycle updates go into `diagrams/lifecycle_bfh_mgmt/`; other generated diagrams go under `diagrams/generated/`
- Docs: add/update under `docs/`; archive old assumptions under `docs/archive/pre_bfh_mgmt/`

---

## Ownership and Direction

- Current recommended approach: direct SailPoint → IAM role → IAM Identity Center (bfh_mgmt model)
- SCIM-first content is maintained only for historical context and is clearly archived
- The structure above is optimized to support ongoing operationalization of the bfh_mgmt-proven flow