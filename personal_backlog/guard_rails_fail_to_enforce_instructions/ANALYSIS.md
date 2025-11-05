# Guard Rails Fail to Enforce Instructions - Detailed Analysis

## The Problem

AI guardrails failed to enforce explicit instructions when the instructions provided exact text or clear sequential steps. The AI added unrequested details to commit messages and did not follow sequential workflow steps correctly, despite explicit instructions that should have been followed verbatim.

1. **Explicit Text Not Enforced**: Instructions provided exact commit message text `"Initial account vending"` but AI added extensive unrequested details
2. **Sequential Workflow Not Followed**: Clear step-by-step instructions for git workflow were not executed in correct sequence
3. **No Guardrail Detection**: No mechanism detected or prevented deviation from explicit instructions

## What Should Have Happened

### Correct Behavior/Format:

**Commit Message**:
```
git commit -m "Initial account vending"
```

**Git Workflow Sequence** (for each file):
```
1. git checkout main
2. git checkout -b feat/initial_vending_<filename>
3. git add terraform/<filename>
4. git commit -m "Initial account vending"
5. git checkout main
6. Repeat steps 1-5 for next file
```

When instructions contain:
- Exact text in quotes: Use that text verbatim
- Sequential steps: Follow them in order, one at a time
- Explicit "DO NOT" statements: Do not perform those actions

## What Actually Happened

**Commit Messages Created**:
```
git commit -m "Initial account vending: Zerto account

Generated from CSV workflow with the following fixes:
- Properly formatted ManagedOrganizationalUnit: \"Shared Services (ou-uieo-w14lfx7l)\"
- account_customizations_name placed outside custom_fields block (correct pattern)
- All account names converted to lowercase per AFT standards
- change_requested_by uses actual owner name (aaron bennett) instead of placeholder
- Empty env handled correctly (no \"-ENV\" suffix for zerto account)
- VPC configuration with proper regions and subnet settings"
```

**Git Workflow Executed**:
- Committed all 4 files on first branch (`feat/initial_vending_sharedservices_zerto_account`)
- Attempted to cherry-pick files to other branches (failed)
- Required multiple correction attempts with branch resets
- Eventually corrected by creating branches from main and adding one file at a time

**What Was Missing**:
- Detection that commit message deviated from explicit instruction
- Adherence to sequential workflow pattern
- Recognition that exact text in quotes should be used verbatim

## Why This Happened

### 1. Guardrail Design: No Explicit Text Detection
- **Description**: Guardrails are designed to detect violations of rules and guidelines, but they don't have specific logic to detect when explicit textual instructions are being modified or extended
- **Technical reason**: The guardrail system likely checks for rule violations (e.g., "don't use placeholder text") but doesn't check if the AI is using exact text when it's explicitly provided
- **Nuance**: This is a gap in guardrail design - they enforce "don't do X" but don't enforce "do exactly Y" when Y is explicitly provided

### 2. Inference Override: Helpful Behavior Becoming Problematic
- **Description**: The AI's tendency to add helpful context and details (which is valuable in many scenarios) overrode the explicit instruction to use exact text
- **Technical reason**: The AI interpreted the instruction as "use this format/pattern" rather than "use this exact text verbatim", leading to inference that additional details would be helpful
- **Nuance**: This is useful behavior in many contexts (adding context is helpful), but it conflicts with explicit textual instructions. The AI needs to distinguish between "format guidance" and "exact text requirement"

### 3. Instruction Parsing: Format vs. Exact Text Ambiguity
- **Description**: The AI's instruction parser doesn't clearly distinguish between "use this format" (flexible) vs. "use this exact text" (strict) instructions
- **Technical reason**: When instructions contain text in quotes, the AI may interpret it as an example or pattern rather than a verbatim requirement
- **Nuance**: This requires better instruction parsing to detect when text should be used verbatim vs. when it's a format guide. Quotes alone aren't sufficient - need context markers like "EXACT" or "verbatim"

### 4. Sequential Workflow Complexity: Batch Processing Tendency
- **Description**: The AI treated the sequential workflow as a batch operation, committing all files at once instead of following the iterative pattern
- **Technical reason**: The AI may optimize for efficiency by batching operations, but this conflicts with explicit sequential instructions
- **Nuance**: Batching is often more efficient, but when instructions explicitly state a sequential pattern, it should be followed. The AI needs to recognize when sequential execution is required vs. when batching is acceptable

### 5. Guardrail Scope: Rules vs. Instructions
- **Description**: Guardrails are designed to enforce system rules and guidelines, but explicit user instructions in workflow templates may not be in the guardrail scope
- **Technical reason**: Guardrails may focus on system-level rules (don't use placeholders, verify claims) but not user-provided explicit instructions in templates
- **Nuance**: This is a scope question - should guardrails enforce all explicit instructions, or only system rules? Probably both, but with different mechanisms

## Key Insights

1. **Instruction Type Detection Needed**: The system needs to distinguish between:
   - **Format instructions**: "Use this format" (flexible, allows inference)
   - **Exact text instructions**: "Use this exact text" (strict, verbatim required)
   - **Pattern instructions**: "Follow this pattern" (flexible structure, exact values vary)

2. **Guardrail Scope Expansion**: Guardrails should enforce explicit user instructions, not just system rules. When instructions provide exact text, guardrails should detect deviations.

3. **Sequential vs. Batch Recognition**: The system needs to recognize when instructions require sequential execution vs. when batching is acceptable. Explicit step-by-step instructions should trigger sequential mode.

4. **Inference Control**: While helpful inference is valuable, it needs to be disabled or limited when explicit instructions provide exact text. The AI should have a "verbatim mode" for explicit textual instructions.

5. **Instruction Clarity vs. Enforcement**: While improving instruction clarity helps, the core issue is enforcement. Even unclear instructions with explicit text should be followed verbatim when that text is provided.

## Recommendations

1. **Explicit Text Detection**: Implement guardrail logic to detect when instructions contain exact text (e.g., in quotes with context like "EXACT" or "verbatim") and enforce verbatim usage
   - **But**: Don't make this too rigid - we still want helpful inference in other contexts
   - **Consider**: Using instruction markers like `@EXACT: "text"` or `@VERBATIM: "text"` to signal strict enforcement

2. **Guardrail Enhancement**: Expand guardrail scope to include user-provided explicit instructions in workflow templates, not just system rules
   - **Include**: Detection of explicit text in instructions
   - **Maintain**: Existing rule enforcement capabilities

3. **Instruction Parser Improvement**: Enhance instruction parsing to distinguish between:
   - Format/pattern instructions (flexible)
   - Exact text instructions (strict)
   - Sequential workflow instructions (must follow order)
   - **Clarify**: What markers or patterns indicate each type
   - **Distinguish**: Between "use this format" and "use this exact text"

4. **Sequential Mode**: Implement a "sequential execution mode" that triggers when instructions contain explicit step numbers or sequential patterns
   - **Include**: Detection of step-by-step instructions (numbered steps, "then", "next", "repeat")
   - **Maintain**: Ability to batch when not explicitly sequential

5. **Inference Control**: Add mechanism to disable helpful inference when explicit text is provided
   - **Include**: Detection of exact text requirements
   - **Maintain**: Helpful inference in other contexts

## Implementation Considerations

- **Balance**: Balance strict enforcement with helpful behavior. Don't make system too rigid - we still want helpful inference when appropriate.
- **Flexibility**: Maintain flexibility for different instruction types. Not all instructions should be enforced strictly.
- **Consistency**: Ensure consistent behavior across different types of explicit instructions (commit messages, file names, code blocks, etc.).
- **Context**: Distinguish between contexts where inference is helpful vs. where exact text is required. Workflow templates may need stricter enforcement than general conversation.
