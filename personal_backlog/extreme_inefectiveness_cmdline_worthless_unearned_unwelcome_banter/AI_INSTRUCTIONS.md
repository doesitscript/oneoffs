# AI Instructions for Processing This Template

**For the AI**: When this template folder is dropped into a chat with user observations/questions, follow these instructions:

**IMPORTANT**: Ignore `TEMPLATE_ACTIONS.md` when filling out the template - it is only for user reference to trigger specific actions later.

## Your Role

You are documenting an incident that occurred in a conversation. The user has **stopped giving instructions** to freeze the current state and wants you to document everything comprehensively.

## What You Should Do

### 1. Analyze the Conversation History
- Review the most recent conversation history
- **Extract specific examples**: quotes, commands, error messages, outputs
- Identify what the user asked for
- Identify what you (the AI) did
- Identify what went wrong or didn't work as expected
- Look for patterns, root causes, and contributing factors
- **Note timestamps or sequence** of events if available
- **Extract complete dates** from conversation (use format YYYY-MM-DD, not XX)

### 2. Fill Out the Template Documents

**CRITICAL: File Update Process**

When filling out template files, you must **WRITE complete files**, not use `search_replace` operations.

**Why This Matters**:
- Template files contain placeholder content (e.g., `[PLACEHOLDER]`, `[DATE]`, `[INCIDENT NAME]`)
- If files already have content (from previous attempts or partial updates), `search_replace` will fail with "string not found" errors
- Writing complete files ensures all placeholders are properly replaced with actual content

**Process for Each File**:
1. **Read the template file** first to understand the structure
2. **WRITE the complete file** with all placeholders replaced with actual content
3. **DO NOT use `search_replace`** on template files - use the `write` tool instead
4. Replace ALL placeholders: `[PLACEHOLDER]`, `[DATE]`, `[INCIDENT NAME]`, etc.

**Exception**: Only use `search_replace` if you're updating a file that was already completely filled out in a previous step of the same conversation, and you're making a small, targeted change to a specific section.

#### INCIDENT_SUMMARY.md
- **WRITE complete file** - do not use search_replace
- Document the high-level overview
- **Extract complete date** from conversation (format: YYYY-MM-DD, not XX)
- **Include conversation context**: what was being worked on, user's goal, background
- **Create timeline** of events if sequence is important
- List what worked (✅) and what didn't (❌)
- Identify root causes at a summary level
- Note key findings
- **Include file paths with line numbers** when referencing code/instructions

#### ANALYSIS.md
- **WRITE complete file** - do not use search_replace
- Provide detailed technical analysis
- **Include specific examples**: actual commands, outputs, error messages, conversation excerpts
- **Show before/after comparisons** when applicable
- Show what should have happened vs. what actually happened
- Deep dive into root causes
- Provide recommendations
- Consider implementation constraints
- **Include at least 2-3 concrete examples** (quotes, commands, outputs)

#### NUANCED_FACTORS.md
- Document philosophical considerations
- Explore balance questions (advisory vs. enforcement, strict vs. flexible, etc.)
- Capture useful behaviors that became problematic
- Consider context diversity and different scenarios
- Think about trade-offs and design decisions

#### USER_OBSERVATIONS_AND_QUESTIONS.md
- **MUST be filled out** - Extract user observations from conversation if not explicitly provided
- **WRITE complete file** - do not use search_replace
- **Document ALL user observations** from their message or conversation
- **Capture ALL user questions** exactly as provided
- Look for user questions, concerns, expectations in the conversation
- Document what user expected vs. what actually happened
- Preserve the user's expectations vs. actual behavior
- Organize by category if helpful
- **DO NOT explore or answer the questions yet** - just document them
- **DO NOT leave placeholders** - this is a critical section

#### NUANCED_FACTORS.md
- **MUST be filled out** - Always complete with relevant considerations
- **WRITE complete file** - do not use search_replace
- Document philosophical considerations
- Extract helpful behaviors that became problematic
- Explore balance questions (advisory vs. enforcement, strict vs. flexible, etc.)
- Document balance questions (advisory vs. enforcement, strict vs. flexible)
- Capture useful behaviors that became problematic
- Consider context diversity and different scenarios
- Think about trade-offs and design decisions
- **DO NOT leave placeholders** - philosophical considerations are critical

#### QUICK_REFERENCE.md
- **MUST be filled out** - Always complete for quick future reference
- **WRITE complete file** - do not use search_replace
- Create a concise summary
- Include one-sentence incident description
- List root causes
- List key files
- Include key points for quick lookup
- Link to detailed documents
- **DO NOT leave placeholders** - this is for quick lookup

### 3. Integration of User Observations

- **Integrate relevant points** from user observations into ANALYSIS.md where they relate to root causes
- **Reference user questions** in NUANCED_FACTORS.md where they relate to philosophical considerations
- **DO NOT** try to answer the questions yet - the user wants to address them in a later analysis session

### 4. Update README.md
- **WRITE complete file** - do not use search_replace
- Replace placeholder text with actual incident name and description
- Update status checkboxes
- Note related files with line numbers when applicable
- Update evidence checklist if applicable
- Replace ALL placeholders: `[PLACEHOLDER]`, `[INCIDENT NAME]`, etc.

## Files to Fill Out

**Core documentation files** (must fill out - WRITE complete files):
- INCIDENT_SUMMARY.md - Write complete file with all sections filled
- ANALYSIS.md - Write complete file with all sections filled
- NUANCED_FACTORS.md - Write complete file with all sections filled
- USER_OBSERVATIONS_AND_QUESTIONS.md - Write complete file with all sections filled
- QUICK_REFERENCE.md - Write complete file with all sections filled
- README.md - Write complete file with incident details (update all sections)

**Template helper files** (do NOT copy or include in filled-out folder):
- TEMPLATE_USAGE.md
- TEMPLATE_EVALUATION.md
- TEMPLATE_ACTIONS.md
- PROMPT_TEMPLATE.md
- AI_INSTRUCTIONS.md

**Process**: When user drops template folder, only copy and fill out the core documentation files listed above. Do not copy template helper files to the filled-out incident folder.

## What You Should NOT Do

- ❌ **DO NOT explore or answer** the user's questions from USER_OBSERVATIONS_AND_QUESTIONS.md yet
- ❌ **DO NOT continue** the conversation that led to the incident
- ❌ **DO NOT make assumptions** beyond what's in the conversation history
- ❌ **DO NOT skip** documenting user observations - they're critical for later analysis
- ❌ **DO NOT hide processing issues** - document all errors and problems encountered

## Example User Observations Format

The user may provide observations like:

```
"[Observation 1] <-- [User's note about expectation]

[Observation 2] <-- [User's note]

[Question 1] <-- [User's question]
```

**Your task**: Document these exactly, preserving the user's voice and concerns, organized clearly in USER_OBSERVATIONS_AND_QUESTIONS.md.

## Specificity Requirements

When filling out the template, ensure:
- ✅ Include at least 2-3 specific examples (quotes, commands, outputs, error messages)
- ✅ Include actual file paths with line numbers when referencing code/instructions
- ✅ Include complete dates extracted from conversation (format: YYYY-MM-DD, not XX)
- ✅ Include conversation excerpts showing the problem (actual quotes)
- ✅ Include before/after comparisons when applicable
- ✅ Include actual commands executed and their outputs
- ✅ Include error messages or unexpected outputs
- ✅ Include timeline/sequence of events if important

## Processing Issues Tracking

**CRITICAL**: Document any issues encountered while processing the template.

### What to Track
- **File update errors**: "string not found" errors, write failures, etc.
- **Missing information**: Information you couldn't extract from conversation
- **Template structure issues**: Placeholders that were unclear, missing sections, etc.
- **Tool failures**: Any tools that failed or behaved unexpectedly
- **Workarounds**: What you did to work around issues

### How to Document
1. **Track issues as they occur** - Don't wait until the end
2. **Document in README.md** - Add a "Template Processing Issues" section
3. **Include specific details**:
   - What operation failed
   - What error message was received
   - What file/section was affected
   - How you worked around it (if applicable)
   - What might need to be fixed in the template

### Format for README.md
Add this section to README.md:

```markdown
## Template Processing Issues

**Purpose**: This section documents any issues encountered while processing the template. This helps improve the template for future use.

### Issues Encountered

**Issue 1**: [Brief description]
- **Operation**: [What you were trying to do]
- **Error**: [Error message or problem]
- **File/Section**: [Which file or section was affected]
- **Workaround**: [How you handled it]
- **Template Improvement**: [What should be fixed in template]

**Issue 2**: [Brief description]
- [Same format]
```

### If No Issues
If no issues were encountered, add:
```markdown
## Template Processing Issues

No issues encountered during template processing. All files were successfully filled out using the write tool (not search_replace).
```

## Completion Checklist

Before finishing, verify:
- [ ] INCIDENT_SUMMARY.md - All sections filled, no placeholders, complete file written (not search_replace)
- [ ] ANALYSIS.md - Includes specific examples with conversation excerpts, complete file written (not search_replace)
- [ ] NUANCED_FACTORS.md - All themes filled with relevant considerations, complete file written (not search_replace)
- [ ] USER_OBSERVATIONS_AND_QUESTIONS.md - User observations extracted from conversation, complete file written (not search_replace)
- [ ] QUICK_REFERENCE.md - All sections filled with actual content, complete file written (not search_replace)
- [ ] README.md - Updated with incident details, evidence checklist completed, processing issues documented, complete file written (not search_replace)
- [ ] No template helper files included in filled-out folder
- [ ] All processing issues documented in README.md
- [ ] All placeholders replaced with actual content

## Key Principles

1. **WRITE Complete Files**: Always write complete files, not search_replace on template files - prevents "string not found" errors
2. **Comprehensive Documentation**: Document everything thoroughly - this is the "freeze state" moment
3. **Root Cause Focus**: Don't just document symptoms - analyze why things happened
4. **Preserve User Voice**: Capture user observations/questions exactly as provided
5. **Defer Analysis**: User questions are for later - just document them now
6. **Nuanced Thinking**: Consider balance questions, not just "make it stricter"
7. **Concrete Evidence**: Include specific examples, quotes, commands, and outputs - not just descriptions
8. **Complete All Sections**: Never leave placeholders - fill out all sections even if user didn't explicitly provide information

## When User Returns for Analysis

### Step 1: Brief the User (ALWAYS DO THIS FIRST)

When the user drops this filled-out folder in a later conversation, **first provide a comprehensive briefing**:

1. **Incident Summary**
   - What the incident was (from INCIDENT_SUMMARY.md)
   - When it occurred
   - Context of what was happening

2. **AI's Understanding of the Issue**
   - Core problem identified
   - Key root causes (from ANALYSIS.md)
   - What worked vs. what didn't work

3. **User's Observations and Questions**
   - List all observations from USER_OBSERVATIONS_AND_QUESTIONS.md
   - List all questions the user wanted to explore
   - Show user's expectations vs. actual behavior

4. **Important Points from Documentation**
   - Status from README.md (what's been completed)
   - Key findings from ANALYSIS.md
   - Philosophical considerations from NUANCED_FACTORS.md
   - Next steps that were identified

5. **Current State**
   - What's been documented
   - What still needs to be addressed
   - What questions are pending

**Format the briefing clearly** so the user can quickly understand where things stand and what needs to be explored.

### Step 2: Proceed with Analysis (If Requested)

If the user asks to proceed with analysis after the briefing:
- Address each question in USER_OBSERVATIONS_AND_QUESTIONS.md
- Update ANALYSIS.md with answers
- Propose solutions and fixes
- Update status in README.md

