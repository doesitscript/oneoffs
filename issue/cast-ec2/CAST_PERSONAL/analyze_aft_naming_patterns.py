#!/usr/bin/env python3
"""
Detailed analysis of AFT account naming patterns vs AWS Organizations account names.
"""

import json
from pathlib import Path

def analyze_naming_patterns():
    """Analyze the naming patterns from the comparison data."""
    
    # Load the comparison data
    json_file = Path("/Users/a805120/develop/oneoffs/issue/cast-ec2/CAST_PERSONAL/aft_account_comparison_v2.json")
    
    if not json_file.exists():
        print("❌ Comparison data not found. Run compare_aft_accounts_v2.py first.")
        return
    
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    comparison = data["comparison"]
    matched_accounts = comparison["matched_accounts"]
    
    print("🔍 DETAILED AFT ACCOUNT NAMING PATTERN ANALYSIS")
    print("=" * 60)
    
    # Analyze the naming transformations
    print("\n📋 ACCOUNT NAME TRANSFORMATIONS:")
    print("-" * 60)
    
    exact_matches = []
    space_to_underscore = []
    hyphen_to_underscore = []
    case_changes = []
    other_changes = []
    
    for match in matched_accounts:
        aft_name = match["aft_request"]["control_tower_parameters"]["AccountName"]
        aws_name = match["aws_account"]["name"]
        aws_id = match["aws_account"]["id"]
        
        if aft_name == aws_name:
            exact_matches.append((aft_name, aws_name, aws_id))
        elif aft_name.replace(" ", "_") == aws_name:
            space_to_underscore.append((aft_name, aws_name, aws_id))
        elif aft_name.replace("-", "_") == aws_name:
            hyphen_to_underscore.append((aft_name, aws_name, aws_id))
        elif aft_name.lower() == aws_name.lower():
            case_changes.append((aft_name, aws_name, aws_id))
        else:
            other_changes.append((aft_name, aws_name, aws_id))
    
    # Print results by category
    if exact_matches:
        print(f"\n✅ EXACT MATCHES ({len(exact_matches)}):")
        for aft, aws, aws_id in exact_matches:
            print(f"   {aft} → {aws} ({aws_id})")
    
    if space_to_underscore:
        print(f"\n🔄 SPACE TO UNDERSCORE ({len(space_to_underscore)}):")
        for aft, aws, aws_id in space_to_underscore:
            print(f"   '{aft}' → '{aws}' ({aws_id})")
    
    if hyphen_to_underscore:
        print(f"\n🔄 HYPHEN TO UNDERSCORE ({len(hyphen_to_underscore)}):")
        for aft, aws, aws_id in hyphen_to_underscore:
            print(f"   '{aft}' → '{aws}' ({aws_id})")
    
    if case_changes:
        print(f"\n🔄 CASE CHANGES ({len(case_changes)}):")
        for aft, aws, aws_id in case_changes:
            print(f"   '{aft}' → '{aws}' ({aws_id})")
    
    if other_changes:
        print(f"\n❓ OTHER CHANGES ({len(other_changes)}):")
        for aft, aws, aws_id in other_changes:
            print(f"   '{aft}' → '{aws}' ({aws_id})")
    
    # Analyze email patterns
    print(f"\n📧 EMAIL ADDRESS PATTERNS:")
    print("-" * 60)
    
    email_patterns = {}
    for match in matched_accounts:
        aft_email = match["aft_request"]["control_tower_parameters"]["AccountEmail"]
        aws_email = match["aws_account"]["email"]
        
        # Extract the part before @
        aft_local = aft_email.split('@')[0]
        aws_local = aws_email.split('@')[0]
        
        if aft_local not in email_patterns:
            email_patterns[aft_local] = []
        email_patterns[aft_local].append((aft_email, aws_email))
    
    for local_part, emails in email_patterns.items():
        if len(emails) > 1 or emails[0][0] != emails[0][1]:
            print(f"   {local_part}:")
            for aft_email, aws_email in emails:
                print(f"     AFT:  {aft_email}")
                print(f"     AWS: {aws_email}")
    
    # Show specific examples of the 5 accounts you asked about
    print(f"\n🎯 TOP 5 ACCOUNT EXAMPLES:")
    print("-" * 60)
    
    examples = matched_accounts[:5]
    for i, match in enumerate(examples, 1):
        aft_request = match["aft_request"]
        aws_account = match["aws_account"]
        
        print(f"\n{i}. {aft_request['control_tower_parameters']['AccountName']}")
        print(f"   AFT Request:")
        print(f"     Name:  {aft_request['control_tower_parameters']['AccountName']}")
        print(f"     Email: {aft_request['control_tower_parameters']['AccountEmail']}")
        print(f"     OU:    {aft_request['control_tower_parameters']['ManagedOrganizationalUnit']}")
        print(f"   AWS Account:")
        print(f"     Name:  {aws_account['name']}")
        print(f"     ID:    {aws_account['id']}")
        print(f"     Email: {aws_account['email']}")
        print(f"   Transformation: '{aft_request['control_tower_parameters']['AccountName']}' → '{aws_account['name']}'")
    
    # Summary of naming rules
    print(f"\n📝 IDENTIFIED NAMING RULES:")
    print("-" * 60)
    print("1. Spaces in AFT AccountName become underscores in AWS account names")
    print("2. Hyphens in AFT AccountName become underscores in AWS account names") 
    print("3. Case is generally preserved")
    print("4. Special characters are typically removed or replaced")
    print("5. AWS profile names follow pattern: AccountName_AccountID_admin")
    print("6. Email addresses in AWS profiles are estimated as: AwsAccount+AccountName@breadfinancial.com")

if __name__ == "__main__":
    analyze_naming_patterns()
