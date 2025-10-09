#!/bin/bash
# =============================================================================
# Shell Environment Test Script
# =============================================================================
# This script tests common shell operations to ensure your environment
# is working correctly and not affected by overly strict error handling

echo "🔍 Testing Shell Environment..."
echo "=================================="

# Test 1: Basic date command
echo "Test 1: Date command"
if date '+%Y-%m-%d %H:%M:%S' > /dev/null 2>&1; then
    echo "✅ Date command works"
else
    echo "❌ Date command failed"
fi

# Test 2: Variable assignment with date
echo "Test 2: Variable assignment with date"
if TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S') 2>/dev/null; then
    echo "✅ Variable assignment with date works: $TIMESTAMP"
else
    echo "❌ Variable assignment with date failed"
fi

# Test 3: Pipeline operations
echo "Test 3: Pipeline operations"
if echo "test" | grep "test" > /dev/null 2>&1; then
    echo "✅ Pipeline operations work"
else
    echo "❌ Pipeline operations failed"
fi

# Test 4: Error handling
echo "Test 4: Error handling"
if ! false 2>/dev/null; then
    echo "✅ Error handling works (false command properly fails)"
else
    echo "❌ Error handling failed"
fi

# Test 5: Undefined variable handling
echo "Test 5: Undefined variable handling"
if [ -z "${UNDEFINED_VAR:-}" ]; then
    echo "✅ Undefined variable handling works"
else
    echo "❌ Undefined variable handling failed"
fi

# Test 6: Shell options
echo "Test 6: Shell options"
echo "  pipefail: $(if [[ -o pipefail ]]; then echo "ON"; else echo "OFF"; fi)"
echo "  errexit: $(if [[ -o errexit ]]; then echo "ON"; else echo "OFF"; fi)"
echo "  nounset: $(if [[ -o nounset ]]; then echo "ON"; else echo "OFF"; fi)"

echo "=================================="
echo "🎉 Shell environment test completed!"









