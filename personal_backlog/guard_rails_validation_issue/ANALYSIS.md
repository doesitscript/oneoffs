# Guard Rails Validation Issue - Detailed Analysis

## The Problem

When asked to "verify data in image matches CSV file", the AI:
1. Correctly detected "verify" as a trigger word
2. Guardrails indicated evidence was required
3. But did NOT follow the required format
4. Made false verification claims

## What Should Have Happened

### Correct Format (CLAIM → EVIDENCE → STATUS):

```
CLAIM: Account Names in CSV match the image
EVIDENCE: Image shows: Zerto, SailPointIsc-prd, SailPointIsc-dev, OpsReporting-prd, OpsReporting-qa, OpsReporting-dev, RPA-prd, RPA-uat, PRA-dev
CSV shows: Zerto, SailPointIsc-prd, SailPointIsc-dev, OpsReporting-prd, OpsReporting-qa, OpsReporting-dev, RPA-prd, RPA-uat, PRA-dev
STATUS: Verified - All 9 account names match exactly

CLAIM: OU values in CSV match the image
EVIDENCE: Image shows: "Shared Services ou-uieo-w14lfx7l" for all entries
CSV shows: "Shared Services ou-uieo-w14lfx7l" for all entries
STATUS: Verified - All OU values match

CLAIM: VPC Size values in CSV match the image
EVIDENCE: Image shows: Zerto="S", others="S /24"
CSV shows: Zerto="S", others="S /24"
STATUS: Verified - VPC sizes match

CLAIM: App Owner data in CSV matches the image
EVIDENCE: Image PR/Notes column - NOT VISIBLE in image description
CSV shows: Aaron Bennett, Deborah Tedeschi, Michael Smith, Mark Pitsick
STATUS: Unverified - Cannot verify App Owner data against image (column not visible)
```

## What Actually Happened

The AI provided a response that:
- Mixed verified and unverified claims
- Did not use the CLAIM → EVIDENCE → STATUS format
- Included App Owner data as "verified" when it couldn't be verified
- Did not clearly distinguish between what was verified vs. what was just reported

## Why This Happened

### 1. Detection vs. Enforcement
- Guardrails **detected** the trigger correctly
- Guardrails **did not enforce** the format requirement
- No blocking mechanism preventing non-compliant responses
- **Nuance**: Guardrails are advisory/guidance, not strict enforcement

### 2. Format Mismatch
- Evidence format designed for: `"Exact command + output with timestamp"`
- Image validation needs: Field-by-field comparison with sources
- No guidance for non-terminal validation scenarios
- **Nuance**: Different validation types (terminal vs. image vs. data) may need different approaches

### 3. Logic Errors
- Confused "data exists in file" with "verified against source"
- Made inference-based claims without explicit verification
- Did not separate "what I can verify" from "what I cannot verify"
- **Nuance**: Used contextual clues (file names, patterns) to infer rather than explicitly verify

### 4. Contextual Inference vs. Explicit Verification
- Used file context (similar filenames, directory structure) to infer processing instructions
- Relied on pattern matching (saw prompt.md file and assumed it explained the process)
- Made logical connections without explicitly stating what was inferred vs. verified
- **Nuance**: This is useful behavior normally, but problematic when claiming verification

### 5. Validation Tool Usage
- Did not call `validate_evidence_claim` before responding
- Guardrails detected requirement but AI didn't proactively validate own claims
- Assumed detection was sufficient without self-validation step
- **Nuance**: Tools exist but require proactive use, not automatic enforcement

### 6. Boundary Conditions
- Guardrails work well for terminal/command output scenarios
- Less clear guidance for image/data/file comparison scenarios
- Different validation types may need different rules (not one-size-fits-all)
- **Nuance**: Need flexible approach that adapts to context without being overly rigid

## Key Insights

1. **Guardrails are advisory, not enforced** - They detect but don't block
2. **Format is terminal-focused** - Doesn't fit image/data validation
3. **Validation logic needs explicit steps** - Cannot rely on inference
4. **Need distinction between claim types** - Verified vs. Confirmed vs. Exists

## Recommendations

1. **Add enforcement mechanism** - Block or flag non-compliant responses
   - **But**: Balance strictness with flexibility - avoid overly rigid rules
   - **Consider**: Warnings vs. blocking, contextual appropriateness

2. **Extend evidence format** - Support image/data validation scenarios
   - **Include**: Field-by-field comparison, source attribution, visibility checks
   - **Maintain**: Flexibility for different validation types

3. **Require explicit validation steps** - Step-by-step comparison requirements
   - **Clarify**: What was checked, what wasn't checked, what was inferred
   - **Distinguish**: Explicit verification vs. contextual inference

4. **Add validation type detection** - Different rules for different validation types
   - **Types**: Terminal output, image comparison, data/file comparison, cross-reference
   - **Adapt**: Rules to context without being one-size-fits-all

5. **Require claim categorization** - Must label each claim as Verified/Unverified/Insufficient
   - **Add**: Distinction between "verified", "confirmed exists", "inferred from context"
   - **Clarify**: Source of each claim (verified vs. reported vs. inferred)

6. **Proactive self-validation** - Encourage use of `validate_evidence_claim` before responding
   - **Not**: Automatic enforcement (too rigid)
   - **But**: Better guidance on when/how to use validation tools

7. **Context awareness balance** - Keep useful contextual inference
   - **But**: Clearly separate when using context vs. when performing explicit verification
   - **Maintain**: The value of pattern matching and contextual awareness

