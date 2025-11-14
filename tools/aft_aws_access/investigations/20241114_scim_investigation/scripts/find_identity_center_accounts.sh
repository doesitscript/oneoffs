#!/bin/bash

# Quick scan to find accounts with IAM Identity Center
echo "Scanning all AWS profiles for IAM Identity Center configuration..."
echo ""

PROFILES=$(cat ~/.aws/config | grep -E '^\[profile ' | sed 's/\[profile //' | sed 's/\]//')

IC_ACCOUNTS=()
COUNT=0
TOTAL=$(echo "$PROFILES" | wc -l)

for PROFILE in $PROFILES; do
    COUNT=$((COUNT + 1))
    echo -ne "\rScanning $COUNT/$TOTAL: $PROFILE...                    "
    
    # Quick test: try to list SSO instances
    if timeout 5 aws sso-admin list-instances --region us-east-2 --profile "$PROFILE" --output json 2>/dev/null | jq -e '.Instances | length > 0' >/dev/null 2>&1; then
        IC_ACCOUNTS+=("$PROFILE")
        echo ""
        echo "✓ FOUND Identity Center: $PROFILE"
    fi
done

echo ""
echo ""
echo "================================"
echo "Accounts with Identity Center:"
echo "================================"
printf '%s\n' "${IC_ACCOUNTS[@]}"
echo ""
echo "Total: ${#IC_ACCOUNTS[@]} accounts"
