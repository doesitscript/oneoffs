#!/bin/bash

# Bread Financial Repository Bulk Clone Script
# This script clones all 46 repositories you have access to in the Bread-Financial organization

set -e  # Exit on any error

echo "🚀 Starting bulk clone of Bread Financial repositories..."
echo "📁 Target directory: $(pwd)"
echo ""

# Array of all 46 repositories you have access to
repos=(
    "aws_bfh_infrastructure"
    "bfh_aws_config"
    "aws-infrastructure-networkhub-core"
    "terraform-aws-data-analytics"
    "terraform-data-infrastructure"
    "bfh_aws_data_modules"
    "bfh_aws_data_solutions"
    "CloudDataOps"
    "aft-account-request"
    "aft-global-customizations"
    "aft-account-customizations"
    "aft-account-provisioning-customizations"
    "terraform-aws-application-ingress-nlb"
    "terraform-aws-application-ingress-nlb-service-discovery"
    "terraform-aws-application-ingress-target-group"
    "terraform-aws-centralized-ingress-alb"
    "terraform-aws-sectigo-acm-connector"
    "sectigo-acm-bootstrap"
    "ADSActiveDirectory"
    "Active-Directory"
    "Microsoft-Endpoint-Configuration-Manager"
    "End-User-Support"
    "omnichannel-web"
    "omnichannel-reference-auth"
    "omnichannel-reference-host"
    "omnichannel-reference-remote"
    "unified-partner-portal"
    "smartmart"
    "prescreen"
    "wave0apps-iac"
    "legacyx-component"
    "legacyx-user"
    "integrations_translation"
    "aws-integration-ServiceNow-ServiceGraphConnector"
    "SRE"
    "SRE-ZenossHealthcheckAutomation"
    "ca-aws-tools"
    "hello-world-ecs-service"
    "CouchbaseDocDeployPOC"
    "example-multi-org-packages"
    "crumbtrail"
    "slice-api-server"
    "rule"
    "enterprise-migration"
    "ws8-prescreen-data-driver"
    "aws-access"
)

# Counters
total_repos=${#repos[@]}
successful=0
failed=0
skipped=0

echo "📊 Total repositories to clone: $total_repos"
echo ""

# Function to clone a repository
clone_repo() {
    local repo_name="$1"
    local repo_path="Bread-Financial/$repo_name"
    
    echo "🔄 Cloning $repo_name..."
    
    # Check if directory already exists
    if [ -d "$repo_name" ]; then
        echo "⏭️  Skipping $repo_name (already exists)"
        ((skipped++))
        return 0
    fi
    
    # Attempt to clone with shallow history for speed
    if gh repo clone "$repo_path" -- --depth 1; then
        echo "✅ Successfully cloned $repo_name"
        ((successful++))
    else
        echo "❌ Failed to clone $repo_name"
        ((failed++))
        return 1
    fi
}

# Clone all repositories
for repo in "${repos[@]}"; do
    clone_repo "$repo"
    echo ""  # Add spacing between clones
done

# Summary
echo "🎉 Bulk clone completed!"
echo "=========================="
echo "✅ Successful: $successful"
echo "⏭️  Skipped: $skipped"
echo "❌ Failed: $failed"
echo "📊 Total processed: $((successful + skipped + failed))"
echo ""

if [ $failed -gt 0 ]; then
    echo "⚠️  Some repositories failed to clone. Check the output above for details."
    exit 1
else
    echo "🎊 All repositories cloned successfully!"
fi
