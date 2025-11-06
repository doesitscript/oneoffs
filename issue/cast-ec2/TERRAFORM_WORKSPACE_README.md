# Terraform Extension Workspace Setup

This workspace is configured specifically for the CAST EC2 project and CAST Terraform module development.

## Quick Start

1. **Open the workspace:**
   ```bash
   code cast-terraform.code-workspace
   ```

2. **Install recommended extensions:**
   - VS Code will prompt you to install recommended extensions
   - Or install manually: `Cmd+Shift+X` → Search for "HashiCorp Terraform"

3. **Initialize Terraform Language Server:**
   - Open Command Palette (`Cmd+Shift+P`)
   - Run: `Terraform: Initialize Language Server`
   - This downloads provider schemas for autocomplete and hover documentation

## Workspace Configuration

### Folders Included
- **CAST-EC2 Project**: Issue tracking and documentation (`/Users/a805120/develop/oneoffs/issue/cast-ec2`)
- **CAST Terraform Module**: Terraform module code (`/Users/a805120/develop/organization_repositories/aws_bfh_infrastructure/components/terraform/cast`)

### Key Features Enabled

#### ✅ Formatting
- Auto-format on save for `.tf` files
- Standard Terraform formatting (2-space indent, 120 char max line length)
- Formats all `.tf`, `.tfvars`, and `.hcl` files

#### ✅ Language Server
- **Autocomplete**: Provider-aware autocomplete for AWS resources
- **Hover Documentation**: Full documentation on hover for resources and attributes
- **Validation**: Real-time syntax and semantic validation
- **Code Lens**: Shows reference counts for resources

#### ✅ Validation
- Enhanced validation enabled
- Module validation enabled
- Provider validation enabled
- Real-time error checking

#### ✅ File Associations
- `.tf` → Terraform
- `.tfvars` → Terraform
- `.tfstate` → JSON (for viewing)
- `.hcl` → Terraform

## Available Tasks

Access tasks via `Cmd+Shift+P` → "Tasks: Run Task" or `Cmd+Shift+B`:

### Build Tasks
- **Terraform: Init** - Initialize Terraform (downloads providers)
- **Terraform: Init (Upgrade)** - Initialize with provider upgrades
- **Terraform: Format** - Format all Terraform files
- **Terraform: Plan** - Create execution plan (with tfvars)
- **Terraform: Plan (No Var File)** - Create execution plan (no tfvars)
- **Terraform: Apply** - Apply changes (interactive)
- **Terraform: Apply (Auto-approve)** - Apply without confirmation
- **Terraform: Apply (Plan File)** - Apply using saved plan file
- **Terraform: Destroy** - Destroy infrastructure

### Test Tasks
- **Terraform: Validate** - Validate configuration (default test task)
- **Terraform: Console** - Interactive console
- **Terraform: Show Outputs** - Display module outputs
- **Terraform: Show State** - Display current state

## Recommended Extensions

The workspace recommends these extensions (auto-install prompt):

1. **HashiCorp Terraform** (`hashicorp.terraform`)
   - Primary Terraform extension with language server
   - Required for all Terraform features

2. **AWS Toolkit** (`amazonwebservices.aws-toolkit-vscode`)
   - AWS resource explorer
   - CloudWatch log viewing
   - AWS credentials management

3. **YAML** (`redhat.vscode-yaml`)
   - YAML file support (for tfvars, etc.)

4. **PowerShell** (`ms-vscode.powershell`)
   - PowerShell support (for Windows user data scripts)

5. **Python** (`ms-python.python`)
   - Python support (for helper scripts)

## Settings Overview

### Terraform-Specific Settings
- **Format on Save**: ✅ Enabled
- **Language Server**: ✅ Enabled (local, not external)
- **Validation**: ✅ Enhanced validation enabled
- **Hover Docs**: ✅ Full documentation enabled
- **Code Lens**: ✅ Reference counts enabled

### Performance Optimizations
- Excluded `.terraform/` from file watching
- Excluded `terraform.tfstate*` from search
- Optimized file watcher patterns

### AWS Configuration
- **Profile**: `CASTSoftware_dev_925774240130_admin`
- All tasks use this profile automatically

## Troubleshooting

### No Autocomplete/Hover Documentation

1. **Check Language Server Status:**
   - Open Output panel (`Cmd+Shift+U`)
   - Select "Terraform" from dropdown
   - Look for initialization messages

2. **Initialize Language Server:**
   ```bash
   # In Command Palette (Cmd+Shift+P)
   Terraform: Initialize Language Server
   ```

3. **Run Terraform Init:**
   ```bash
   cd /Users/a805120/develop/organization_repositories/aws_bfh_infrastructure/components/terraform/cast
   terraform init
   ```
   This downloads provider schemas that the extension uses.

### Formatting Not Working

1. **Check default formatter:**
   - Open any `.tf` file
   - Check bottom-right corner for formatter name
   - Should show "HashiCorp Terraform"

2. **Verify extension installed:**
   - Extensions view (`Cmd+Shift+X`)
   - Search for "HashiCorp Terraform"
   - Should be installed and enabled

### Tasks Not Running

1. **Check working directory:**
   - Tasks are configured to run in the CAST Terraform Module folder
   - Verify the path is correct: `../../organization_repositories/aws_bfh_infrastructure/components/terraform/cast`

2. **Check AWS Profile:**
   - Tasks use `CASTSoftware_dev_925774240130_admin` profile
   - Verify profile exists: `aws configure list-profiles`

## Next Steps

1. Open the workspace: `code cast-terraform.code-workspace`
2. Install recommended extensions when prompted
3. Open a `.tf` file in the CAST Terraform Module folder
4. Try hovering over a resource to see documentation
5. Use `Cmd+Shift+B` to run Terraform: Validate

## Workspace Scope

**Important**: These settings are **workspace-specific** and will only apply when you open this `.code-workspace` file. They won't affect your global VS Code settings or other workspaces.

To use these settings:
- Always open the workspace file: `cast-terraform.code-workspace`
- Don't just open the folders directly

