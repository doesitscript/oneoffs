# User Observations and Questions

**Purpose**: This document captures the user's observations, questions, and concerns that were documented during the incident but not explored immediately. These are items to be addressed in a later analysis session.

## Usage

When you drop this template folder into a chat to document an incident, you can include additional observations and questions in your message. The AI will:

1. **Document** these observations here without exploring them immediately
2. **Integrate** relevant points into the ANALYSIS.md and NUANCED_FACTORS.md
3. **Preserve** your questions for later analysis and resolution

## User's Observations

### Observation Category 1: Commit Message Instructions

**"don't our guardrails prevent you from doing this. That's an explicite instruction: '3. Commit with message: \"Initial account vending\"'"**

*User's note*: The user observed that explicit instructions were provided with exact text to use for commit messages, but guardrails did not prevent the AI from adding unrequested details.

*Context*: The workflow template contained explicit step-by-step instructions including: `git commit -m "Initial account vending"`. The user expected guardrails to enforce this exact text, but the AI added extensive details about "fixes" and "improvements" that were not requested.

---

### Observation Category 2: Git Workflow Execution

**"You really had problems, switching to the branches and making sure that you had a file to commit, you really seemed lost, are you using git-mcp-server to help you"**

*User's note*: The user observed that the AI struggled significantly with the git workflow, committing multiple files on one branch instead of following the "one file per branch" pattern, and then having difficulty fixing the mistake.

*Context*: Clear step-by-step instructions were provided for creating branches and committing files. The user expected the AI to follow these steps sequentially, but the AI committed all files on the first branch and then struggled to correct the mistake.

---

### Observation Category 3: Instruction Quality

**"Are there any better instructions that would've helped you to be better at these version control steps, you were guessing alot"**

*User's note*: The user questioned whether the instructions themselves were clear enough, or if the AI was struggling due to other factors.

*Context*: The user wanted to understand if the instructions needed improvement or if the AI needed better guidance/guardrails to follow them correctly.

---

## User's Questions for Later Analysis

### Question 1: Guardrail Enforcement of Explicit Instructions

**"Don't you have guard rails that would've kept you more strictly on this path of not inferring things that have been explicitly written out"**

*User's expectation*: Guardrails should detect when explicit instructions provide exact text/formats and enforce strict adherence to those exact specifications, preventing the AI from adding inferred details.

*Actual behavior*: Guardrails did not prevent the AI from adding unrequested details to commit messages when explicit instructions provided exact text to use.

*Why this matters*: This is a fundamental issue with instruction enforcement. When users provide explicit, exact text, they expect it to be used verbatim. If guardrails don't enforce this, users cannot rely on explicit instructions being followed.

---

### Question 2: Instruction Clarity and Complexity

**"Can you look at the instructions for those steps, they are probably very verbose and hard to follow. Can you replace them with your better workflow, keep them simple like this so you don't have to guess."**

*User's expectation*: Instructions should be simple, clear, and executable without requiring inference or guessing. The user wants to improve the instructions based on what worked better.

*Actual behavior*: The AI acknowledged that the instructions were verbose and created improved, simpler instructions after the incident.

*Why this matters*: While instructions may need improvement, the core issue is that guardrails should enforce explicit instructions even if they could be clearer. However, improving instructions is also valuable for preventing future issues.

---

### Question 3: Inference vs. Explicit Instructions Balance

**"don't our guardrails prevent you from doing this. That's an explicite instruction: '3. Commit with message: \"Initial account vending\"'"**

*User's expectation*: When instructions contain explicit text in quotes (like `"Initial account vending"`), the AI should use that exact text and not add additional details.

*Actual behavior*: The AI inferred that additional details about "fixes" would be helpful and added them to the commit message, overriding the explicit instruction.

*Why this matters*: This represents a fundamental conflict between helpful inference (adding context) and strict adherence to explicit instructions. The balance needs to be clear: when explicit text is provided, use it exactly.

---

## User's Expectations vs. Actual Behavior

### Expectation 1: Exact Text Enforcement

**What user expected**: When instructions say `git commit -m "Initial account vending"`, the commit message should be exactly "Initial account vending" with no additional text.

**What actually happened**: Commit messages included extensive details like "Generated from CSV workflow with the following fixes: - Properly formatted ManagedOrganizationalUnit... - account_customizations_name placed outside custom_fields block..." etc.

**Gap**: The AI treated the explicit instruction as a format/pattern rather than exact text to use verbatim. The gap is between "use this format" interpretation vs. "use this exact text" requirement.

---

### Expectation 2: Sequential Workflow Execution

**What user expected**: The AI would follow the step-by-step git workflow instructions sequentially: create branch from main, add one file, commit, return to main, repeat for next file.

**What actually happened**: The AI committed all files on the first branch, then struggled to create separate branches for each file, requiring multiple correction attempts.

**Gap**: The AI did not follow the sequential pattern correctly, treating it as a batch operation rather than an iterative sequential process.

---

### Expectation 3: Guardrail Detection and Prevention

**What user expected**: Guardrails would detect when the AI deviates from explicit instructions and prevent the deviation, or at least warn about it.

**What actually happened**: Guardrails did not detect or prevent the deviation from explicit instructions. The AI proceeded with adding unrequested details without any guardrail intervention.

**Gap**: No mechanism existed to detect when explicit textual instructions were being modified or extended with inferred content.

---

## Additional Context from User

The user provided improved workflow instructions after the incident that emphasized:
- Always start from main for each new branch (critical detail)
- One file per branch (explicit rule)
- Use exact commit message as specified (verbatim requirement)

The user also noted that the instructions were updated to be simpler and more executable, suggesting that instruction clarity is important, but the core issue remains: guardrails should enforce explicit instructions even when they could be clearer.

---

## Status

- [x] Observations documented
- [x] Questions captured
- [x] Ready for analysis phase
- [ ] Questions answered in ANALYSIS.md
- [ ] Questions addressed in NUANCED_FACTORS.md

## Notes for Future Analysis

When analyzing this incident later:
- Review all user observations and questions
- Ensure ANALYSIS.md addresses each concern
- Check NUANCED_FACTORS.md for related philosophical considerations
- Verify that root causes explain why user expectations weren't met
- Focus on balance between helpful inference and strict adherence
- Consider how to detect "exact text" vs "format/pattern" instructions
