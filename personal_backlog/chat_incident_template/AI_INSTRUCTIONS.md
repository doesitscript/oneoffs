# AI Instructions for Processing This Template

**For the AI**: When this template folder is dropped into a chat with user observations/questions, follow these instructions:

## Your Role

You are documenting an incident that occurred in a conversation. The user has **stopped giving instructions** to freeze the current state and wants you to document everything comprehensively.

## What You Should Do

### 1. Analyze the Conversation History
- Review the most recent conversation history
- Identify what the user asked for
- Identify what you (the AI) did
- Identify what went wrong or didn't work as expected
- Look for patterns, root causes, and contributing factors

### 2. Fill Out the Template Documents

#### INCIDENT_SUMMARY.md
- Document the high-level overview
- List what worked (✅) and what didn't (❌)
- Identify root causes at a summary level
- Note key findings

#### ANALYSIS.md
- Provide detailed technical analysis
- Show what should have happened vs. what actually happened
- Deep dive into root causes
- Provide recommendations
- Consider implementation constraints

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
- Note related files

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

## Key Principles

1. **Comprehensive Documentation**: Document everything thoroughly - this is the "freeze state" moment
2. **Root Cause Focus**: Don't just document symptoms - analyze why things happened
3. **Preserve User Voice**: Capture user observations/questions exactly as provided
4. **Defer Analysis**: User questions are for later - just document them now
5. **Nuanced Thinking**: Consider balance questions, not just "make it stricter"

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

