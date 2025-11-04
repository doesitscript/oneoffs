# Quick Reference - Guard Rails Validation Issue

## What Happened
User asked to verify image data matches CSV. AI claimed verification without following CLAIM → EVIDENCE → STATUS format.

## Root Causes
1. Guardrails detect but don't enforce compliance
2. Evidence format designed for terminal output, not image/data validation
3. AI confused "exists in file" with "verified against source"

## Key Files
- `INCIDENT_SUMMARY.md` - Overview
- `ANALYSIS.md` - Detailed analysis
- `evidence-based-behavior.md` - Current guardrail docs
- `cursorrules_evidence_section.txt` - Relevant rules

## What Needs Fixing
1. Enforcement mechanism (block non-compliant responses)
2. Evidence format extension (support image/data validation)
3. Explicit validation step requirements
4. Better distinction between claim types

## Conversation Export
Full conversation should be exported and added here for complete context.

