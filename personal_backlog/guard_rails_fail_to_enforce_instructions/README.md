# Guard Rails Fail to Enforce Instructions - Chat Incident Documentation

This folder contains documentation and files related to an incident where AI guardrails failed to enforce explicit instructions, allowing the AI to add unrequested details to commit messages and struggle with git workflow despite clear step-by-step instructions.

## Contents

- `INCIDENT_SUMMARY.md` - High-level summary of what happened
- `ANALYSIS.md` - Detailed analysis of the problem and root causes
- `NUANCED_FACTORS.md` - **Important**: Subtle factors, philosophical considerations, balance questions
- `USER_OBSERVATIONS_AND_QUESTIONS.md` - **User-provided**: Observations, questions, and expectations captured during incident documentation (to be addressed later)
- `QUICK_REFERENCE.md` - Quick summary for future reference
- `AI_INSTRUCTIONS.md` - Instructions for AI on how to process this template (for reference)
- `PROMPT_TEMPLATE.md` - Ready-to-use prompts for documenting incidents
- `TEMPLATE_USAGE.md` - Detailed guide on using this template

## Key Documents

- **NUANCED_FACTORS.md** - Contains the philosophical considerations and balance questions that are critical for addressing this without creating overly rigid rules.
- **USER_OBSERVATIONS_AND_QUESTIONS.md** - Contains the user's observations and questions that were documented during incident capture but are to be addressed in a later analysis session.

## Key Issue

AI guardrails failed to prevent the AI from adding unrequested details to a commit message when explicit instructions stated "Commit with message: 'Initial account vending'" and from struggling with git workflow despite clear step-by-step instructions.

## Status

- [x] Root cause analysis complete
- [ ] Solutions identified
- [ ] Implementation needed
- [ ] Testing required

## Related Files (Outside This Folder)

- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/shared-services-account-start-workflow.tf` - Workflow template with git instructions that were not followed
- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/GIT_WORKFLOW_INSTRUCTIONS.md` - Improved git workflow instructions created after the incident
- `/Users/a805120/develop/aft-account-request/terraform/` - Target directory where Terraform files were to be committed

## Conversation Export

The full conversation about this incident should be exported separately and added to this folder.

## How to Use This Template

### When an Incident Occurs:

1. **Stop the current conversation** - Don't continue giving instructions that might muddy the problem
2. **Drop this template folder** into a new chat (or the same chat after stopping)
3. **Include your observations and questions** - Add any concerns, questions, or observations you want documented but not explored immediately
4. **Let AI fill out the template** - The AI will analyze the conversation history and document the incident
5. **Come back later** - In another conversation, drop this filled-out folder again to analyze and fix

### Template Processing:

When you drop this template folder with your observations/questions:
- AI will document your observations in `USER_OBSERVATIONS_AND_QUESTIONS.md`
- AI will analyze the conversation and fill out `INCIDENT_SUMMARY.md`, `ANALYSIS.md`, and `NUANCED_FACTORS.md`
- AI will integrate relevant points from your observations into the analysis documents
- Your questions will be preserved for later analysis and resolution

### For Later Analysis:

1. Drop the filled-out folder (no longer a template) into a new conversation
2. Ask for a briefing: "Brief me on this incident - catch me up to speed"
   - AI will summarize where you were, what the issue was, and what you wanted to explore
   - AI will show important points from the documentation
3. Review the briefing to get caught up
4. Address the questions in `USER_OBSERVATIONS_AND_QUESTIONS.md`
5. Work on solutions and fixes
