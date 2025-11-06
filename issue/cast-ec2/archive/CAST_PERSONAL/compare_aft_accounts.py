#!/usr/bin/env python3
"""
Script to compare AFT account requests with actual AWS Organizations accounts.
This script extracts account request data from Terraform files and compares
with the actual accounts created in AWS Organizations.
"""

import os
import re
import json
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Any, Optional

class AFTAccountComparator:
    def __init__(self, aft_request_path: str):
        self.aft_request_path = Path(aft_request_path)
        self.account_requests = []
        
    def extract_account_requests(self) -> List[Dict[str, Any]]:
        """Extract account request data from Terraform files."""
        print("🔍 Extracting account requests from Terraform files...")
        
        # Find all .tf files in the aft-account-request/terraform directory
        tf_files = list(self.aft_request_path.glob("*.tf"))
        
        for tf_file in tf_files:
            if tf_file.name.startswith("modules/") or tf_file.name in ["data.tf", "versions.tf"]:
                continue
                
            print(f"  📄 Processing {tf_file.name}")
            content = tf_file.read_text()
            
            # Extract module blocks
            module_blocks = self._extract_module_blocks(content)
            
            for module in module_blocks:
                account_request = self._parse_module_block(module, tf_file.name)
                if account_request:
                    self.account_requests.append(account_request)
        
        print(f"✅ Found {len(self.account_requests)} account requests")
        return self.account_requests
    
    def _extract_module_blocks(self, content: str) -> List[str]:
        """Extract module blocks from Terraform content."""
        # Simple regex to find module blocks
        pattern = r'module\s+"[^"]+"\s*\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}'
        return re.findall(pattern, content, re.MULTILINE | re.DOTALL)
    
    def _parse_module_block(self, module_content: str, filename: str) -> Optional[Dict[str, Any]]:
        """Parse a module block to extract account request data."""
        try:
            # Extract module name
            module_name_match = re.search(r'module\s+"([^"]+)"', module_content)
            if not module_name_match:
                return None
            
            module_name = module_name_match.group(1)
            
            # Extract control_tower_parameters
            ct_params = self._extract_control_tower_parameters(module_content)
            if not ct_params:
                return None
            
            # Extract account_tags
            account_tags = self._extract_account_tags(module_content)
            
            # Extract change_management_parameters
            change_mgmt = self._extract_change_management_parameters(module_content)
            
            return {
                "module_name": module_name,
                "filename": filename,
                "control_tower_parameters": ct_params,
                "account_tags": account_tags,
                "change_management_parameters": change_mgmt
            }
        except Exception as e:
            print(f"  ⚠️  Error parsing module in {filename}: {e}")
            return None
    
    def _extract_control_tower_parameters(self, content: str) -> Optional[Dict[str, str]]:
        """Extract control_tower_parameters from module content."""
        # Find the control_tower_parameters block
        pattern = r'control_tower_parameters\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
        match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        
        if not match:
            return None
        
        params_block = match.group(1)
        params = {}
        
        # Extract key-value pairs
        for line in params_block.split('\n'):
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                # Remove comments and clean up
                line = re.sub(r'#.*$', '', line).strip()
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    if key and value:
                        params[key] = value
        
        return params if params else None
    
    def _extract_account_tags(self, content: str) -> Dict[str, str]:
        """Extract account_tags from module content."""
        pattern = r'account_tags\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
        match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        
        if not match:
            return {}
        
        tags_block = match.group(1)
        tags = {}
        
        for line in tags_block.split('\n'):
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                line = re.sub(r'#.*$', '', line).strip()
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip().strip('"').strip("'")
                    value = value.strip().strip('"').strip("'")
                    if key and value:
                        tags[key] = value
        
        return tags
    
    def _extract_change_management_parameters(self, content: str) -> Dict[str, str]:
        """Extract change_management_parameters from module content."""
        pattern = r'change_management_parameters\s*=\s*\{([^}]+(?:\{[^}]*\}[^}]*)*)\}'
        match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        
        if not match:
            return {}
        
        cm_block = match.group(1)
        params = {}
        
        for line in cm_block.split('\n'):
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                line = re.sub(r'#.*$', '', line).strip()
                if '=' in line:
                    key, value = line.split('=', 1)
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    if key and value:
                        params[key] = value
        
        return params
    
    def get_aws_organizations_accounts(self) -> List[Dict[str, Any]]:
        """Get actual AWS Organizations accounts."""
        print("🔍 Querying AWS Organizations for actual accounts...")
        
        try:
            # Use AWS CLI to list organization accounts
            cmd = [
                "aws", "organizations", "list-accounts",
                "--query", "Accounts[?Status=='ACTIVE'].[Id,Name,Email,JoinedMethod]",
                "--output", "json"
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            accounts_data = json.loads(result.stdout)
            
            accounts = []
            for account_data in accounts_data:
                accounts.append({
                    "id": account_data[0],
                    "name": account_data[1],
                    "email": account_data[2],
                    "joined_method": account_data[3]
                })
            
            print(f"✅ Found {len(accounts)} active AWS Organizations accounts")
            return accounts
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Error querying AWS Organizations: {e}")
            print(f"   Make sure you're authenticated and have permissions")
            return []
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            return []
    
    def compare_accounts(self) -> Dict[str, Any]:
        """Compare AFT requests with actual AWS accounts."""
        print("🔄 Comparing AFT requests with AWS Organizations accounts...")
        
        aws_accounts = self.get_aws_organizations_accounts()
        
        comparison = {
            "matched_accounts": [],
            "unmatched_requests": [],
            "unmatched_aws_accounts": [],
            "naming_patterns": {}
        }
        
        # Create lookup dictionaries
        aws_by_name = {acc["name"]: acc for acc in aws_accounts}
        aws_by_email = {acc["email"]: acc for acc in aws_accounts}
        
        # Match AFT requests with AWS accounts
        for request in self.account_requests:
            ct_params = request.get("control_tower_parameters", {})
            account_name = ct_params.get("AccountName", "")
            account_email = ct_params.get("AccountEmail", "")
            
            matched = False
            
            # Try to match by name first
            if account_name in aws_by_name:
                aws_account = aws_by_name[account_name]
                comparison["matched_accounts"].append({
                    "aft_request": request,
                    "aws_account": aws_account,
                    "match_type": "name"
                })
                matched = True
                del aws_by_name[account_name]  # Remove from unmatched
            
            # Try to match by email if name didn't match
            elif account_email in aws_by_email:
                aws_account = aws_by_email[account_email]
                comparison["matched_accounts"].append({
                    "aft_request": request,
                    "aws_account": aws_account,
                    "match_type": "email"
                })
                matched = True
                del aws_by_email[account_email]  # Remove from unmatched
            
            if not matched:
                comparison["unmatched_requests"].append(request)
        
        # Remaining AWS accounts are unmatched
        comparison["unmatched_aws_accounts"] = list(aws_by_name.values())
        
        # Analyze naming patterns
        comparison["naming_patterns"] = self._analyze_naming_patterns(comparison["matched_accounts"])
        
        return comparison
    
    def _analyze_naming_patterns(self, matched_accounts: List[Dict]) -> Dict[str, Any]:
        """Analyze naming patterns between AFT requests and AWS accounts."""
        patterns = {
            "exact_matches": 0,
            "case_differences": 0,
            "format_differences": 0,
            "examples": []
        }
        
        for match in matched_accounts:
            aft_name = match["aft_request"]["control_tower_parameters"].get("AccountName", "")
            aws_name = match["aws_account"]["name"]
            
            if aft_name == aws_name:
                patterns["exact_matches"] += 1
            elif aft_name.lower() == aws_name.lower():
                patterns["case_differences"] += 1
                patterns["examples"].append({
                    "aft": aft_name,
                    "aws": aws_name,
                    "type": "case_difference"
                })
            else:
                patterns["format_differences"] += 1
                patterns["examples"].append({
                    "aft": aft_name,
                    "aws": aws_name,
                    "type": "format_difference"
                })
        
        return patterns
    
    def print_comparison_report(self, comparison: Dict[str, Any]):
        """Print a detailed comparison report."""
        print("\n" + "="*80)
        print("📊 AFT ACCOUNT REQUEST vs AWS ORGANIZATIONS COMPARISON REPORT")
        print("="*80)
        
        # Summary
        total_requests = len(self.account_requests)
        total_matched = len(comparison["matched_accounts"])
        total_unmatched_requests = len(comparison["unmatched_requests"])
        total_unmatched_aws = len(comparison["unmatched_aws_accounts"])
        
        print(f"\n📈 SUMMARY:")
        print(f"   Total AFT Requests: {total_requests}")
        print(f"   Matched Accounts: {total_matched}")
        print(f"   Unmatched Requests: {total_unmatched_requests}")
        print(f"   Unmatched AWS Accounts: {total_unmatched_aws}")
        
        # Naming patterns
        patterns = comparison["naming_patterns"]
        print(f"\n🏷️  NAMING PATTERNS:")
        print(f"   Exact Matches: {patterns['exact_matches']}")
        print(f"   Case Differences: {patterns['case_differences']}")
        print(f"   Format Differences: {patterns['format_differences']}")
        
        # Show examples of differences
        if patterns["examples"]:
            print(f"\n📝 EXAMPLES OF DIFFERENCES:")
            for example in patterns["examples"][:5]:  # Show first 5
                print(f"   AFT: '{example['aft']}' → AWS: '{example['aws']}' ({example['type']})")
        
        # Show matched accounts (first 5)
        if comparison["matched_accounts"]:
            print(f"\n✅ MATCHED ACCOUNTS (showing first 5):")
            for match in comparison["matched_accounts"][:5]:
                aft_name = match["aft_request"]["control_tower_parameters"].get("AccountName", "")
                aws_name = match["aws_account"]["name"]
                aws_id = match["aws_account"]["id"]
                print(f"   {aft_name} → {aws_name} ({aws_id}) [{match['match_type']}]")
        
        # Show unmatched requests
        if comparison["unmatched_requests"]:
            print(f"\n❌ UNMATCHED AFT REQUESTS:")
            for request in comparison["unmatched_requests"]:
                ct_params = request["control_tower_parameters"]
                name = ct_params.get("AccountName", "N/A")
                email = ct_params.get("AccountEmail", "N/A")
                print(f"   {name} ({email})")
        
        # Show unmatched AWS accounts
        if comparison["unmatched_aws_accounts"]:
            print(f"\n❓ UNMATCHED AWS ACCOUNTS:")
            for account in comparison["unmatched_aws_accounts"][:10]:  # Show first 10
                print(f"   {account['name']} ({account['email']}) [{account['id']}]")

def main():
    # Path to the aft-account-request terraform directory
    aft_path = "/Users/a805120/develop/organization_repositories/aft-account-request/terraform"
    
    if not os.path.exists(aft_path):
        print(f"❌ AFT request path not found: {aft_path}")
        sys.exit(1)
    
    comparator = AFTAccountComparator(aft_path)
    
    # Extract account requests
    account_requests = comparator.extract_account_requests()
    
    if not account_requests:
        print("❌ No account requests found")
        sys.exit(1)
    
    # Compare with AWS Organizations
    comparison = comparator.compare_accounts()
    
    # Print report
    comparator.print_comparison_report(comparison)
    
    # Save detailed results to JSON
    output_file = "/Users/a805120/develop/oneoffs/issue/cast-ec2/CAST_PERSONAL/aft_account_comparison.json"
    with open(output_file, 'w') as f:
        json.dump({
            "account_requests": account_requests,
            "comparison": comparison
        }, f, indent=2, default=str)
    
    print(f"\n💾 Detailed results saved to: {output_file}")

if __name__ == "__main__":
    main()
