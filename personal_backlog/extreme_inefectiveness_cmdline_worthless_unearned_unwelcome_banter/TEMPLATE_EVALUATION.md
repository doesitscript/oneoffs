# Template Evaluation and Improvement Recommendations

**Evaluation Date**: 2025-01-28  
**Evaluated Incident**: `guard_rails_fail_to_enforce_instructions_2nd_pass/`  
**Template Version**: v0.2.0

Based on analysis of the filled-out incident documentation (`guard_rails_fail_to_enforce_instructions_2nd_pass/`), here's feedback on how well the template was filled out and how to improve it.

## Critical Issue Discovered: File Update Errors

### Problem: "String to replace was not found" Errors

**What Happened**:
- When filling out the template, the AI encountered multiple "The string to replace was not found" errors
- Errors occurred when trying to update `README.md` and `ANALYSIS.md`
- The AI was using `search_replace` operations on files that already had content

**Root Cause**:
- Template files contain placeholder content (e.g., `[PLACEHOLDER]`, `[DATE]`, etc.)
- AI attempted to use `search_replace` to update specific sections
- When files already had real content (from previous fill-out or partial updates), the exact strings didn't match
- AI should WRITE complete files, not use search_replace on template files

**Impact**:
- Failed updates to README.md (evidence checklist, conversation export sections)
- Failed updates to ANALYSIS.md (specific examples section)
- User had to manually fix or AI had to re-read and retry

**This is a TEMPLATE/PROCESS issue, NOT user responsibility**

## What Was Done Well ✅

### 1. Excellent Coverage and Specificity
- ✅ **Complete date**: Used `2025-01-28` instead of `2025-01-XX` - excellent improvement!
- ✅ **Conversation Context section**: Fully filled out with all required fields
- ✅ **Timeline of Events**: Included with specific sequence of events
- ✅ **File references with line numbers**: All file references include specific line numbers (e.g., "lines 121-135")
- ✅ **Specific Examples section**: ANALYSIS.md includes 3 detailed examples with actual conversation excerpts and command outputs

### 2. Strong Evidence Documentation
- ✅ **Conversation excerpts**: Multiple actual quotes from conversation showing the problem
- ✅ **Actual commands executed**: Shows exact bash commands that were run (with ❌ markers for mistakes)
- ✅ **Before/after comparisons**: Clear comparison of expected vs. actual commit messages
- ✅ **Specific file references**: Includes exact line numbers for workflow template instructions

### 3. Comprehensive Analysis
- ✅ **Root causes**: Detailed with detection/compliance indicators
- ✅ **What Should Have Happened vs. What Actually Happened**: Clear comparison with actual examples
- ✅ **Specific Examples section**: Three detailed examples with conversation excerpts and command outputs
- ✅ **Evidence checklist**: README.md shows evidence tracking (most items checked)

### 4. Template Structure Adherence
- ✅ **All sections filled**: No placeholder text remaining in key documents
- ✅ **Status tracking**: README.md shows progress on checklist items
- ✅ **Evidence tracking**: README.md includes evidence checklist showing what was included

## What Could Be Improved ❌

### 1. Missing Content in Key Sections

**Issue**: USER_OBSERVATIONS_AND_QUESTIONS.md contains only template placeholders
- **Impact**: This was a key improvement from the previous evaluation - user observations should be captured
- **Current**: All sections still have `[PLACEHOLDER]` format
- **Expected**: Should contain actual user observations from the incident
- **Fix**: AI should extract user observations from conversation even if not explicitly provided in prompt

**Issue**: NUANCED_FACTORS.md contains only template placeholders
- **Impact**: Missing philosophical considerations that are critical for understanding balance questions
- **Current**: All sections still have `[PLACEHOLDER]` format
- **Expected**: Should contain nuanced analysis of helpful behaviors vs. problematic behaviors
- **Fix**: AI should always fill out NUANCED_FACTORS.md with relevant considerations

**Issue**: QUICK_REFERENCE.md contains only template placeholders
- **Impact**: Missing quick reference for future lookup
- **Current**: All sections still have `[PLACEHOLDER]` format
- **Expected**: Should contain concise summary of incident, root causes, and key files
- **Fix**: AI should always complete QUICK_REFERENCE.md

### 2. Template Files Should Not Be Included

**Issue**: Template helper files included in filled-out incident folder
- **Files**: `TEMPLATE_USAGE.md`, `TEMPLATE_EVALUATION.md`, `TEMPLATE_ACTIONS.md`, `PROMPT_TEMPLATE.md`, `AI_INSTRUCTIONS.md`
- **Impact**: These are template files, not incident-specific documentation
- **Fix**: AI should not copy template helper files when filling out the template - only copy and fill out the core documentation files

### 3. File Update Process Issue (CRITICAL)

**Issue**: AI using search_replace on template files causes errors
- **Impact**: "String to replace was not found" errors when files already have content
- **Root Cause**: Template files contain placeholder content, but AI tries to update specific strings
- **Fix**: AI should WRITE complete files, not use search_replace operations

## Template Quality Score

Based on the filled-out documentation:

- **Completeness**: 7/10 (core sections excellent, but USER_OBSERVATIONS_AND_QUESTIONS.md, NUANCED_FACTORS.md, QUICK_REFERENCE.md not filled)
- **Specificity**: 10/10 (excellent examples, quotes, commands, line numbers - major improvement!)
- **Traceability**: 9/10 (complete date, file references with line numbers, timeline - excellent!)
- **Usability**: 8/10 (well organized, but missing some key sections)
- **Evidence Quality**: 10/10 (excellent conversation excerpts, actual commands, before/after comparisons)
- **Process Reliability**: 6/10 (file update errors indicate process issues)

**Overall**: 8.3/10 - **Significant improvement** from previous evaluation (7.6/10). Major gains in specificity and evidence documentation, but needs to fix file update process and ensure all sections are filled out.

## Improvements from Previous Evaluation

### ✅ Fixed Issues
1. ✅ **Complete date**: Now uses `2025-01-28` instead of `2025-01-XX`
2. ✅ **Line numbers**: All file references include specific line numbers
3. ✅ **Conversation excerpts**: Multiple actual quotes included
4. ✅ **Specific examples**: Detailed examples section with actual commands and outputs
5. ✅ **Timeline**: Timeline of events included
6. ✅ **Conversation Context**: Fully filled out section

### ⚠️ Still Needs Work
1. ⚠️ **USER_OBSERVATIONS_AND_QUESTIONS.md**: Not filled out (should extract from conversation)
2. ⚠️ **NUANCED_FACTORS.md**: Not filled out (should always be completed)
3. ⚠️ **QUICK_REFERENCE.md**: Not filled out (should always be completed)
4. ⚠️ **Template files**: Should not be copied to filled-out incident folder

### 🔴 NEW Critical Issue
5. 🔴 **File update process**: Using search_replace on template files causes errors - should WRITE complete files

## Recommended Template Improvements

### 1. Fix File Update Process (CRITICAL - HIGHEST PRIORITY)

**Priority**: CRITICAL

**Problem**: AI using `search_replace` on template files with placeholders causes "string not found" errors

**Solution**: Update AI_INSTRUCTIONS.md to require WRITING complete files, not using search_replace

**Add to AI_INSTRUCTIONS.md**:
```markdown
## File Update Process

**CRITICAL**: When filling out template files, you must WRITE complete files, not use search_replace.

### Why This Matters
- Template files contain placeholder content (e.g., `[PLACEHOLDER]`, `[DATE]`)
- If files already have content (from previous attempts or partial updates), search_replace will fail
- Writing complete files ensures all content is properly filled out

### Process for Each File:
1. **Read the template file** to understand structure
2. **Write the complete file** with all placeholders replaced with actual content
3. **DO NOT use search_replace** on template files - use write tool instead

### Files to Fill Out (Write Complete Content):
- INCIDENT_SUMMARY.md - Write complete file with all sections filled
- ANALYSIS.md - Write complete file with all sections filled
- NUANCED_FACTORS.md - Write complete file with all sections filled
- USER_OBSERVATIONS_AND_QUESTIONS.md - Write complete file with all sections filled
- QUICK_REFERENCE.md - Write complete file with all sections filled
- README.md - Write complete file with incident details (update all sections)

**Exception**: Only use search_replace if you're updating a file that was already filled out in a previous step of the same conversation, and you're making a small, targeted change.
```

### 2. Ensure All Core Sections Are Filled

**Priority**: HIGH

**Update AI_INSTRUCTIONS.md** to explicitly require:
- USER_OBSERVATIONS_AND_QUESTIONS.md must be filled even if user doesn't provide explicit observations
- NUANCED_FACTORS.md must always be completed with relevant considerations
- QUICK_REFERENCE.md must always be completed

**Add to AI_INSTRUCTIONS.md**:
```markdown
#### USER_OBSERVATIONS_AND_QUESTIONS.md
- **MUST be filled out** - Extract user observations from conversation if not explicitly provided
- Look for user questions, concerns, expectations in the conversation
- Document what user expected vs. what actually happened
- **DO NOT leave placeholders** - this is a critical section
- **WRITE complete file** - do not use search_replace

#### NUANCED_FACTORS.md
- **MUST be filled out** - Always complete with relevant considerations
- Extract helpful behaviors that became problematic
- Document balance questions (advisory vs. enforcement, strict vs. flexible)
- Consider context diversity and different scenarios
- **DO NOT leave placeholders** - philosophical considerations are critical
- **WRITE complete file** - do not use search_replace

#### QUICK_REFERENCE.md
- **MUST be filled out** - Always complete for quick future reference
- Include one-sentence incident description
- List root causes
- List key files
- List what needs fixing
- **DO NOT leave placeholders** - this is for quick lookup
- **WRITE complete file** - do not use search_replace
```

### 3. Exclude Template Helper Files

**Priority**: HIGH

**Update AI_INSTRUCTIONS.md** to explicitly exclude:
- TEMPLATE_USAGE.md
- TEMPLATE_EVALUATION.md
- TEMPLATE_ACTIONS.md
- PROMPT_TEMPLATE.md
- AI_INSTRUCTIONS.md

**Add to AI_INSTRUCTIONS.md**:
```markdown
## Files to Fill Out

**Core documentation files** (must fill out - WRITE complete files):
- INCIDENT_SUMMARY.md
- ANALYSIS.md
- NUANCED_FACTORS.md
- USER_OBSERVATIONS_AND_QUESTIONS.md
- QUICK_REFERENCE.md
- README.md (update with incident details)

**Template helper files** (do NOT copy or include):
- TEMPLATE_USAGE.md
- TEMPLATE_EVALUATION.md
- TEMPLATE_ACTIONS.md
- PROMPT_TEMPLATE.md
- AI_INSTRUCTIONS.md

**Process**: When user drops template folder, only copy and fill out the core documentation files. Do not copy template helper files.
```

### 4. Add Completion Checklist

**Priority**: MEDIUM

**Add to AI_INSTRUCTIONS.md** a completion checklist:
```markdown
## Completion Checklist

Before finishing, verify:
- [ ] INCIDENT_SUMMARY.md - All sections filled, no placeholders, complete file written
- [ ] ANALYSIS.md - Includes specific examples with conversation excerpts, complete file written
- [ ] NUANCED_FACTORS.md - All themes filled with relevant considerations, complete file written
- [ ] USER_OBSERVATIONS_AND_QUESTIONS.md - User observations extracted from conversation, complete file written
- [ ] QUICK_REFERENCE.md - All sections filled with actual content, complete file written
- [ ] README.md - Updated with incident details, evidence checklist completed, complete file written
- [ ] No template helper files included in filled-out folder
- [ ] No "string not found" errors encountered (all files written completely, not search_replace)
```

## Priority Improvements

### Critical Priority (Fix Immediately)
1. 🔴 **Fix file update process** - Require WRITE complete files, not search_replace on template files

### High Priority (Do First)
2. ✅ Add requirement to always fill USER_OBSERVATIONS_AND_QUESTIONS.md (extract from conversation)
3. ✅ Add requirement to always fill NUANCED_FACTORS.md
4. ✅ Add requirement to always fill QUICK_REFERENCE.md
5. ✅ Add explicit exclusion of template helper files

### Medium Priority
6. ⚠️ Add guidance on extracting user observations from conversation
7. ⚠️ Add completion checklist to AI_INSTRUCTIONS.md
8. ⚠️ Update README.md evidence checklist to reflect when excerpts are in ANALYSIS.md

## Key Takeaways

### What's Working Great
- **Specificity and evidence**: Major improvement - excellent examples, quotes, commands, line numbers
- **Date handling**: Complete dates now extracted correctly
- **File references**: Line numbers included consistently
- **Timeline**: Sequence of events captured
- **Conversation Context**: Fully filled out

### What Needs Attention
- **File update process**: CRITICAL - using search_replace causes errors, should WRITE complete files
- **Completeness**: Three key sections (USER_OBSERVATIONS_AND_QUESTIONS.md, NUANCED_FACTORS.md, QUICK_REFERENCE.md) not being filled
- **Template file management**: Helper files should not be copied to filled-out folders
- **Extraction guidance**: Need better instructions for extracting user observations from conversation

### Process Issue Identified
The "string to replace was not found" errors indicate the AI is using the wrong approach. Template files should be WRITTEN completely, not updated with search_replace. This is a template/process issue, not user responsibility.

## Next Steps

1. **CRITICAL**: Update AI_INSTRUCTIONS.md with explicit requirement to WRITE complete files, not use search_replace
2. Update AI_INSTRUCTIONS.md with explicit requirements for all core sections
3. Add exclusion list for template helper files
4. Add guidance on extracting user observations from conversation
5. Add completion checklist
6. Test with another incident to verify improvements
