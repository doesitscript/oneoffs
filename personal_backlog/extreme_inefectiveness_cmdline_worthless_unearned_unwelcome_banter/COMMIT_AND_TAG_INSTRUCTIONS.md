# Instructions for Creating Commits and Tags Based on Template Improvements

## When to Use These Instructions

Use these instructions when you've made improvements to the template based on evaluation findings and want to commit and tag the changes.

## Step-by-Step Process

### 1. Review Changes Made

**Action**: Review what changes were made to the template:
- Read `TEMPLATE_EVALUATION.md` to understand evaluation findings
- Check git status to see which files were modified
- Identify the type of changes:
  - **Bug fixes** (fixes errors, prevents failures)
  - **New features** (adds new functionality)
  - **Enhancements** (improves existing functionality)
  - **Breaking changes** (changes that break backward compatibility)

### 2. Stage Appropriate Files

**Action**: Stage only template files, not filled-out incident folders:
```bash
git add personal_backlog/chat_incident_template/
```

**Note**: Do NOT stage filled-out incident folders (like `guard_rails_fail_to_enforce_instructions_2nd_pass/`) - those are examples, not template improvements.

### 3. Determine Version Bump Type

**Action**: Determine semantic version bump based on changes:

**PATCH (x.y.Z)**: Bug fixes only, no new features
- Use when: Only fixing bugs, no new functionality
- Example: v0.2.0 → v0.2.1

**MINOR (x.Y.z)**: New features, enhancements, or significant bug fixes
- Use when: New features added, enhancements made, or critical bug fixes
- Backward compatible changes
- Example: v0.2.0 → v0.3.0

**MAJOR (X.y.z)**: Breaking changes
- Use when: Changes that break backward compatibility
- Example: v0.2.0 → v1.0.0

**Decision criteria for this template**:
- Critical bug fix (prevents failures) → MINOR
- New feature added → MINOR
- Multiple enhancements → MINOR
- Breaking changes → MAJOR

### 4. Create Commit Message

**Action**: Create a commit message following conventional commits format:

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `fix`: Bug fix
- `feat`: New feature
- `enhance`: Enhancement/improvement
- Use multiple types if needed: `fix(...) + feat(...)`

**Scope**: `chat_incident_template`

**Subject**: Brief summary (50 chars or less)

**Body**: Detailed description including:
- What was fixed/added/enhanced
- Why it matters
- Based on what evaluation findings
- Impact/benefits

**Footer** (optional):
- Breaking: Yes/No
- Compatibility: Backward compatible/Not compatible

**Example structure**:
```
fix(chat_incident_template): critical file update process fix + automatic issue tracking

CRITICAL FIX: [Description]
- What was fixed
- Why it matters
- Impact

NEW FEATURE: [Description]
- What was added
- How it works
- Benefits

ENHANCEMENTS: [Description]
- What was improved
- Details

Based on evaluation of [incident name]:
- Key findings referenced
- Quality score improvement (if applicable)

Breaking: No
Compatibility: Backward compatible
```

### 5. Create Commit

**Action**: Create the commit:
```bash
git commit -m "<commit message>"
```

### 6. Create Annotated Tag

**Action**: Create an annotated tag with detailed message:

**Format**:
```bash
git tag -a <tag_name> -m "<tag message>"
```

**Tag name format**: `chat_incident_v<MAJOR>.<MINOR>.<PATCH>`

**Tag message should include**:
- Version number and type (Major/Minor/Patch)
- Clear categorization of changes:
  - CRITICAL FIX: (if applicable)
  - NEW FEATURES: (if applicable)
  - ENHANCEMENTS: (if applicable)
- Context about what this version addresses
- Reference to previous version if fixing issues from it

**Example tag message**:
```
fix: critical file update process + feat: automatic issue tracking

Version: v0.3.0 (Minor version bump)

CRITICAL FIX:
- What was fixed
- Why it matters
- Impact

NEW FEATURES:
- What was added
- How it helps

ENHANCEMENTS:
- What was improved

This version addresses the [issues] discovered in v0.2.0
and adds [features] to prevent future problems.
```

### 7. Verify

**Action**: Verify commit and tag were created:
```bash
git log --oneline -1
git tag -l "*chat_incident*" | sort -V | tail -3
git show <tag_name> --oneline -s
```

## Complete Example Prompt

Here's how you would ask me to do this:

```
Commit the template improvements based on the evaluation findings and implemented features.

Requirements:
1. Review TEMPLATE_EVALUATION.md to understand what was fixed/added
2. Stage only template files (personal_backlog/chat_incident_template/)
3. Determine semantic version bump type (major/minor/patch) based on changes:
   - Critical bug fix → minor
   - New feature → minor
   - Breaking changes → major
4. Create commit with conventional commit format:
   - Type: fix, feat, or both
   - Scope: chat_incident_template
   - Body: Detail what was fixed/added, why it matters, based on what evaluation
   - Include: Breaking/Compatibility info
5. Create annotated tag (chat_incident_vX.Y.Z) with:
   - Version number and bump type
   - Categorized changes (CRITICAL FIX, NEW FEATURES, ENHANCEMENTS)
   - Context about addressing previous version issues
6. Verify commit and tag were created correctly

Make the call on version bump type based on:
- Critical bug fixes = minor bump
- New features = minor bump
- Multiple enhancements = minor bump
- Breaking changes = major bump
```

## Key Principles

1. **Only commit template files** - not filled-out incident examples
2. **Use semantic versioning** - follow MAJOR.MINOR.PATCH
3. **Conventional commits** - use standard commit message format
4. **Annotated tags** - include detailed context in tag message
5. **Document decisions** - explain why version bump type was chosen
6. **Reference evaluations** - link commits to evaluation findings
7. **Verify everything** - check that commit and tag were created correctly

