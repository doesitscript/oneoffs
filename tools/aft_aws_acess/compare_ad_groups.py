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
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Set, Optional

import yaml


@dataclass
class ComparisonResult:
    """Result of comparing AD groups between CSV and YAML files."""

    missing_groups: List[str] = field(default_factory=list)
    csv_groups: Set[str] = field(default_factory=set)
    yaml_groups: Set[str] = field(default_factory=set)
    csv_path: Optional[Path] = None
    yaml_path: Optional[Path] = None

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
            'missing_groups': self.missing_groups,
            'missing_count': self.missing_count,
            'total_csv_groups': len(self.csv_groups),
            'total_yaml_groups': len(self.yaml_groups),
            'csv_path': str(self.csv_path) if self.csv_path else None,
            'yaml_path': str(self.yaml_path) if self.yaml_path else None,
        }


def load_csv_groups(csv_path: Path) -> Set[str]:
    """
    Load AD group names from CSV file.

    Args:
        csv_path: Path to the CSV file containing AD groups

    Returns:
        Set of AD group names

    Raises:
        FileNotFoundError: If CSV file doesn't exist
        ValueError: If CSV file is malformed or missing required column
    """
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    groups = set()

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)

        if 'ADGroupName' not in reader.fieldnames:
            raise ValueError(
                f"CSV file must contain 'ADGroupName' column. "
                f"Found columns: {reader.fieldnames}"
            )

        for row in reader:
            group_name = row.get('ADGroupName', '').strip()
            if group_name:
                groups.add(group_name)

    return groups


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

    with open(yaml_path, 'r', encoding='utf-8') as f:
        try:
            data = yaml.safe_load(f)
        except yaml.YAMLError as e:
            raise ValueError(f"Error parsing YAML file: {e}")

    if not isinstance(data, list):
        raise ValueError("YAML file must contain a list of group configurations")

    for item in data:
        if isinstance(item, dict) and 'group_name' in item:
            group_name = item['group_name'].strip()
            if group_name:
                groups.add(group_name)

    return groups


def find_missing_groups(
    csv_path: str | Path,
    yaml_path: str | Path
) -> ComparisonResult:
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

    csv_groups = load_csv_groups(csv_path)
    yaml_groups = load_yaml_groups(yaml_path)

    missing = sorted(csv_groups - yaml_groups)

    return ComparisonResult(
        missing_groups=missing,
        csv_groups=csv_groups,
        yaml_groups=yaml_groups,
        csv_path=csv_path,
        yaml_path=yaml_path,
    )


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
        output_path.write_text(content, encoding='utf-8')
        print(f"Results written to: {output_path}")
    else:
        print(content)


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
        """
    )

    parser.add_argument(
        '--csv',
        type=Path,
        default=Path('aws_recent.csv'),
        help='Path to CSV file with AD groups (default: aws_recent.csv)'
    )

    parser.add_argument(
        '--yaml',
        type=Path,
        default=Path('../aws-access/conf/sso_groups.yaml'),
        help='Path to YAML file with SSO groups (default: ../aws-access/conf/sso_groups.yaml)'
    )

    parser.add_argument(
        '--output',
        type=Path,
        help='Output file path (default: stdout)'
    )

    parser.add_argument(
        '--json',
        action='store_true',
        help='Output results as JSON'
    )

    args = parser.parse_args()

    try:
        result = find_missing_groups(args.csv, args.yaml)

        if args.json:
            import json
            output_data = json.dumps(result.to_dict(), indent=2)
            if args.output:
                args.output.write_text(output_data, encoding='utf-8')
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


if __name__ == '__main__':
    sys.exit(main())
