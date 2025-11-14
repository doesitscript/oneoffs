#!/usr/bin/env python3
"""
Unit tests for the compare_ad_groups module.

These tests demonstrate how to test the module functionality.
Run with: pytest tests/test_compare_ad_groups.py
"""

import csv
import tempfile
from pathlib import Path

import pytest
import yaml

from compare_ad_groups import (
    ComparisonResult,
    find_missing_groups,
    load_csv_groups,
    load_yaml_groups,
    write_results,
)


@pytest.fixture
def sample_csv_file(tmp_path):
    """Create a temporary CSV file with sample AD groups."""
    csv_file = tmp_path / "test_groups.csv"
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["AccountName", "AccountID", "ADGroupName"])
        writer.writeheader()
        writer.writerow(
            {
                "AccountName": "test-account-1",
                "AccountID": "123456789012",
                "ADGroupName": "App-AWS-AA-test-account-1-123456789012-admin",
            }
        )
        writer.writerow(
            {
                "AccountName": "test-account-2",
                "AccountID": "987654321098",
                "ADGroupName": "App-AWS-AA-test-account-2-987654321098-admin",
            }
        )
        writer.writerow(
            {
                "AccountName": "test-account-3",
                "AccountID": "555555555555",
                "ADGroupName": "App-AWS-AA-test-account-3-555555555555-admin",
            }
        )
    return csv_file


@pytest.fixture
def sample_yaml_file(tmp_path):
    """Create a temporary YAML file with sample SSO groups."""
    yaml_file = tmp_path / "test_sso_groups.yaml"
    data = [
        {
            "group_name": "App-AWS-global-admin",
            "snow_item": "RITM0000001",
            "scope": "global",
            "permission_set": "admin",
            "description": "global admin access",
        },
        {
            "group_name": "App-AWS-AA-test-account-1-123456789012-admin",
            "snow_item": "RITM0000002",
            "account_id": "123456789012",
            "scope": "account",
            "permission_set": "admin",
            "description": "admin access to test account 1",
        },
    ]
    with open(yaml_file, "w", encoding="utf-8") as f:
        yaml.dump(data, f)
    return yaml_file


@pytest.fixture
def empty_csv_file(tmp_path):
    """Create an empty CSV file with just headers."""
    csv_file = tmp_path / "empty.csv"
    with open(csv_file, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["AccountName", "AccountID", "ADGroupName"])
        writer.writeheader()
    return csv_file


@pytest.fixture
def empty_yaml_file(tmp_path):
    """Create an empty YAML file."""
    yaml_file = tmp_path / "empty.yaml"
    with open(yaml_file, "w", encoding="utf-8") as f:
        yaml.dump([], f)
    return yaml_file


class TestLoadCsvGroups:
    """Tests for load_csv_groups function."""

    def test_load_valid_csv(self, sample_csv_file):
        """Test loading groups from a valid CSV file."""
        groups = load_csv_groups(sample_csv_file)
        assert len(groups) == 3
        assert "App-AWS-AA-test-account-1-123456789012-admin" in groups
        assert "App-AWS-AA-test-account-2-987654321098-admin" in groups
        assert "App-AWS-AA-test-account-3-555555555555-admin" in groups

    def test_load_empty_csv(self, empty_csv_file):
        """Test loading groups from an empty CSV file."""
        groups = load_csv_groups(empty_csv_file)
        assert len(groups) == 0
        assert isinstance(groups, set)

    def test_load_nonexistent_csv(self, tmp_path):
        """Test loading from a non-existent CSV file."""
        nonexistent = tmp_path / "does_not_exist.csv"
        with pytest.raises(FileNotFoundError):
            load_csv_groups(nonexistent)

    def test_load_csv_missing_column(self, tmp_path):
        """Test loading CSV file without ADGroupName column."""
        csv_file = tmp_path / "invalid.csv"
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["Name", "ID"])
            writer.writeheader()
            writer.writerow({"Name": "test", "ID": "123"})

        with pytest.raises(ValueError, match="must contain 'ADGroupName' column"):
            load_csv_groups(csv_file)

    def test_load_csv_with_whitespace(self, tmp_path):
        """Test that whitespace is stripped from group names."""
        csv_file = tmp_path / "whitespace.csv"
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["ADGroupName"])
            writer.writeheader()
            writer.writerow({"ADGroupName": "  Group-With-Spaces  "})

        groups = load_csv_groups(csv_file)
        assert "Group-With-Spaces" in groups
        assert "  Group-With-Spaces  " not in groups


class TestLoadYamlGroups:
    """Tests for load_yaml_groups function."""

    def test_load_valid_yaml(self, sample_yaml_file):
        """Test loading groups from a valid YAML file."""
        groups = load_yaml_groups(sample_yaml_file)
        assert len(groups) == 2
        assert "App-AWS-global-admin" in groups
        assert "App-AWS-AA-test-account-1-123456789012-admin" in groups

    def test_load_empty_yaml(self, empty_yaml_file):
        """Test loading groups from an empty YAML file."""
        groups = load_yaml_groups(empty_yaml_file)
        assert len(groups) == 0
        assert isinstance(groups, set)

    def test_load_nonexistent_yaml(self, tmp_path):
        """Test loading from a non-existent YAML file."""
        nonexistent = tmp_path / "does_not_exist.yaml"
        with pytest.raises(FileNotFoundError):
            load_yaml_groups(nonexistent)

    def test_load_invalid_yaml_format(self, tmp_path):
        """Test loading YAML file that's not a list."""
        yaml_file = tmp_path / "invalid.yaml"
        with open(yaml_file, "w", encoding="utf-8") as f:
            f.write("not_a_list: true\n")

        with pytest.raises(ValueError, match="must contain a list"):
            load_yaml_groups(yaml_file)

    def test_load_yaml_malformed(self, tmp_path):
        """Test loading malformed YAML file."""
        yaml_file = tmp_path / "malformed.yaml"
        with open(yaml_file, "w", encoding="utf-8") as f:
            f.write("[\ninvalid yaml: content\n")

        with pytest.raises(ValueError, match="Error parsing YAML"):
            load_yaml_groups(yaml_file)

    def test_load_yaml_missing_group_name(self, tmp_path):
        """Test YAML items without group_name are skipped."""
        yaml_file = tmp_path / "no_group_name.yaml"
        data = [
            {"group_name": "ValidGroup", "scope": "global"},
            {"scope": "global"},  # Missing group_name
            {"group_name": "AnotherValidGroup"},
        ]
        with open(yaml_file, "w", encoding="utf-8") as f:
            yaml.dump(data, f)

        groups = load_yaml_groups(yaml_file)
        assert len(groups) == 2
        assert "ValidGroup" in groups
        assert "AnotherValidGroup" in groups


class TestFindMissingGroups:
    """Tests for find_missing_groups function."""

    def test_find_missing_groups_basic(self, sample_csv_file, sample_yaml_file):
        """Test finding missing groups with sample data."""
        result = find_missing_groups(sample_csv_file, sample_yaml_file)

        assert isinstance(result, ComparisonResult)
        assert result.missing_count == 2
        assert "App-AWS-AA-test-account-2-987654321098-admin" in result.missing_groups
        assert "App-AWS-AA-test-account-3-555555555555-admin" in result.missing_groups
        assert "App-AWS-AA-test-account-1-123456789012-admin" not in result.missing_groups

    def test_find_no_missing_groups(self, tmp_path):
        """Test when all CSV groups are in YAML."""
        csv_file = tmp_path / "all_present.csv"
        yaml_file = tmp_path / "all_present.yaml"

        # Create CSV
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["ADGroupName"])
            writer.writeheader()
            writer.writerow({"ADGroupName": "Group1"})
            writer.writerow({"ADGroupName": "Group2"})

        # Create YAML with same groups
        with open(yaml_file, "w", encoding="utf-8") as f:
            yaml.dump(
                [{"group_name": "Group1"}, {"group_name": "Group2"}, {"group_name": "Group3"}],
                f,
            )

        result = find_missing_groups(csv_file, yaml_file)
        assert result.missing_count == 0
        assert not result.has_missing_groups
        assert len(result.missing_groups) == 0

    def test_find_all_missing_groups(self, tmp_path):
        """Test when all CSV groups are missing from YAML."""
        csv_file = tmp_path / "all_missing.csv"
        yaml_file = tmp_path / "none_match.yaml"

        # Create CSV
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["ADGroupName"])
            writer.writeheader()
            writer.writerow({"ADGroupName": "MissingGroup1"})
            writer.writerow({"ADGroupName": "MissingGroup2"})

        # Create YAML with different groups
        with open(yaml_file, "w", encoding="utf-8") as f:
            yaml.dump([{"group_name": "DifferentGroup1"}], f)

        result = find_missing_groups(csv_file, yaml_file)
        assert result.missing_count == 2
        assert result.has_missing_groups
        assert "MissingGroup1" in result.missing_groups
        assert "MissingGroup2" in result.missing_groups

    def test_missing_groups_sorted(self, tmp_path):
        """Test that missing groups are returned in sorted order."""
        csv_file = tmp_path / "unsorted.csv"
        yaml_file = tmp_path / "empty_groups.yaml"

        # Create CSV with unsorted groups
        with open(csv_file, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=["ADGroupName"])
            writer.writeheader()
            writer.writerow({"ADGroupName": "ZGroup"})
            writer.writerow({"ADGroupName": "AGroup"})
            writer.writerow({"ADGroupName": "MGroup"})

        with open(yaml_file, "w", encoding="utf-8") as f:
            yaml.dump([], f)

        result = find_missing_groups(csv_file, yaml_file)
        assert result.missing_groups == ["AGroup", "MGroup", "ZGroup"]


class TestComparisonResult:
    """Tests for ComparisonResult dataclass."""

    def test_comparison_result_properties(self):
        """Test ComparisonResult properties."""
        result = ComparisonResult(
            missing_groups=["Group1", "Group2"],
            csv_groups={"Group1", "Group2", "Group3"},
            yaml_groups={"Group3", "Group4"},
        )

        assert result.has_missing_groups is True
        assert result.missing_count == 2

    def test_comparison_result_no_missing(self):
        """Test ComparisonResult with no missing groups."""
        result = ComparisonResult(
            missing_groups=[],
            csv_groups={"Group1", "Group2"},
            yaml_groups={"Group1", "Group2", "Group3"},
        )

        assert result.has_missing_groups is False
        assert result.missing_count == 0

    def test_comparison_result_to_dict(self):
        """Test converting ComparisonResult to dictionary."""
        csv_path = Path("/test/path.csv")
        yaml_path = Path("/test/sso.yaml")

        result = ComparisonResult(
            missing_groups=["Group1"],
            csv_groups={"Group1", "Group2"},
            yaml_groups={"Group2", "Group3"},
            csv_path=csv_path,
            yaml_path=yaml_path,
        )

        data = result.to_dict()

        assert data["missing_groups"] == ["Group1"]
        assert data["missing_count"] == 1
        assert data["total_csv_groups"] == 2
        assert data["total_yaml_groups"] == 2
        assert data["csv_path"] == str(csv_path)
        assert data["yaml_path"] == str(yaml_path)


class TestWriteResults:
    """Tests for write_results function."""

    def test_write_to_file(self, tmp_path):
        """Test writing results to a file."""
        result = ComparisonResult(
            missing_groups=["Group1", "Group2"],
            csv_groups={"Group1", "Group2", "Group3"},
            yaml_groups={"Group3"},
            csv_path=Path("test.csv"),
            yaml_path=Path("test.yaml"),
        )

        output_file = tmp_path / "output.txt"
        write_results(result, output_file)

        assert output_file.exists()
        content = output_file.read_text()
        assert "Missing Groups: 2" in content
        assert "Group1" in content
        assert "Group2" in content

    def test_write_no_missing_groups(self, tmp_path):
        """Test writing results when no groups are missing."""
        result = ComparisonResult(
            missing_groups=[],
            csv_groups={"Group1"},
            yaml_groups={"Group1"},
        )

        output_file = tmp_path / "output.txt"
        write_results(result, output_file)

        content = output_file.read_text()
        assert "All CSV groups are present in YAML" in content


class TestIntegration:
    """Integration tests for the complete workflow."""

    def test_complete_workflow(self, sample_csv_file, sample_yaml_file, tmp_path):
        """Test the complete workflow from files to output."""
        # Find missing groups
        result = find_missing_groups(sample_csv_file, sample_yaml_file)

        # Verify results
        assert result.has_missing_groups
        assert result.missing_count == 2

        # Write to file
        output_file = tmp_path / "report.txt"
        write_results(result, output_file)

        # Verify output file
        assert output_file.exists()
        content = output_file.read_text()
        assert "App-AWS-AA-test-account-2-987654321098-admin" in content
        assert "App-AWS-AA-test-account-3-555555555555-admin" in content

    def test_workflow_with_string_paths(self, sample_csv_file, sample_yaml_file):
        """Test that string paths work as well as Path objects."""
        result = find_missing_groups(str(sample_csv_file), str(sample_yaml_file))

        assert isinstance(result, ComparisonResult)
        assert result.csv_path == sample_csv_file
        assert result.yaml_path == sample_yaml_file
