# Evidence-Based Behavior Configuration

## Overview
This configuration implements **targeted evidence-based behavior rules** that only apply when making claims about results, status, or success/failure - preserving YOLO mode for normal tasks.

## Configuration Components

### 1. Cursor Rules (`.cursorrules`)
- **Targeted enforcement** - only applies to status/verification requests
- **Preserves YOLO mode** for normal coding tasks
- **Context-aware** - knows when to be strict vs. permissive

### 2. Evidence Validator MCP Server
- **Context detection** - identifies when evidence is required
- **Claim validation** - ensures evidence supports claims
- **Trigger phrase detection** - recognizes evaluation requests

## When Evidence Rules Apply

### ✅ TRIGGERED BY:
- "evaluate", "status", "verify", "check"
- "did it work", "is it working", "what happened"
- "show me proof", "back up your claim"
- Extension functionality claims
- Test result reporting
- Success/failure statements

### ❌ NOT TRIGGERED BY:
- General coding tasks
- File operations (create, edit, delete)
- Command execution (unless claiming results)
- YOLO mode operations
- Normal development workflow

## Evidence Format (When Required)

```
CLAIM: [What I'm claiming]
EVIDENCE: [Exact command + output with timestamp]
STATUS: [Verified/Unverified/Insufficient Evidence]
```

## Prohibited Words (Without Evidence)
- "successful", "working", "fixed", "verified"
- "extension is functioning"
- "auto-login worked"
- Any result claims without proof

## Usage Examples

### Normal Task (No Evidence Required)
```
User: "Create a new file called test.js"
Assistant: [Creates file - no evidence needed]
```

### Status Request (Evidence Required)
```
User: "Evaluate the extension status"
Assistant:
CLAIM: Extension is loaded and functional
EVIDENCE: Console log shows "🎯 [CONTENT] Okta Auto Sign-In extension v2.0 loaded" at 2024-01-15T10:30:00Z
STATUS: Verified
```

## MCP Server Tools

### `check_evidence_required`
- Analyzes user request for evidence triggers
- Returns context recommendation
- Identifies matched trigger phrases

### `validate_evidence_claim`
- Validates claims against evidence
- Context-aware enforcement
- Provides validation feedback

## Benefits
- ✅ **Preserves efficiency** - YOLO mode still works for normal tasks
- ✅ **Enforces accuracy** - Evidence required for status claims
- ✅ **Context-aware** - Knows when to be strict
- ✅ **Targeted** - Doesn't break existing workflows
- ✅ **Verifiable** - Claims backed by evidence
- ✅ **Prevents unauthorized Playwright usage** - Only uses when explicitly requested

## Implementation Status
- ✅ Cursor rules updated
- ✅ MCP server created
- ✅ MCP config updated
- ✅ Dependencies installed
- ✅ Documentation created
