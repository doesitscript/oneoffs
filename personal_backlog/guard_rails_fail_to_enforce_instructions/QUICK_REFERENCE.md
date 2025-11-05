# Quick Reference - Guard Rails Fail to Enforce Instructions

## What Happened
AI guardrails failed to prevent the AI from adding unrequested details to commit messages and struggling with git workflow despite explicit instructions providing exact text and clear sequential steps.

## Root Causes
1. **Guardrail Gap**: No mechanism to detect when explicit textual instructions are being modified or extended
2. **Inference Override**: Helpful inference behavior (adding context) overrode explicit instruction to use exact text
3. **Instruction Parsing**: System doesn't distinguish between "use this format" vs. "use this exact text" instructions
4. **Sequential Workflow**: AI treated sequential steps as batch operation instead of following iterative pattern
5. **Guardrail Scope**: Guardrails enforce system rules but not user-provided explicit instructions in templates

## Key Files
- `INCIDENT_SUMMARY.md` - Overview of the incident
- `ANALYSIS.md` - Detailed technical analysis and recommendations
- `NUANCED_FACTORS.md` - Philosophical considerations and balance questions
- `USER_OBSERVATIONS_AND_QUESTIONS.md` - User's observations and questions (to be addressed later)
- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/shared-services-account-start-workflow.tf` - Workflow template with instructions
- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/GIT_WORKFLOW_INSTRUCTIONS.md` - Improved instructions created after incident

## What Needs Fixing
1. **Explicit Text Detection**: Implement guardrail logic to detect and enforce verbatim usage when exact text is provided
2. **Guardrail Scope**: Expand to include user-provided explicit instructions, not just system rules
3. **Instruction Parser**: Distinguish between format/pattern instructions (flexible) vs. exact text instructions (strict)
4. **Sequential Mode**: Implement sequential execution mode for step-by-step instructions
5. **Inference Control**: Disable helpful inference when explicit text requirements are detected

## Conversation Export
Full conversation should be exported and added here for complete context.

## Template Usage Notes
- Replace all `[PLACEHOLDER]` text with actual incident information
- This is a quick reference - keep it concise
- Add links to other documents for detailed information
