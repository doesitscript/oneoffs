#!/usr/bin/env python3
"""
Example usage of the compare_ad_groups module.

This script demonstrates various ways to use the module for comparing
AD groups between CSV and YAML files.
"""

import json
from pathlib import Path

from compare_ad_groups import (
    find_missing_groups,
    load_csv_groups,
    load_yaml_groups,
    write_results,
)


def example_basic_usage():
    """Basic usage example."""
    print("=" * 80)
    print("Example 1: Basic Usage")
    print("=" * 80)

    result = find_missing_groups(
        csv_path="aws_recent.csv", yaml_path="../aws-access/conf/sso_groups.yaml"
    )

    if result.has_missing_groups:
        print(f"\nFound {result.missing_count} missing groups:")
        for group in result.missing_groups:
            print(f"  - {group}")
    else:
        print("\n✓ All CSV groups are present in YAML")

    print()


def example_with_custom_paths():
    """Example with custom file paths."""
    print("=" * 80)
    print("Example 2: Custom Paths")
    print("=" * 80)

    csv_path = Path("aws_recent.csv")
    yaml_path = Path("../aws-access/conf/sso_groups.yaml")

    if not csv_path.exists():
        print(f"⚠️  CSV file not found: {csv_path}")
        print()
        return

    if not yaml_path.exists():
        print(f"⚠️  YAML file not found: {yaml_path}")
        print()
        return

    result = find_missing_groups(csv_path, yaml_path)

    print(f"CSV Groups: {len(result.csv_groups)}")
    print(f"YAML Groups: {len(result.yaml_groups)}")
    print(f"Missing: {result.missing_count}")
    print()


def example_load_individual_files():
    """Example of loading files individually."""
    print("=" * 80)
    print("Example 3: Load Files Individually")
    print("=" * 80)

    try:
        csv_groups = load_csv_groups(Path("aws_recent.csv"))
        print(f"Loaded {len(csv_groups)} groups from CSV")

        yaml_groups = load_yaml_groups(Path("../aws-access/conf/sso_groups.yaml"))
        print(f"Loaded {len(yaml_groups)} groups from YAML")

        # Manual comparison
        missing = csv_groups - yaml_groups
        common = csv_groups & yaml_groups

        print(f"Common groups: {len(common)}")
        print(f"Missing groups: {len(missing)}")

        if missing:
            print("\nMissing groups:")
            for group in sorted(missing)[:5]:  # Show first 5
                print(f"  - {group}")
            if len(missing) > 5:
                print(f"  ... and {len(missing) - 5} more")

    except FileNotFoundError as e:
        print(f"⚠️  File not found: {e}")
    except ValueError as e:
        print(f"⚠️  Invalid file format: {e}")

    print()


def example_json_output():
    """Example of JSON output."""
    print("=" * 80)
    print("Example 4: JSON Output")
    print("=" * 80)

    try:
        result = find_missing_groups("aws_recent.csv", "../aws-access/conf/sso_groups.yaml")

        # Convert to dictionary
        data = result.to_dict()

        # Pretty print JSON
        print(json.dumps(data, indent=2))

    except Exception as e:
        print(f"⚠️  Error: {e}")

    print()


def example_save_to_file():
    """Example of saving results to file."""
    print("=" * 80)
    print("Example 5: Save Results to File")
    print("=" * 80)

    try:
        result = find_missing_groups("aws_recent.csv", "../aws-access/conf/sso_groups.yaml")

        output_path = Path("missing_groups_report.txt")
        write_results(result, output_path)

        print(f"✓ Report saved to: {output_path}")

        # Also save as JSON
        json_path = Path("missing_groups_report.json")
        json_path.write_text(json.dumps(result.to_dict(), indent=2), encoding="utf-8")
        print(f"✓ JSON report saved to: {json_path}")

    except Exception as e:
        print(f"⚠️  Error: {e}")

    print()


def example_conditional_processing():
    """Example of conditional processing based on results."""
    print("=" * 80)
    print("Example 6: Conditional Processing")
    print("=" * 80)

    try:
        result = find_missing_groups("aws_recent.csv", "../aws-access/conf/sso_groups.yaml")

        if result.has_missing_groups:
            print(f"⚠️  Action required: {result.missing_count} groups need to be added to YAML")

            # In a real scenario, you might:
            # - Send an email notification
            # - Create a JIRA ticket
            # - Generate a pull request
            # - Log to a monitoring system

            print("\nGroups to add:")
            for group in result.missing_groups:
                print(f"  - {group}")
        else:
            print("✓ No action needed - all groups are synchronized")

    except Exception as e:
        print(f"⚠️  Error: {e}")

    print()


def example_error_handling():
    """Example of proper error handling."""
    print("=" * 80)
    print("Example 7: Error Handling")
    print("=" * 80)

    # Try with non-existent file
    try:
        result = find_missing_groups("nonexistent.csv", "../aws-access/conf/sso_groups.yaml")
    except FileNotFoundError as e:
        print(f"✓ Caught FileNotFoundError: {e}")
    except ValueError as e:
        print(f"✓ Caught ValueError: {e}")
    except Exception as e:
        print(f"✓ Caught unexpected error: {e}")

    print()


def main():
    """Run all examples."""
    print("\n")
    print("╔" + "═" * 78 + "╗")
    print("║" + " " * 20 + "compare_ad_groups Usage Examples" + " " * 25 + "║")
    print("╚" + "═" * 78 + "╝")
    print("\n")

    # Run examples
    example_basic_usage()
    example_with_custom_paths()
    example_load_individual_files()
    example_json_output()
    example_save_to_file()
    example_conditional_processing()
    example_error_handling()

    print("=" * 80)
    print("All examples completed!")
    print("=" * 80)
    print("\nFor more information, see README.md")
    print()


if __name__ == "__main__":
    main()
