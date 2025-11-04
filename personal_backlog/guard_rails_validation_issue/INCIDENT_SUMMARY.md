# Guard Rails Validation Issue - Incident Summary

**Date**: November 4, 2025  
**Context**: Data verification task - comparing image data to CSV file

## What Happened

User asked to verify data in an image matched a CSV file. The AI assistant:
1. ✅ Correctly detected "verify" trigger in guardrails
2. ❌ Did NOT follow CLAIM → EVIDENCE → STATUS format
3. ❌ Claimed App Owner data was "verified" without actually verifying it against the image
4. ❌ Mixed "verified from image" with "confirmed exists in CSV" without distinction

## Root Causes Identified

### 1. Partial Guardrail Enforcement
- **Detection**: ✅ Guardrails detected "verify" trigger correctly
- **Compliance**: ❌ Did not follow required format
- **Result**: Guardrails were partially working (detection) but not fully enforced (compliance)

### 2. Evidence Format Mismatch
- Guardrails are designed for **terminal command output** verification
- Evidence format expects: "Exact command + output with timestamp"
- Image/data validation doesn't fit this format
- **Result**: Guardrails may not fully apply to image validation scenarios

### 3. Validation Logic Errors
- Confused "data exists in CSV" with "verified against image"
- Did not perform actual field-by-field comparison
- Made inference-based claims without explicit verification steps
- **Result**: False verification claims

## Key Findings

### Guardrails Are:
- ✅ Triggering correctly on "verify", "check", "evaluate" keywords
- ✅ Context-aware (detects when evidence required)
- ✅ Working for terminal/command output scenarios

### Guardrails Are NOT:
- ❌ Enforced (compliance not automatic)
- ❌ Designed for image/data validation scenarios
- ❌ Preventing false verification claims
- ❌ Requiring explicit validation steps

## What Needs to Be Addressed

1. **Enforcement Mechanism**: How to ensure compliance with CLAIM → EVIDENCE → STATUS format
2. **Evidence Format for Non-Terminal Scenarios**: Extend format to support:
   - Image validation
   - Data comparison
   - File content verification
   - Cross-reference validation
3. **Validation Logic**: Require explicit verification steps:
   - What was actually checked
   - What was NOT checked (but reported)
   - Source of each data point
4. **Distinction Between Claims**:
   - "Verified from source" vs "Exists in file"
   - "Can verify" vs "Cannot verify"
   - "Confirmed" vs "Verified"

## Files Referenced

- `.cursorrules` - Evidence-based claims rule (lines 74-105)
- `docs/evidence-based-behavior.md` - Full documentation
- `claude/servers/evidence-validator-mcp-server.js` - Validator implementation
- `.scratch/aft-account-request/testing/account_configuration_from_onenote.prompt.csv` - Data file
- `.scratch/aft-account-request/testing/account_configuration_from_onenote.prompt.md` - Instructions

## Questions to Address Later

1. Should guardrails block responses that don't follow CLAIM → EVIDENCE → STATUS format?
2. How should evidence format be extended for non-terminal validation?
3. Should validation require explicit step-by-step comparison?
4. How to prevent inference-based claims vs. actual verification?
5. Should there be different validation types (terminal, image, data, cross-reference)?

## Next Steps

- [ ] Review guardrail enforcement mechanism
- [ ] Extend evidence format for image/data validation
- [ ] Add explicit validation step requirements
- [ ] Test with similar scenarios
- [ ] Update documentation with examples

