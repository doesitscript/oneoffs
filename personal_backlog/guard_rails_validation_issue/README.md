# Guard Rails Validation Issue

This folder contains documentation and files related to an incident where guardrails were triggered but not properly enforced during a data verification task.

## Contents

- `INCIDENT_SUMMARY.md` - High-level summary of what happened
- `ANALYSIS.md` - Detailed analysis of the problem and root causes
- `NUANCED_FACTORS.md` - **Important**: Subtle factors, philosophical considerations, balance questions
- `QUICK_REFERENCE.md` - Quick summary for future reference
- `evidence-based-behavior.md` - Current guardrail documentation
- `cursorrules_evidence_section.txt` - Relevant section from .cursorrules
- `evidence-validator-mcp-server.js` - Validator implementation
- `account_configuration_from_onenote.prompt.csv` - Data file being verified
- `account_configuration_from_onenote.prompt.md` - Instructions for data extraction

## Key Document: NUANCED_FACTORS.md

**Read this first** - Contains the philosophical considerations and balance questions that are critical for addressing this without creating overly rigid rules.

## Key Issue

Guardrails detected "verify" trigger but did not enforce CLAIM → EVIDENCE → STATUS format, resulting in false verification claims.

## Status

- [ ] Root cause analysis complete
- [ ] Solutions identified
- [ ] Implementation needed
- [ ] Testing required

## Related Files (Outside This Folder)

- `/Users/a805120/develop/workflows/.cursorrules` - Full cursor rules
- `/Users/a805120/develop/workflows/claude/servers/evidence-validator-mcp-server.js` - Validator implementation
- `/Users/a805120/develop/workflows/docs/evidence-based-behavior.md` - Full documentation

## Conversation Export

The full conversation about this incident should be exported separately and added to this folder.

