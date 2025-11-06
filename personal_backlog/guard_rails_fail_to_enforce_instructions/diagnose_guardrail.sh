#!/bin/bash
# Guardrail Enforcement Diagnostic Script
# Checks if guardrails are properly configured and running

set -euo pipefail

echo "=========================================="
echo "Guardrail Enforcement Diagnostic"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Cursor MCP Configuration
echo "1. Checking Cursor MCP Configuration..."
if [ -f ~/.cursor/mcp.json ]; then
    if grep -qi "guardrail\|mcp-guard" ~/.cursor/mcp.json; then
        echo -e "${GREEN}✓${NC} Guardrail found in Cursor MCP config"
        echo "   Configuration:"
        grep -A 10 "MCP Guardrail" ~/.cursor/mcp.json | head -15 | sed 's/^/   /'
    else
        echo -e "${RED}✗${NC} Guardrail NOT found in Cursor MCP config"
    fi
else
    echo -e "${RED}✗${NC} Cursor MCP config not found at ~/.cursor/mcp.json"
fi
echo ""

# Check 2: Guardrail Binary
echo "2. Checking Guardrail Binary..."
GUARDRAIL_BIN="/Users/a805120/.mcp-src/mcp-guard/dist/index.js"
if [ -f "$GUARDRAIL_BIN" ]; then
    echo -e "${GREEN}✓${NC} Guardrail binary exists: $GUARDRAIL_BIN"
    if [ -x "$GUARDRAIL_BIN" ]; then
        echo -e "${GREEN}✓${NC} Binary is executable"
    else
        echo -e "${YELLOW}⚠${NC} Binary may not be executable (check permissions)"
    fi
else
    echo -e "${RED}✗${NC} Guardrail binary not found: $GUARDRAIL_BIN"
    echo "   Alternative locations to check:"
    find ~/.mcp-src -name "index.js" -path "*/mcp-guard/*" 2>/dev/null | head -5 | sed 's/^/     /'
fi
echo ""

# Check 3: Rule Files
echo "3. Checking Rule Files..."
RULES_DIR="$HOME/.mcp/rules"
if [ -d "$RULES_DIR" ]; then
    echo -e "${GREEN}✓${NC} Rules directory exists: $RULES_DIR"
    RULE_COUNT=$(find "$RULES_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RULE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Found $RULE_COUNT rule file(s):"
        find "$RULES_DIR" -name "*.json" 2>/dev/null | sed 's/^/     /'
        
        # Validate JSON syntax
        echo "   Validating JSON syntax..."
        for rule_file in "$RULES_DIR"/*.json; do
            if [ -f "$rule_file" ]; then
                if python3 -m json.tool "$rule_file" > /dev/null 2>&1; then
                    echo -e "     ${GREEN}✓${NC} $(basename "$rule_file") - Valid JSON"
                else
                    echo -e "     ${RED}✗${NC} $(basename "$rule_file") - Invalid JSON"
                fi
            fi
        done
    else
        echo -e "${YELLOW}⚠${NC} No rule files found in $RULES_DIR"
    fi
else
    echo -e "${RED}✗${NC} Rules directory not found: $RULES_DIR"
    echo "   Creating directory..."
    mkdir -p "$RULES_DIR"
    echo -e "${GREEN}✓${NC} Created: $RULES_DIR"
fi
echo ""

# Check 4: Environment Variables
echo "4. Checking Environment Variables..."
if [ -f ~/.cursor/mcp.json ]; then
    RULE_PATH=$(grep -A 20 "MCP Guardrail" ~/.cursor/mcp.json | grep -i "RULE_FILES_PATH" | head -1 | sed 's/.*"RULE_FILES_PATH": *"\([^"]*\)".*/\1/' || echo "")
    LOG_PATH=$(grep -A 20 "MCP Guardrail" ~/.cursor/mcp.json | grep -i "MCP_RULEGUARD_LOG_DIR" | head -1 | sed 's/.*"MCP_RULEGUARD_LOG_DIR": *"\([^"]*\)".*/\1/' || echo "")
    
    if [ -n "$RULE_PATH" ]; then
        EXPANDED_RULE_PATH=$(echo "$RULE_PATH" | sed "s|~|$HOME|")
        echo "   RULE_FILES_PATH: $EXPANDED_RULE_PATH"
        if [ -d "$EXPANDED_RULE_PATH" ]; then
            echo -e "     ${GREEN}✓${NC} Path exists"
        else
            echo -e "     ${RED}✗${NC} Path does not exist"
        fi
    else
        echo -e "${YELLOW}⚠${NC} RULE_FILES_PATH not found in config"
    fi
    
    if [ -n "$LOG_PATH" ]; then
        EXPANDED_LOG_PATH=$(echo "$LOG_PATH" | sed "s|~|$HOME|")
        echo "   MCP_RULEGUARD_LOG_DIR: $EXPANDED_LOG_PATH"
        if [ -d "$EXPANDED_LOG_PATH" ]; then
            echo -e "     ${GREEN}✓${NC} Path exists"
            LOG_COUNT=$(find "$EXPANDED_LOG_PATH" -name "*.log" 2>/dev/null | wc -l | tr -d ' ')
            echo "     Found $LOG_COUNT log file(s)"
        else
            echo -e "     ${YELLOW}⚠${NC} Path does not exist (will be created on first run)"
        fi
    else
        echo -e "${YELLOW}⚠${NC} MCP_RULEGUARD_LOG_DIR not found in config"
    fi
fi
echo ""

# Check 5: Guardrail Process
echo "5. Checking Running Processes..."
if pgrep -f "mcp-guard\|guardrail" > /dev/null; then
    echo -e "${GREEN}✓${NC} Guardrail process is running:"
    ps aux | grep -i "mcp-guard\|guardrail" | grep -v grep | sed 's/^/     /'
else
    echo -e "${YELLOW}⚠${NC} No guardrail process found running"
    echo "   Note: Guardrail may be started by Cursor on demand"
fi
echo ""

# Check 6: Log Files
echo "6. Checking Log Files..."
LOG_DIR="$HOME/.mcp/rule-logs"
if [ -d "$LOG_DIR" ]; then
    echo -e "${GREEN}✓${NC} Log directory exists: $LOG_DIR"
    LOG_COUNT=$(find "$LOG_DIR" -name "*.log" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$LOG_COUNT" -gt 0 ]; then
        echo "   Found $LOG_COUNT log file(s)"
        echo "   Recent log files:"
        find "$LOG_DIR" -name "*.log" -type f -mtime -7 2>/dev/null | sort -r | head -5 | while read log; do
            echo "     $(basename "$log") - $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$log" 2>/dev/null || stat -c "%y" "$log" 2>/dev/null | cut -d' ' -f1-2)"
        done
        
        # Check for recent activity
        RECENT_LOG=$(find "$LOG_DIR" -name "*.log" -type f -mtime -1 2>/dev/null | head -1)
        if [ -n "$RECENT_LOG" ]; then
            echo "   Recent activity in: $(basename "$RECENT_LOG")"
            echo "   Last 5 lines:"
            tail -5 "$RECENT_LOG" 2>/dev/null | sed 's/^/     /' || echo "     (empty or unreadable)"
        fi
    else
        echo -e "${YELLOW}⚠${NC} No log files found (guardrail may not have run yet)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Log directory not found: $LOG_DIR"
    echo "   (Will be created on first guardrail run)"
fi
echo ""

# Check 7: Servers Configuration
echo "7. Checking Servers Configuration..."
SERVERS_CONFIG="/Users/a805120/develop/workflows/guardrails/servers.json"
if [ -f "$SERVERS_CONFIG" ]; then
    echo -e "${GREEN}✓${NC} Servers config exists: $SERVERS_CONFIG"
    if python3 -m json.tool "$SERVERS_CONFIG" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Valid JSON syntax"
        echo "   Configured servers:"
        python3 -c "import json, sys; data=json.load(open('$SERVERS_CONFIG')); [print(f'     - {s.get(\"name\", \"unknown\")}') for s in data]" 2>/dev/null || echo "     (could not parse)"
    else
        echo -e "${RED}✗${NC} Invalid JSON syntax"
    fi
else
    echo -e "${YELLOW}⚠${NC} Servers config not found: $SERVERS_CONFIG"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "Key Findings:"
echo ""
echo "1. Guardrail Configuration:"
if grep -qi "guardrail\|mcp-guard" ~/.cursor/mcp.json 2>/dev/null; then
    echo -e "   ${GREEN}✓${NC} Configured in Cursor MCP"
else
    echo -e "   ${RED}✗${NC} NOT configured in Cursor MCP"
fi
echo ""
echo "2. Rule Files:"
if [ -d "$RULES_DIR" ] && [ -n "$(find "$RULES_DIR" -name "*.json" 2>/dev/null)" ]; then
    echo -e "   ${GREEN}✓${NC} Rule files exist and are valid"
else
    echo -e "   ${RED}✗${NC} Rule files missing or invalid"
fi
echo ""
echo "3. Enforcement Status:"
echo -e "   ${YELLOW}⚠${NC} UNKNOWN - Cannot verify if enforcement is active"
echo "   (Check Cursor logs and guardrail logs for enforcement activity)"
echo ""
echo "Next Steps:"
echo "1. Verify guardrail is actually intercepting tool calls"
echo "2. Check guardrail logs for rule validation activity"
echo "3. Test with a known violation to see if it's blocked"
echo "4. Review guardrail documentation for blocking mode configuration"
echo ""

