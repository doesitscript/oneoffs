#!/usr/bin/env python3
"""
List EC2 instances and their tags in the CAST account.

This script uses the CAST AWS profile to connect and list all instances
with their associated tags for research purposes.
"""

import boto3
import json
from typing import List, Dict, Any
from datetime import datetime


def get_ec2_client(profile_name: str, region: str = "us-east-2"):
    """Create an EC2 client using the specified AWS profile."""
    session = boto3.Session(profile_name=profile_name)
    return session.client("ec2", region_name=region)


def list_all_instances(ec2_client) -> List[Dict[str, Any]]:
    """List all EC2 instances in the account."""
    instances = []
    paginator = ec2_client.get_paginator("describe_instances")

    for page in paginator.paginate():
        for reservation in page.get("Reservations", []):
            for instance in reservation.get("Instances", []):
                instances.append(instance)

    return instances


def format_tags(tags: List[Dict[str, str]]) -> Dict[str, str]:
    """Convert AWS tag format to a simple dictionary."""
    if not tags:
        return {}
    return {tag["Key"]: tag["Value"] for tag in tags}


def format_instance_info(instance: Dict[str, Any]) -> Dict[str, Any]:
    """Extract and format relevant instance information."""
    return {
        "InstanceId": instance.get("InstanceId"),
        "InstanceType": instance.get("InstanceType"),
        "State": instance.get("State", {}).get("Name"),
        "LaunchTime": (
            instance.get("LaunchTime").isoformat()
            if instance.get("LaunchTime")
            else None
        ),
        "PrivateIpAddress": instance.get("PrivateIpAddress"),
        "PublicIpAddress": instance.get("PublicIpAddress"),
        "Tags": format_tags(instance.get("Tags", [])),
        "VpcId": instance.get("VpcId"),
        "SubnetId": instance.get("SubnetId"),
        "SecurityGroups": [
            {"GroupId": sg.get("GroupId"), "GroupName": sg.get("GroupName")}
            for sg in instance.get("SecurityGroups", [])
        ],
    }


def main():
    """Main function to list CAST instances and their tags."""
    # CAST profile name found in AWS config
    profile_name = "CASTSoftware_dev_925774240130_admin"
    region = "us-east-2"

    print(f"Connecting to AWS using profile: {profile_name}")
    print(f"Region: {region}\n")

    try:
        ec2 = get_ec2_client(profile_name, region)
        instances = list_all_instances(ec2)

        print(f"Found {len(instances)} EC2 instance(s)\n")
        print("=" * 80)

        if not instances:
            print("No instances found in this account.")
            return

        # Format and display each instance
        formatted_instances = []
        for instance in instances:
            info = format_instance_info(instance)
            formatted_instances.append(info)

            print(f"\nInstance ID: {info['InstanceId']}")
            print(f"  Type: {info['InstanceType']}")
            print(f"  State: {info['State']}")
            print(f"  Launch Time: {info['LaunchTime']}")
            print(f"  Private IP: {info['PrivateIpAddress']}")
            print(f"  Public IP: {info['PublicIpAddress']}")
            print(f"  VPC: {info['VpcId']}")
            print(f"  Subnet: {info['SubnetId']}")

            if info["Tags"]:
                print(f"  Tags ({len(info['Tags'])}):")
                for key, value in sorted(info["Tags"].items()):
                    print(f"    {key} = {value}")
            else:
                print("  Tags: None")

            if info["SecurityGroups"]:
                print(f"  Security Groups ({len(info['SecurityGroups'])}):")
                for sg in info["SecurityGroups"]:
                    print(f"    {sg['GroupName']} ({sg['GroupId']})")

            print("-" * 80)

        # Also output as JSON for easy parsing
        print("\n" + "=" * 80)
        print("JSON Output:")
        print("=" * 80)
        print(json.dumps(formatted_instances, indent=2, default=str))

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    exit(main())
