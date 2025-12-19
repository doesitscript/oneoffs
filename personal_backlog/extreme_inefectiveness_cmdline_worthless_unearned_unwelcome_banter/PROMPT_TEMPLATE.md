# Chat Incident Documentation Prompt Template

Copy and paste this prompt into a chat window when you want to document an incident:

---

## Standard Template (With User Observations)

```
@chat_incident_template/ I need to document an incident that occurred during our conversation. 
I've stopped giving instructions so we can freeze the current state and document the problem.

**Incident Name**: [Brief name for the incident]

**Date**: [Date when it occurred]

**Context**: [What task or conversation was happening - e.g., "User asked to verify data in image matches CSV file"]

**What Happened**:
- User asked: [What the user requested]
- AI did: [What the AI actually did]
- Problem: [What went wrong or didn't work as expected]

**Key Issues**:
1. [Issue 1]
2. [Issue 2]
3. [Issue 3]

**Related Files** (if any):
- [Path to relevant files with line numbers if applicable]

**Evidence Available** (if applicable):
- [ ] Conversation excerpts showing the problem
- [ ] Actual commands/outputs
- [ ] Error messages
- [ ] File paths with line numbers
- [ ] Screenshots or logs

**My Observations and Questions** (to be documented but not explored now - we'll address these later):

[Your observations, questions, expectations, and concerns go here. 
These will be captured in USER_OBSERVATIONS_AND_QUESTIONS.md for later analysis.
Example format below - adapt as needed:]

----
"[Observation 1] <-- [Your note about what you expected or observed]

[Observation 2] <-- [Your note]

[Question 1] <-- [Your question or concern]

[Question 2] <-- [Your question]
----

Please help me fill out the complete incident documentation using the template structure:
- Analyze the most recent conversation history
- Document your findings in INCIDENT_SUMMARY.md, ANALYSIS.md, and NUANCED_FACTORS.md
- Capture my observations and questions in USER_OBSERVATIONS_AND_QUESTIONS.md
- Integrate relevant points from my observations into the analysis documents
- Focus on root cause analysis, not just symptoms
- Consider the philosophical balance questions and what useful behaviors might have become problematic in this specific context

Do NOT explore the questions I've provided yet - just document them for later analysis.
```

---

## Alternative: Quick Version (With Observations)

For a simpler prompt with observations:

```
@chat_incident_template/ I've stopped giving instructions. Document the incident we just discussed: [brief description]. 

**My observations/questions to document** (address later):
----
[Your observations and questions here]
----

Use the template structure to create a complete analysis. Document my observations in USER_OBSERVATIONS_AND_QUESTIONS.md but don't explore them yet.
```

---

## Alternative: Based on Conversation History

If you want to document based on the current conversation:

```
@chat_incident_template/ I've stopped the conversation to freeze the state. Based on our conversation, create a complete incident analysis using the template structure. 

**Incident**: [describe what happened]

**My observations/questions** (document but don't explore):
----
[Your observations and questions]
----

Analyze root causes, not just symptoms, include nuanced considerations, and capture my observations for later analysis.
```

---

## For Later Analysis (When Returning to Documented Incident)

When you're ready to analyze and fix the incident, drop the folder and ask for a briefing:

```
@[incident-folder-name]/ Brief me on this incident - catch me up to speed.
```

Or if you want to jump straight to analysis:

```
@[incident-folder-name]/ I'm ready to analyze this incident and address the questions. 

Please:
1. First, brief me: summarize where we were, what the issue was, and what I wanted to explore
2. Then address each question in USER_OBSERVATIONS_AND_QUESTIONS.md
3. Update ANALYSIS.md with answers to the questions
4. Propose solutions and fixes
5. Update the status in README.md
```

**What the briefing should include:**
- Summary of the incident (what happened)
- What the AI understands the core issue to be
- Key root causes identified
- Your observations and questions from USER_OBSERVATIONS_AND_QUESTIONS.md
- Important points from the template documents (status, next steps, etc.)
- Current state of the incident documentation
