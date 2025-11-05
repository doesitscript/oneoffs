# Guard Rails Fail to Enforce Instructions (2nd Pass) - Incident Summary

**Date**: 2025-01-28  
**Context**: User requested execution of AFT account request workflow that included generating Terraform files and committing them to git with specific instructions for commit messages and branch creation.

## Conversation Context

**What was being worked on**: Executing the workflow defined in `shared-services-account-start-workflow.tf` to generate Terraform files from CSV input and commit them to git with explicit instructions.

**Key background**: The workflow template contained explicit step-by-step instructions including exact commit message text and sequential git workflow steps.

**User's goal**: Execute the workflow to generate 4 Terraform files and commit each to a separate git branch following the explicit instructions provided.

## What Happened

User requested execution of workflow that generated Terraform files and required git commits. The workflow template contained explicit instructions:
1. Commit message: "Initial account vending" (exact text specified)
2. Git workflow: Clear step-by-step instructions for creating branches and committing files

**What the AI did**:
1. ✅ Generated Terraform files correctly
2. ✅ Created git branches as instructed
3. ❌ Added extensive details to commit messages beyond what was specified
4. ❌ Committed multiple files on first branch instead of one file per branch
5. ❌ Struggled with git workflow, requiring multiple attempts to fix

**What went wrong**:
- Commit messages included unrequested details about "fixes" and "improvements" when instruction explicitly said: `git commit -m "Initial account vending"`
- Git workflow was not followed correctly - committed all files on first branch, then struggled to create separate branches for each file
- Guardrails that should enforce explicit instructions did not prevent this behavior

## Root Causes Identified

### 1. Guardrail Failure: Explicit Instruction Not Enforced
- **Detection**: ❌ Guardrails did not detect that commit message deviated from explicit instruction
- **Compliance**: ❌ AI did not comply with exact text specified in instructions
- **Result**: Commit messages contained unrequested details despite explicit instruction to use exact text "Initial account vending"

### 2. Inference Override: Adding Context When Not Requested
- **Detection**: ❌ No detection that AI was inferring/adding details beyond explicit instructions
- **Compliance**: ❌ AI added contextual information about "fixes" that was not requested
- **Result**: Commit messages became verbose when simple message was explicitly requested

### 3. Workflow Instruction Complexity: Not Following Sequential Steps
- **Detection**: ❌ Did not detect that workflow steps were not being followed in correct sequence
- **Compliance**: ❌ Committed multiple files at once instead of following "one file per branch" pattern
- **Result**: Required multiple correction attempts and branch resets

## Key Findings

### What Is Working:
- ✅ AI correctly generated Terraform files from YAML input
- ✅ AI correctly parsed CSV and generated YAML configuration
- ✅ AI correctly grouped accounts by shortname into single files
- ✅ AI identified the problem when questioned by user
- ✅ AI created improved workflow instructions after the incident

### What Is NOT Working:
- ❌ Guardrails do not enforce strict adherence to explicit textual instructions
- ❌ AI infers and adds details when explicit instructions provide exact text to use
- ❌ AI does not follow sequential workflow steps correctly when instructions are complex
- ❌ No mechanism to detect when AI behavior deviates from explicit instructions

## What Needs to Be Addressed

1. **Guardrail Enforcement**: Need mechanism to detect when explicit instructions contain exact text/formats that must be used verbatim
2. **Inference Control**: Need to prevent AI from adding context/details when explicit instructions provide exact text
3. **Workflow Compliance**: Need better adherence to sequential step-by-step instructions, especially for git workflows
4. **Instruction Parsing**: Need to distinguish between "use this format" vs "use this exact text" in instructions

## Timeline of Events

1. **User Request**: "do this @shared-services-account-start-workflow.tf"
2. **AI Execution**: Generated Terraform files correctly, then attempted git commits
3. **First Mistake**: Committed all 4 files on first branch with extended commit message
4. **Correction Attempts**: Multiple attempts to fix branch structure using cherry-pick (failed)
5. **User Observation**: User pointed out guardrails should have prevented this
6. **AI Acknowledgment**: AI acknowledged guardrail failure and instruction violation
7. **Final Fix**: Branches recreated correctly from main, one file per branch

## Files Referenced

- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/shared-services-account-start-workflow.tf` - Contains explicit git workflow instructions (lines 121-135, updated after incident)
- `/Users/a805120/develop/workflows/.scratch/aft-account-request/in_progress/GIT_WORKFLOW_INSTRUCTIONS.md` - Improved instructions created after incident
- `/Users/a805120/develop/aft-account-request/terraform/` - Target directory where Terraform files were committed

## Questions to Address Later

**Note**: User-provided questions and observations are documented in `USER_OBSERVATIONS_AND_QUESTIONS.md`. These questions should be addressed during the analysis phase.

1. Why didn't guardrails prevent AI from inferring/adding details when explicit instructions existed?
2. Should guardrails be more strict about enforcing exact text when instructions provide it?
3. How can we distinguish between "use this format" vs "use this exact text" in instructions?
4. What balance is needed between helpful context and strict adherence to explicit instructions?

**See also**: `USER_OBSERVATIONS_AND_QUESTIONS.md` for detailed user questions and expectations

## Next Steps

- [x] Analyze root causes of guardrail failure
- [x] Identify solutions for enforcing explicit instructions
- [x] Document user observations and questions
- [ ] Design mechanism to distinguish "exact text" vs "format/pattern" instructions
- [ ] Test guardrail improvements with similar scenarios
- [ ] Update workflow instructions to be more explicit about verbatim requirements
