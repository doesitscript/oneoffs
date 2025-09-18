# Oneoffs

A collection of one-off scripts and utilities for various tasks.

## Overview

This repository contains miscellaneous scripts, tools, and utilities that don't fit into larger projects but are useful for specific tasks.

## Structure

```
oneoffs/
├── README.md           # This file
├── scripts/            # Scripts and utilities
├── tools/              # Standalone tools
└── docs/               # Documentation
```

## Usage

Each script or tool should include its own documentation and usage instructions.

## Contributing

Feel free to add your own one-off scripts and utilities here. Please include:
- A brief description of what the script does
- Usage instructions
- Any dependencies or requirements

## Prompts
Example prompts for cast-ec2:
'where are we at in iteration 1 of project cast-ec2?'
'give me the execution plan for iteration 1 of project cast-ec2'
'update my checklist for iteration 1 of project cast-ec2'
All-in-one example:
'Give me a complete iteration status for 1 of project cast-ec2, including current progress, next steps execution plan, checklist updates based on codebase, and relevant MCP capabilities that can help with this work.'

# Show project-specific prompts
make project-prompts PROJECT=aft-account-customizations
make project-prompts PROJECT=cast-ec2