#!/usr/bin/env python3
"""
Compare AD Groups from AWS Recent CSV against SSO Groups YAML

This module identifies AD group names from a CSV file that are not present
in a YAML configuration file. Designed to be used as both a standalone script
and an importable module.

Usage:
    As a script:
        python compare_ad_groups.py [--csv CSV_PATH] [--yaml YAML_PATH] [--output OUTPUT_PATH]

    As a module:
        from compare_ad_groups import find_missing_groups, ComparisonResult

        result = find_missing_groups('aws_recent.csv', 'sso_groups.yaml')
        print(result.missing_groups)
"""

import csv
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set

import yaml


@dataclass
class AccountInfo:
    """Information about an AWS account from AD group name."""

    account_name: str
    account_id: str
    group_name: str
    permission_set: str = "admin"


@dataclass
class ComparisonResult:
    """Result of comparing AD groups between CSV and YAML files."""

    missing_groups: List[str] = field(default_factory=list)
    csv_groups: Set[str] = field(default_factory=set)
    yaml_groups: Set[str] = field(default_factory=set)
    csv_path: Optional[Path] = None
    yaml_path: Optional[Path] = None
    csv_data: List[Dict[str, str]] = field(default_factory=list)

    @property
    def has_missing_groups(self) -> bool:
        """Check if there are any missing groups."""
        return len(self.missing_groups) > 0

    @property
    def missing_count(self) -> int:
        """Get count of missing groups."""
        return len(self.missing_groups)

    def to_dict(self) -> dict:
        """Convert result to dictionary."""
        return {
            "missing_groups": self.missing_groups,
            "missing_count": self.missing_count,
            "total_csv_groups": len(self.csv_groups),
            "total_yaml_groups": len(self.yaml_groups),
            "csv_path": str(self.csv_path) if self.csv_path else None,
            "yaml_path": str(self.yaml_path) if self.yaml_path else None,
        }


def parse_ad_group_name(group_name: str) -> Optional[AccountInfo]:
    """
    Parse AD group name to extract account information.

    Expected format: App-AWS-AA-{AccountName}-{AccountID}-{PermissionSet}

    Args:
        group_name: AD group name to parse

    Returns:
        AccountInfo object if parsed successfully, None otherwise
    """
    # Pattern: App-AWS-AA-{AccountName}-{AccountID}-{PermissionSet}
    # Example: App-AWS-AA-database-sandbox-941677815499-admin
    pattern = r"^App-AWS-AA-(.+?)-(\d{12})-(.+)$"
    match = re.match(pattern, group_name)

    if match:
        account_name = match.group(1)
        account_id = match.group(2)
        permission_set = match.group(3)

        return AccountInfo(
            account_name=account_name,
            account_id=account_id,
            group_name=group_name,
            permission_set=permission_set,
        )

    return None


def load_csv_groups(csv_path: Path) -> tuple[Set[str], List[Dict[str, str]]]:
    """
    Load AD group names from CSV file.

    Args:
        csv_path: Path to the CSV file containing AD groups

    Returns:
        Tuple of (Set of AD group names, List of CSV row data)

    Raises:
        FileNotFoundError: If CSV file doesn't exist
        ValueError: If CSV file is malformed or missing required column
    """
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    groups = set()
    csv_data = []

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)

        if "ADGroupName" not in reader.fieldnames:
            raise ValueError(
                f"CSV file must contain 'ADGroupName' column. Found columns: {reader.fieldnames}"
            )

        for row in reader:
            group_name = row.get("ADGroupName", "").strip()
            if group_name:
                groups.add(group_name)
                csv_data.append(row)

    return groups, csv_data


def load_yaml_groups(yaml_path: Path) -> Set[str]:
    """
    Load group names from YAML configuration file.

    Args:
        yaml_path: Path to the YAML file containing SSO groups

    Returns:
        Set of group names

    Raises:
        FileNotFoundError: If YAML file doesn't exist
        ValueError: If YAML file is malformed
    """
    if not yaml_path.exists():
        raise FileNotFoundError(f"YAML file not found: {yaml_path}")

    groups = set()

    with open(yaml_path, "r", encoding="utf-8") as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise ValueError(f"Error parsing YAML file: {e}")

    if not isinstance(data, list):
        raise ValueError("YAML file must contain a list of group configurations")

    for item in data:
        if isinstance(item, dict) and "group_name" in item:
            group_name = item["group_name"].strip()
            if group_name:
                groups.add(group_name)

    return groups


def find_missing_groups(csv_path: str | Path, yaml_path: str | Path) -> ComparisonResult:
    """
    Find AD groups in CSV that are not present in YAML.

    Args:
        csv_path: Path to CSV file with AD groups
        yaml_path: Path to YAML file with SSO groups

    Returns:
        ComparisonResult object containing missing groups and metadata

    Example:
        >>> result = find_missing_groups('aws_recent.csv', 'sso_groups.yaml')
        >>> if result.has_missing_groups:
        ...     print(f"Found {result.missing_count} missing groups")
        ...     for group in result.missing_groups:
        ...         print(f"  - {group}")
    """
    csv_path = Path(csv_path)
    yaml_path = Path(yaml_path)

    csv_groups, csv_data = load_csv_groups(csv_path)
    yaml_groups = load_yaml_groups(yaml_path)

    missing = sorted(csv_groups - yaml_groups)

    return ComparisonResult(
        missing_groups=missing,
        csv_groups=csv_groups,
        yaml_groups=yaml_groups,
        csv_path=csv_path,
        yaml_path=yaml_path,
        csv_data=csv_data,
    )


def generate_yaml_template(result: ComparisonResult) -> str:
    """
    Generate YAML template for missing groups.

    Args:
        result: ComparisonResult containing missing groups

    Returns:
        YAML formatted string with template blocks for each missing group
    """
    output_lines = []

    # Create a lookup dictionary from CSV data
    csv_lookup = {}
    for row in result.csv_data:
        group_name = row.get("ADGroupName", "").strip()
        if group_name:
            csv_lookup[group_name] = {
                "AccountName": row.get("AccountName", "").strip(),
                "AccountID": row.get("AccountID", "").strip(),
            }

    for group_name in result.missing_groups:
        # Get account info from CSV lookup
        csv_info = csv_lookup.get(group_name, {})
        account_name = csv_info.get("AccountName", "")
        account_id = csv_info.get("AccountID", "")

        # If we have CSV data, use it; otherwise try to parse from group name
        if not account_name or not account_id:
            parsed = parse_ad_group_name(group_name)
            if parsed:
                account_name = parsed.account_name
                account_id = parsed.account_id

        # Generate YAML block
        output_lines.append(f"- group_name: {group_name}")
        output_lines.append(f"  snow_item: RI____")
        output_lines.append(f'  account_id: "{account_id}"')
        output_lines.append(f"  scope: account")
        output_lines.append(f"  permission_set: admin")
        output_lines.append(f"  description: admin access to a single account")
        output_lines.append("")  # Empty line between entries

    return "\n".join(output_lines)


def write_results(result: ComparisonResult, output_path: Optional[Path] = None) -> None:
    """
    Write comparison results to a file or stdout.

    Args:
        result: ComparisonResult object
        output_path: Optional path to output file. If None, writes to stdout
    """
    output = []
    output.append("=" * 80)
    output.append("AD Group Comparison Report")
    output.append("=" * 80)
    output.append(f"CSV Source: {result.csv_path}")
    output.append(f"YAML Source: {result.yaml_path}")
    output.append(f"Total CSV Groups: {len(result.csv_groups)}")
    output.append(f"Total YAML Groups: {len(result.yaml_groups)}")
    output.append(f"Missing Groups: {result.missing_count}")
    output.append("=" * 80)

    if result.has_missing_groups:
        output.append("\nGroups in CSV but NOT in YAML:")
        output.append("-" * 80)
        for group in result.missing_groups:
            output.append(f"  - {group}")
    else:
        output.append("\n✓ All CSV groups are present in YAML")

    output.append("")

    content = "\n".join(output)

    if output_path:
        output_path.write_text(content, encoding="utf-8")
        print(f"Results written to: {output_path}")
    else:
        print(content)


def write_yaml_template(result: ComparisonResult, output_path: Optional[Path] = None) -> None:
    """
    Write YAML template for missing groups to a file or stdout.

    Args:
        result: ComparisonResult object
        output_path: Optional path to output file. If None, writes to stdout
    """
    if not result.has_missing_groups:
        message = "# No missing groups - all CSV groups are present in YAML\n"
        if output_path:
            output_path.write_text(message, encoding="utf-8")
            print(f"Template written to: {output_path}")
        else:
            print(message)
        return

    yaml_content = generate_yaml_template(result)

    if output_path:
        output_path.write_text(yaml_content, encoding="utf-8")
        print(f"YAML template written to: {output_path}")
    else:
        print(yaml_content)


def main() -> int:
    """
    Main entry point for CLI usage.

    Returns:
        Exit code (0 for success, 1 for errors)
    """
    import argparse

    parser = argparse.ArgumentParser(
        description="Compare AD groups from CSV against YAML configuration",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Use default paths
  python compare_ad_groups.py

  # Specify custom paths
  python compare_ad_groups.py --csv data/groups.csv --yaml config/sso.yaml

  # Save output to file
  python compare_ad_groups.py --output results.txt

  # Generate YAML template for missing groups
  python compare_ad_groups.py --yaml-template missing_groups.yaml
        """,
    )

    parser.add_argument(
        "--csv",
        type=Path,
        default=Path("aws_recent.csv"),
        help="Path to CSV file with AD groups (default: aws_recent.csv)",
    )

    parser.add_argument(
        "--yaml",
        type=Path,
        default=Path("../aws-access/conf/sso_groups.yaml"),
        help="Path to YAML file with SSO groups (default: ../aws-access/conf/sso_groups.yaml)",
    )

    parser.add_argument("--output", type=Path, help="Output file path (default: stdout)")

    parser.add_argument("--json", action="store_true", help="Output results as JSON")

    parser.add_argument(
        "--yaml-template",
        type=Path,
        help="Generate YAML template for missing groups and save to file",
    )

    args = parser.parse_args()

    try:
        result = find_missing_groups(args.csv, args.yaml)

        # If YAML template requested, generate it
        if args.yaml_template:
            write_yaml_template(result, args.yaml_template)
            return 0

        # Otherwise, output normal results
        if args.json:
            import json

            output_data = json.dumps(result.to_dict(), indent=2)
            if args.output:
                args.output.write_text(output_data, encoding="utf-8")
                print(f"JSON results written to: {args.output}")
            else:
                print(output_data)
        else:
            write_results(result, args.output)

        # Return non-zero exit code if there are missing groups
        return 1 if result.has_missing_groups else 0

    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        import traceback

        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())
