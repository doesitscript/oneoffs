# Chat Incident Template - Usage Guide

This template folder is designed to help you quickly document and analyze chat incidents in a structured, comprehensive way.

## Quick Start

1. **Copy this folder** to create a new incident documentation folder:
   ```bash
   cp -r chat_incident_template [incident-name]
   ```

2. **Fill in the templates** - Replace all `[PLACEHOLDER]` text with actual incident details

3. **Start with INCIDENT_SUMMARY.md** - Get the high-level overview documented first

4. **Work through ANALYSIS.md** - Deep dive into technical details

5. **Don't skip NUANCED_FACTORS.md** - This captures the important philosophical considerations

6. **Use QUICK_REFERENCE.md** - For future quick lookups

## Template Structure

### README.md
- Overview of the incident folder
- Points to key documents
- Lists related files
- Status tracking

### INCIDENT_SUMMARY.md
- High-level overview
- What happened (brief)
- Root causes (summary)
- Key findings
- Next steps

### ANALYSIS.md
- Detailed technical analysis
- What should have happened vs. what did
- Root cause deep dive
- Recommendations
- Implementation considerations

### NUANCED_FACTORS.md
- Philosophical considerations
- Balance questions
- Design trade-offs
- Context-specific considerations
- Questions for future development

### QUICK_REFERENCE.md
- One-page summary
- Key points for quick lookup
- Links to detailed docs

## Best Practices

1. **Be thorough in ANALYSIS.md** - This is where the real learning happens
2. **Don't skip nuances** - The NUANCED_FACTORS.md is critical for avoiding over-correction
3. **Include actual examples** - Show what happened vs. what should have happened
4. **Capture context** - What was the user trying to do? What conversation led to this?
5. **Document related files** - Note any config files, code, or data that's relevant
6. **Export conversation** - Add the full conversation transcript for complete context

## When to Use This Template

Use this template for:
- ✅ Guardrail/validation issues
- ✅ Unexpected AI behavior
- ✅ False claims or verification problems
- ✅ Format compliance issues
- ✅ System design problems
- ✅ Context/search problems (like Memory MCP not finding relevant context)
- ✅ Any incident where you want to understand root causes deeply

## Workflow: Freeze, Document, Analyze Later

### Step 1: Freeze the Incident
When you detect an incident:
1. **Stop giving instructions** - Don't continue the conversation that might muddy the problem
2. **Note your observations** - Write down what you expected vs. what happened, your questions
3. **Prepare to drop the template** - Have the template folder ready

### Step 2: Document the Incident
1. **Drop the template folder** into a chat (new chat or same chat after stopping)
2. **Include your observations/questions** in the same message
3. **Let AI process** - AI will:
   - Analyze the conversation history
   - Fill out INCIDENT_SUMMARY.md, ANALYSIS.md, NUANCED_FACTORS.md
   - Capture your observations in USER_OBSERVATIONS_AND_QUESTIONS.md
   - Integrate relevant points into analysis documents
   - NOT explore your questions yet (just document them)

### Step 3: Analyze Later (Different Session)
1. **Drop the filled-out folder** into a new conversation
2. **Ask for a briefing** - AI will summarize:
   - Where you were at
   - What the issue was
   - What you wanted to explore (from USER_OBSERVATIONS_AND_QUESTIONS.md)
   - Important points from the documentation
3. **Review the briefing** - Get caught up to speed
4. **Address the questions** - Work through USER_OBSERVATIONS_AND_QUESTIONS.md
5. **Propose solutions** - Update analysis documents with answers
6. **Implement fixes** - Based on the analysis

## Documenting User Observations and Questions

### Why This Matters
When you detect an incident, you often have:
- **Observations** about what you expected vs. what happened
- **Questions** about why things didn't work as expected
- **Context** about what you were trying to accomplish
- **Concerns** about related systems or behaviors

These are valuable but you may not want to explore them immediately - you want to **freeze the state** and document everything first.

### How to Include Observations
When dropping the template folder, include a section like:

```
**My Observations and Questions** (document but don't explore):

----
"[Observation about context not being understood] <-- [Your note about what you expected]

[Observation about search results] <-- [Your note about what should have happened]

[Question about why Memory MCP didn't capture this] <-- [Your question]

[Question about why recent context wasn't prioritized] <-- [Your question]
----
```

### What AI Will Do
- **Document** all your observations in USER_OBSERVATIONS_AND_QUESTIONS.md
- **Integrate** relevant points into ANALYSIS.md and NUANCED_FACTORS.md
- **Preserve** your questions for later analysis
- **NOT explore** them immediately (just document)

### Template Customization

Feel free to:
- Add additional sections specific to your incident type
- Remove sections that don't apply
- Add data files, screenshots, or other artifacts
- Create additional analysis documents as needed

## Filling Out the Template

### Step 1: Basic Information
- Update README.md with incident name and brief description
- Fill in date and context in INCIDENT_SUMMARY.md

### Step 2: What Happened
- Document what the user asked
- Document what the AI did
- Document what went wrong
- Use ✅/❌ markers for clarity

### Step 3: Root Cause Analysis
- Identify primary causes
- Document detection vs. enforcement gaps
- Note format mismatches or logic errors
- Consider contextual factors

### Step 4: Nuanced Considerations
- Think about useful behaviors that became problematic
- Consider advisory vs. enforcement philosophy
- Document different scenario types
- Capture balance questions

### Step 5: Recommendations
- Propose specific fixes
- Consider trade-offs
- Note implementation constraints
- Balance flexibility with enforcement

## Example Prompts to Generate This Documentation

When you want to document an incident, you can use a prompt like:

```
@chat_incident_template/ I need to document an incident where [describe what happened]. 
Please help me fill out the template based on this conversation:
[attach relevant conversation or describe incident]
```

Or:

```
Based on our conversation, I'd like you to create a complete incident analysis 
using the chat_incident_template structure. The incident was: [describe]
```

## Tips for Effective Incident Documentation

1. **Be specific** - Use exact quotes, examples, and file paths
2. **Show, don't just tell** - Include before/after examples
3. **Think about balance** - Not every issue needs a strict rule
4. **Consider context** - What was useful behavior that became problematic?
5. **Document questions** - Not everything needs immediate answers
6. **Track status** - Update the README checkboxes as you progress

