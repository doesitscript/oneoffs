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

#### INCIDENT_SUMMARY.md
- Document the high-level overview
- **Extract complete date** from conversation (format: YYYY-MM-DD, not XX)
- **Include conversation context**: what was being worked on, user's goal, background
- **Create timeline** of events if sequence is important
- List what worked (✅) and what didn't (❌)
- Identify root causes at a summary level
- Note key findings
- **Include file paths with line numbers** when referencing code/instructions

#### ANALYSIS.md
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
- **Document ALL user observations** from their message
- **Capture ALL user questions** exactly as provided
- Preserve the user's expectations vs. actual behavior
- Organize by category if helpful
- **DO NOT explore or answer the questions yet** - just document them

#### QUICK_REFERENCE.md
- Create a concise summary
- Include key points for quick lookup
- Link to detailed documents

### 3. Integration of User Observations

- **Integrate relevant points** from user observations into ANALYSIS.md where they relate to root causes
- **Reference user questions** in NUANCED_FACTORS.md where they relate to philosophical considerations
- **DO NOT** try to answer the questions yet - the user wants to address them in a later analysis session

### 4. Update README.md
- Replace placeholder text with actual incident name and description
- Update status checkboxes
- Note related files with line numbers when applicable
- Update evidence checklist if applicable

## What You Should NOT Do

- ❌ **DO NOT explore or answer** the user's questions from USER_OBSERVATIONS_AND_QUESTIONS.md yet
- ❌ **DO NOT continue** the conversation that led to the incident
- ❌ **DO NOT make assumptions** beyond what's in the conversation history
- ❌ **DO NOT skip** documenting user observations - they're critical for later analysis

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

## Key Principles

1. **Comprehensive Documentation**: Document everything thoroughly - this is the "freeze state" moment
2. **Root Cause Focus**: Don't just document symptoms - analyze why things happened
3. **Preserve User Voice**: Capture user observations/questions exactly as provided
4. **Defer Analysis**: User questions are for later - just document them now
5. **Nuanced Thinking**: Consider balance questions, not just "make it stricter"
6. **Concrete Evidence**: Include specific examples, quotes, commands, and outputs - not just descriptions

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

