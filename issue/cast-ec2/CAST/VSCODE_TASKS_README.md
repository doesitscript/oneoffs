# VSCode Tasks for CAST-EC2 Terraform Project

This directory contains VSCode tasks specifically configured for the CAST-EC2 Terraform project, targeting the CAST Software Dev account (925774240130).

## Quick Start

1. **Open the workspace**: Open `cast-ec2.code-workspace` in VSCode
2. **Access tasks**: Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) and type "Tasks: Run Task"
3. **Select a task**: Choose from the CAST-prefixed tasks

## Available Tasks

### Core Terraform Tasks

| Task | Description | Use Case |
|------|-------------|----------|
| **CAST: Terraform Init** | Initialize Terraform in CAST directory | First-time setup or after adding providers |
| **CAST: Terraform Validate** | Validate configuration syntax and semantics | Before planning or applying changes |
| **CAST: Terraform Plan** | Plan changes with dev.tfvars | Review what will be created/modified |
| **CAST: Terraform Plan (Auto-approve)** | Plan with detailed exit codes | For automation/CI pipelines |
| **CAST: Terraform Apply** | Apply changes with auto-approve | Deploy infrastructure changes |
| **CAST: Terraform Apply (Interactive)** | Apply with confirmation prompt | Safe deployment with manual approval |
| **CAST: Terraform Destroy** | Destroy all resources | Clean up development environment |

### Development & Debugging Tasks

| Task | Description | Use Case |
|------|-------------|----------|
| **CAST: Terraform Console** | Open interactive console | Test expressions and debug |
| **CAST: Terraform Format** | Format all .tf files | Code formatting and style |
| **CAST: Terraform Output** | Show outputs in JSON format | Get resource information |
| **CAST: Terraform Graph** | Generate dependency graph | Understand resource relationships |
| **CAST: Terraform State List** | List resources in state | See what's managed by Terraform |
| **CAST: Terraform Show** | Show current state and config | Debug state issues |

### Security & Quality Tasks

| Task | Description | Use Case |
|------|-------------|----------|
| **CAST: AWS Profile Check** | Verify AWS profile access | Confirm account connectivity |
| **CAST: TFLint** | Run Terraform linting | Code quality and best practices |
| **CAST: Checkov Security Scan** | Security vulnerability scan | Security compliance check |

### Workflow Tasks

| Task | Description | Use Case |
|------|-------------|----------|
| **CAST: Development Workflow** | Format → Validate → Lint → Plan | Complete pre-deployment check |
| **CAST: Security Workflow** | Validate → Security Scan → Lint | Security-focused validation |

## Configuration Details

### AWS Profile
All tasks are configured to use the AWS profile: `CASTSoftware_dev_925774240130_admin`

### Working Directory
Tasks run from: `${workspaceFolder}/issue/cast-ec2/CAST`

### Variables File
Tasks use: `dev.tfvars` for variable values

## Keyboard Shortcuts

You can create custom keyboard shortcuts for frequently used tasks:

1. Go to `File > Preferences > Keyboard Shortcuts`
2. Search for "workbench.action.tasks.runTask"
3. Add shortcuts for your most-used tasks

Example shortcuts:
```json
{
  "key": "ctrl+alt+p",
  "command": "workbench.action.tasks.runTask",
  "args": "CAST: Terraform Plan"
},
{
  "key": "ctrl+alt+a",
  "command": "workbench.action.tasks.runTask", 
  "args": "CAST: Terraform Apply"
}
```

## Task Groups

- **Build Tasks**: Init, Plan, Apply, Destroy, Format
- **Test Tasks**: Validate, Console, Output, Graph, State operations
- **Security Tasks**: AWS Profile Check, TFLint, Checkov

## Problem Matchers

Tasks include problem matchers for:
- **Terraform**: Captures validation errors and warnings
- **TFLint**: Captures linting issues with proper file/line references

## Environment Variables

Tasks automatically set:
- `AWS_PROFILE=CASTSoftware_dev_925774240130_admin`
- Working directory to CAST project folder

## Best Practices

1. **Always run Development Workflow** before applying changes
2. **Use Security Workflow** for compliance checks
3. **Check AWS Profile** if you encounter authentication issues
4. **Use Interactive Apply** for production-like deployments
5. **Run Format** before committing code changes

## Troubleshooting

### Common Issues

1. **AWS Profile Not Found**
   - Run "CAST: AWS Profile Check" to verify
   - Ensure AWS CLI is configured with the correct profile

2. **Terraform Not Found**
   - Ensure Terraform is installed and in PATH
   - Check the `terraform.path` setting in workspace

3. **Permission Denied**
   - Verify AWS profile has necessary permissions
   - Check account ID matches (925774240130)

### Getting Help

- Check the task output in the terminal panel
- Review the `dev.tfvars` file for variable configuration
- Use "CAST: Terraform Console" for expression testing

## Integration with MCP

These tasks work alongside the Terraform MCP server for:
- Module discovery and documentation
- Provider version management
- Policy compliance checking

Use the MCP tools for research and planning, then use these VSCode tasks for execution.

