# Guardrail Enforcement Troubleshooting Guide

**Date**: 2025-01-28  
**Issue**: Guardrails are detecting rule violations but not enforcing compliance

## Executive Summary

Guardrails are **partially working**:
- ✅ **Detection**: Guardrails correctly detect triggers (e.g., "verify", "evaluate", explicit instructions)
- ❌ **Enforcement**: Guardrails do NOT prevent non-compliant responses
- ❌ **Blocking**: No mechanism to block or flag violations before responses are sent

## Root Cause Analysis

### 1. MCP Guardrail Server Status

**Current State**: MCP Guardrail is configured in Cursor but may not be actively enforcing rules

**Evidence**:
- Guardrail is configured in `~/.cursor/mcp.json`
- Rule files exist in `~/.mcp/rules/`:
  - `cli-knowledge-leverage.json`
  - `enterprise-trust-loop-behavior-contract.json`
- Guardrail logs exist in `~/.mcp/rule-logs/` but show minimal activity

**Problem**: The guardrail server may be:
1. Not actively intercepting tool calls/responses
2. Only logging violations without blocking
3. Not properly loading rule files from `RULE_FILES_PATH`

### 2. Two Types of Rules (Disconnected)

**Type A: Cursor Rules (`.cursorrules`)**
- **Location**: `.cursorrules` files in workspace directories
- **Enforcement**: Advisory only - these are instructions, not enforced rules
- **Purpose**: Guidance for AI behavior
- **Status**: Working as designed (instructions, not enforcement)

**Type B: MCP Guardrail Rules (JSON files)**
- **Location**: `~/.mcp/rules/*.json`
- **Enforcement**: Should be enforced by MCP Guardrail server
- **Purpose**: Policy enforcement that blocks violations
- **Status**: **NOT ENFORCING** - rules exist but violations are not blocked

**Problem**: There's a disconnect between:
- What rules are defined (in `.cursorrules` and JSON rule files)
- What is actually enforced (nothing is being blocked)

### 3. Guardrail Architecture Gaps

**How Guardrails Should Work**:
1. MCP Guardrail intercepts tool calls/responses
2. Validates against rule files in `~/.mcp/rules/`
3. Blocks or flags violations before responses are sent
4. Logs violations for audit

**How Guardrails Actually Work**:
1. ✅ Rules are detected (trigger phrases, patterns)
2. ✅ Evidence requirements are identified
3. ❌ **No blocking mechanism** - violations proceed
4. ❌ **No pre-execution validation** - responses sent without validation
5. ⚠️ **Post-hoc detection** - violations only detected after the fact

### 4. Evidence Validator MCP Server

**Current State**: Evidence Validator exists but requires **proactive use**

**Tools Available**:
- `check_evidence_required` - Detects if evidence is needed
- `validate_evidence_claim` - Validates claims against evidence

**Problem**: 
- Tools exist but are **not automatically called**
- AI must proactively use these tools (not enforced)
- No automatic validation before responses are sent

## Specific Enforcement Failures

### Failure 1: Explicit Text Not Enforced

**Rule**: "Follow explicit instructions exactly"

**Violation**: Commit message specified as `"Initial account vending"` but AI added unrequested details

**Why It Failed**:
- No guardrail logic to detect when explicit text is provided
- No comparison between instruction text and actual output
- Advisory-only enforcement (rules exist but don't block)

### Failure 2: Evidence Format Not Enforced

**Rule**: "Use CLAIM → EVIDENCE → STATUS format for verification requests"

**Violation**: Verification requested but format not used

**Why It Failed**:
- Guardrails detected trigger ("verify") correctly
- But did not enforce format requirement
- No blocking mechanism to prevent non-compliant responses

### Failure 3: Sequential Workflow Not Enforced

**Rule**: "Follow sequential step-by-step instructions"

**Violation**: Sequential git workflow instructions not followed in order

**Why It Failed**:
- No detection of sequential instruction patterns
- No enforcement of step order
- No validation that each step completes before next begins

## Diagnostic Checklist

### Step 1: Verify Guardrail is Running

```bash
# Check if guardrail is configured in Cursor
grep -i "guardrail\|mcp-guard" ~/.cursor/mcp.json

# Check guardrail logs
ls -la ~/.mcp/rule-logs/

# Check rule files
ls -la ~/.mcp/rules/
```

**Expected**: Guardrail configured, logs exist, rules present  
**Actual**: ✅ Configured, ⚠️ Logs minimal, ✅ Rules present

### Step 2: Verify Rule Files Are Loaded

```bash
# Check rule file format
cat ~/.mcp/rules/enterprise-trust-loop-behavior-contract.json | jq .

# Check environment variable
echo $RULE_FILES_PATH
```

**Expected**: Valid JSON, `RULE_FILES_PATH` points to rules directory  
**Actual**: ✅ Valid JSON, ❓ Need to verify env var in guardrail process

### Step 3: Test Rule Enforcement

**Test Case 1: Evidence Requirement**
- Trigger: "Verify the extension status"
- Expected: Response blocked if not in CLAIM → EVIDENCE → STATUS format
- Actual: Response sent without format requirement

**Test Case 2: Explicit Text**
- Trigger: Instruction with exact text in quotes
- Expected: Deviation from exact text blocked
- Actual: Deviation allowed, response sent

**Test Case 3: Sequential Workflow**
- Trigger: Step-by-step numbered instructions
- Expected: Steps must execute in order
- Actual: Steps executed out of order or batched

## Solutions & Recommendations

### Solution 1: Enable Active Enforcement

**Problem**: Guardrails are advisory only

**Fix**: Configure MCP Guardrail to:
1. Intercept responses before sending
2. Validate against rule files
3. Block non-compliant responses
4. Return error with rule violation details

**Implementation**:
- Check MCP Guardrail configuration
- Verify `RULE_FILES_PATH` environment variable
- Enable blocking mode (if available)
- Test with known violations

### Solution 2: Add Pre-Execution Validation

**Problem**: No validation before responses are sent

**Fix**: Implement validation hooks:
1. Before tool calls: Validate against rule triggers
2. Before responses: Validate format and compliance
3. After responses: Audit and log violations

**Implementation**:
- Use Evidence Validator MCP tools proactively
- Add validation checks in response generation
- Create validation middleware

### Solution 3: Bridge Cursor Rules and Guardrail Rules

**Problem**: Two disconnected rule systems

**Fix**: 
1. Convert critical `.cursorrules` to guardrail JSON rules
2. Create mapping between instruction types and enforcement levels
3. Enable guardrail to read `.cursorrules` patterns

**Implementation**:
- Create rule converter/parser
- Map instruction patterns to guardrail rules
- Test enforcement of converted rules

### Solution 4: Add Explicit Text Detection

**Problem**: No detection when explicit text is provided

**Fix**: Add rule for explicit text enforcement:
- Detect quoted text in instructions
- Compare output to exact text
- Block if deviation detected

**Implementation**:
```json
{
  "rule_name": "explicit-text-enforcement",
  "triggers": [
    {
      "type": "instruction_pattern",
      "patterns": [
        "use.*exact.*text",
        "verbatim",
        "\".*\"",
        "exactly.*as.*written"
      ]
    }
  ],
  "actions": [
    {
      "type": "enforce_exact_text",
      "validation": {
        "compare_output_to_instruction": true,
        "block_deviation": true
      }
    }
  ]
}
```

### Solution 5: Add Sequential Workflow Detection

**Problem**: No enforcement of sequential step order

**Fix**: Add rule for sequential workflow:
- Detect numbered steps or sequential patterns
- Enforce step order
- Block out-of-order execution

**Implementation**:
```json
{
  "rule_name": "sequential-workflow-enforcement",
  "triggers": [
    {
      "type": "instruction_pattern",
      "patterns": [
        "step.*1.*step.*2",
        "then.*next",
        "repeat.*for.*each",
        "numbered.*steps"
      ]
    }
  ],
  "actions": [
    {
      "type": "enforce_sequential_execution",
      "validation": {
        "require_step_completion": true,
        "block_parallel_execution": true
      }
    }
  ]
}
```

## Immediate Actions

### Action 1: Verify Guardrail is Active

```bash
# Check if guardrail process is running
ps aux | grep -i "mcp-guard\|guardrail"

# Check guardrail logs for activity
tail -f ~/.mcp/rule-logs/*.log

# Test guardrail with a known violation
# (e.g., make a claim without evidence)
```

### Action 2: Review Guardrail Configuration

```bash
# Check Cursor MCP config
cat ~/.cursor/mcp.json | jq '.mcpServers["MCP Guardrail"]'

# Check environment variables
cat ~/.cursor/mcp.json | jq '.mcpServers["MCP Guardrail"].env'

# Verify rule files path
ls -la ~/.mcp/rules/
```

### Action 3: Test Rule Loading

Create a test rule file and verify it's loaded:

```bash
# Create test rule
cat > ~/.mcp/rules/test-enforcement.json << 'EOF'
{
  "rule_name": "test-enforcement",
  "description": "Test rule to verify enforcement is working",
  "triggers": [
    {
      "type": "response_generation",
      "patterns": ["always"]
    }
  ],
  "actions": [
    {
      "type": "log_test",
      "message": "Test rule triggered"
    }
  ],
  "enforcement": {
    "level": "mandatory",
    "block_improvisation": true
  }
}
EOF

# Restart Cursor and check logs
# Look for "Test rule triggered" in logs
```

## Questions to Answer

1. **Is MCP Guardrail actively intercepting tool calls?**
   - Check logs for interception activity
   - Verify guardrail is running as a proxy

2. **Are rule files being loaded from `RULE_FILES_PATH`?**
   - Check guardrail logs for rule loading messages
   - Verify environment variable is set correctly

3. **Does guardrail have blocking capability?**
   - Check guardrail documentation for blocking mode
   - Verify if blocking is enabled in configuration

4. **Are validation tools being called automatically?**
   - Check if Evidence Validator is called proactively
   - Verify if validation is integrated into response flow

5. **What is the enforcement level?**
   - Advisory (log only)?
   - Warning (log and flag)?
   - Blocking (prevent response)?

## Next Steps

1. ✅ Document root causes (this document)
2. ⏳ Verify guardrail is actively running and intercepting
3. ⏳ Test rule loading and validation
4. ⏳ Implement explicit text detection rule
5. ⏳ Implement sequential workflow detection rule
6. ⏳ Test enforcement with known violations
7. ⏳ Document working configuration

## Related Files

- `/Users/a805120/develop/workflows/.cursorrules` - Cursor rules (advisory)
- `/Users/a805120/.mcp/rules/*.json` - Guardrail rules (should enforce)
- `/Users/a805120/develop/workflows/guardrails/README.md` - Guardrail setup
- `/Users/a805120/develop/oneoffs/personal_backlog/guard_rails_*` - Incident documentation

