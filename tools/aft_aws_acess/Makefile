.PHONY: help setup install install-dev clean test lint format run run-json example

help:
	@echo "AFT AWS Access Tools - Available Commands"
	@echo "=========================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make setup        - Initial setup (install uv, create venv, install deps)"
	@echo "  make install      - Install package in editable mode"
	@echo "  make install-dev  - Install package with development dependencies"
	@echo ""
	@echo "Running:"
	@echo "  make run          - Run comparison with default settings"
	@echo "  make run-json     - Run comparison with JSON output"
	@echo "  make example      - Run example usage script"
	@echo ""
	@echo "Development:"
	@echo "  make test         - Run tests"
	@echo "  make lint         - Run linters (ruff, black, mypy)"
	@echo "  make format       - Format code with black and ruff"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean        - Remove generated files and caches"
	@echo ""

setup:
	@echo "Running setup script..."
	@bash setup.sh

install:
	@echo "Installing package..."
	uv pip install -e .

install-dev:
	@echo "Installing package with development dependencies..."
	uv pip install -e ".[dev]"

clean:
	@echo "Cleaning up generated files and caches..."
	rm -rf __pycache__ .pytest_cache .mypy_cache .coverage htmlcov
	rm -rf build dist *.egg-info
	rm -f missing_groups_report.txt missing_groups_report.json
	rm -f results.txt results.json
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	@echo "✓ Cleanup complete"

test:
	@echo "Running tests..."
	pytest

lint:
	@echo "Running linters..."
	@echo "→ ruff..."
	ruff check .
	@echo "→ black..."
	black --check .
	@echo "→ mypy..."
	mypy compare_ad_groups.py
	@echo "✓ All linters passed"

format:
	@echo "Formatting code..."
	black .
	ruff check --fix .
	@echo "✓ Code formatted"

run:
	@echo "Running AD group comparison..."
	python compare_ad_groups.py

run-json:
	@echo "Running AD group comparison (JSON output)..."
	python compare_ad_groups.py --json

example:
	@echo "Running example usage script..."
	python example_usage.py

# Additional convenience targets
check: lint test
	@echo "✓ All checks passed"

venv:
	@echo "Creating virtual environment..."
	uv venv
	@echo "✓ Virtual environment created"
	@echo ""
	@echo "To activate:"
	@echo "  source .venv/bin/activate"
