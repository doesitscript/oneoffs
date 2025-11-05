# Guard Rails Fail to Enforce Instructions (2nd Pass) - Chat Incident Documentation

This folder contains documentation and files related to an incident where AI guardrails failed to enforce explicit instructions when executing a git workflow. The AI added unrequested details to commit messages and struggled with sequential git operations despite explicit step-by-step instructions providing exact text and clear workflow patterns.

## Contents

- `INCIDENT_SUMMARY.md` - High-level summary of what happened
- `ANALYSIS.md` - Detailed analysis of the problem and root causes
- `NUANCED_FACTORS.md` - **Important**: Subtle factors, philosophical considerations, balance questions
- `USER_OBSERVATIONS_AND_QUESTIONS.md` - **User-provided**: Observations, questions, and expectations captured during incident documentation (to be addressed later)
- `QUICK_REFERENCE.md` - Quick summary for future reference
- `AI_INSTRUCTIONS.md` - Instructions for AI on how to process this template (for reference)
- `PROMPT_TEMPLATE.md` - Ready-to-use prompts for documenting incidents
- `TEMPLATE_USAGE.md` - Detailed guide on using this template
- `TEMPLATE_EVALUATION.md` - Evaluation of template quality and improvement recommendations (based on filled-out example)
- `TEMPLATE_ACTIONS.md` - **User prompts for triggering actions** (AI should ignore this when filling out template)
- `[RELEVANT_CONFIG_FILES]` - Related configuration or documentation files
- `[DATA_FILES]` - Any data files, prompts, or artifacts related to the incident

## Key Documents

- **NUANCED_FACTORS.md** - Contains the philosophical considerations and balance questions that are critical for addressing this without creating overly rigid rules.
- **USER_OBSERVATIONS_AND_QUESTIONS.md** - Contains the user's observations and questions that were documented during incident capture but are to be addressed in a later analysis session.

## Key Issue

AI guardrails failed to enforce explicit textual instructions when the instructions provided exact text (commit message) and clear sequential steps (git workflow). The AI added unrequested details to commit messages and committed multiple files on one branch instead of following the explicit "one file per branch" sequential pattern.

## Status

- [x] Root cause analysis complete
- [x] Solutions identified
- [x] User observations documented
- [ ] Implementation needed
- [ ] Testing required

## Related Files (Outside This Folder)

- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/shared-services-account-start-workflow.tf` (lines 121-135) - Workflow template with explicit git workflow instructions
- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/GIT_WORKFLOW_INSTRUCTIONS.md` - Improved instructions created after incident
- `/Users/a805120/develop/aft-account-request/terraform/` - Target directory where Terraform files were committed

## Conversation Export

- [ ] Conversation exported to `conversation_export.md` or similar file
- [ ] Or: Conversation reference included: [Link or identifier if available]
- [ ] Or: Key conversation excerpts included in ANALYSIS.md

**Note**: At minimum, include key conversation excerpts in ANALYSIS.md showing the problem.

## Evidence Included

- [x] Conversation excerpts/quotes showing the problem (in ANALYSIS.md)
- [x] Actual commands executed (in ANALYSIS.md)
- [x] Error messages or unexpected outputs (in ANALYSIS.md)
- [x] Before/after comparisons (commit messages in ANALYSIS.md)
- [x] File paths with line numbers for code references (in INCIDENT_SUMMARY.md and ANALYSIS.md)
- [ ] Screenshots or logs (if applicable)

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

