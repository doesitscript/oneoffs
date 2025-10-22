#!/bin/bash

# Bread Financial Repository Bulk Clone Script (Parallel Version)
# This script clones all 46 repositories in parallel for maximum speed

set -e  # Exit on any error

echo "🚀 Starting PARALLEL bulk clone of Bread Financial repositories..."
echo "📁 Target directory: $(pwd)"
echo "⚠️  WARNING: This will use significant bandwidth and system resources"
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
max_parallel=8  # Adjust based on your system and network capacity

echo "📊 Total repositories to clone: $total_repos"
echo "🔀 Max parallel processes: $max_parallel"
echo ""

# Function to clone a repository
clone_repo() {
    local repo_name="$1"
    local repo_path="Bread-Financial/$repo_name"
    
    # Check if directory already exists
    if [ -d "$repo_name" ]; then
        echo "⏭️  Skipping $repo_name (already exists)"
        return 0
    fi
    
    echo "🔄 Starting clone of $repo_name..."
    
    # Attempt to clone with shallow history for speed
    if gh repo clone "$repo_path" -- --depth 1 2>/dev/null; then
        echo "✅ Successfully cloned $repo_name"
    else
        echo "❌ Failed to clone $repo_name"
        return 1
    fi
}

# Export the function so it can be used by parallel processes
export -f clone_repo

# Clone repositories in parallel
echo "🚀 Starting parallel clone operations..."
printf '%s\n' "${repos[@]}" | xargs -n 1 -P $max_parallel -I {} bash -c 'clone_repo "$@"' _ {}

# Count results
successful=$(find . -maxdepth 1 -type d -name "*" | grep -v "^\.$" | wc -l)
echo ""
echo "🎉 Parallel clone completed!"
echo "=========================="
echo "📁 Directories created: $successful"
echo "📊 Total repositories: $total_repos"
echo ""

if [ $successful -eq $total_repos ]; then
    echo "🎊 All repositories cloned successfully!"
else
    echo "⚠️  Some repositories may have failed. Check the output above for details."
fi
