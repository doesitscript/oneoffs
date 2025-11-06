#!/usr/bin/env python3
"""
Query AMI using AWS SDK with proper SSL certificate handling.
This script uses the same certificate configuration as your MCP servers.
"""

import boto3
import sys
from operator import itemgetter
import os

# Set SSL certificate paths (matching your MCP server configuration)
os.environ['REQUESTS_CA_BUNDLE'] = '/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem'
os.environ['SSL_CERT_FILE'] = '/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem'
os.environ['PYTHONWARNINGS'] = 'ignore:Unverified HTTPS request'

# Suppress urllib3 warnings
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def get_most_recent_ami(owner, tag_name, platform, region='us-east-2'):
    """
    Get the most recent AMI matching the specified criteria.
    
    Args:
        owner: AWS account ID (e.g., '422228628991')
        tag_name: Tag value for tag:Name (e.g., 'GoldenAMI')
        platform: Platform name pattern (e.g., 'winserver2022')
        region: AWS region (default: 'us-east-2')
    
    Returns:
        Dictionary with AMI details or None if not found
    """
    try:
        ec2 = boto3.client('ec2', region_name=region)
        
        response = ec2.describe_images(
            Owners=[owner],
            Filters=[
                {'Name': 'tag:Name', 'Values': [tag_name]},
                {'Name': 'name', 'Values': [f'*{platform}*']},
                {'Name': 'state', 'Values': ['available']}
            ]
        )
        
        # Sort by creation date and get most recent (equivalent to most_recent=true)
        if response['Images']:
            images = sorted(
                response['Images'],
                key=itemgetter('CreationDate'),
                reverse=True
            )
            most_recent_ami = images[0]
            return most_recent_ami
        else:
            print(f"No AMIs found matching criteria:", file=sys.stderr)
            print(f"  Owner: {owner}", file=sys.stderr)
            print(f"  Tag Name: {tag_name}", file=sys.stderr)
            print(f"  Platform: {platform}", file=sys.stderr)
            return None
            
    except Exception as e:
        print(f"Error describing images: {e}", file=sys.stderr)
        raise

if __name__ == '__main__':
    # Default values from your Terraform configuration
    OWNER = '422228628991'
    TAG_NAME = 'GoldenAMI'
    PLATFORM = 'winserver2022'
    REGION = 'us-east-2'
    
    # Allow override via command line arguments
    if len(sys.argv) > 1:
        OWNER = sys.argv[1]
    if len(sys.argv) > 2:
        TAG_NAME = sys.argv[2]
    if len(sys.argv) > 3:
        PLATFORM = sys.argv[3]
    if len(sys.argv) > 4:
        REGION = sys.argv[4]
    
    ami = get_most_recent_ami(OWNER, TAG_NAME, PLATFORM, REGION)
    
    if ami:
        print(f"AMI ID: {ami['ImageId']}")
        print(f"Name: {ami['Name']}")
        print(f"Creation Date: {ami['CreationDate']}")
        print(f"Description: {ami.get('Description', 'N/A')}")
        print(f"State: {ami['State']}")
        print(f"\nFull AMI ID (for use in Terraform):")
        print(ami['ImageId'])
    else:
        sys.exit(1)

aws imagebuilder list-image-pipeline-images   --image-pipeline-arn "arn:aws:imagebuilder:us-east-2:422228628991:image-pipeline/ec2-image-builder-win2022"   --region us-east-2   --profile SharedServices_imagemanagement_422228628991_admin   --query 'imageSummaryList[?imageStatus==`AVAILABLE`].{ARN:arn,Version:version}'   --output json