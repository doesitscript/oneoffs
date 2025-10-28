# Status Updates

## 2025-01-23 - MVP Variable Extraction Complete

**What we accomplished:**
- Successfully adapted Sanjeev's Varonis configuration for CAST
- Extracted hardcoded values into variables (name_prefix, env, domain_join_user_data)
- Updated all resource names to use CAST-specific values
- Maintained cross-account dependencies (AMI and secrets from SharedServices-imagemanagement)

**Key changes made:**
- `name_prefix = "cast"` (was "varonis")
- `env = "dev"` (from CASTSoftware-dev account name)
- `domain_join_user_data = "brd26w080n1,dev"` (was "brd03w255,prod")
- All "Production" references replaced with `${var.env}`

**Current status:**
- Configuration is ready for CAST deployment
- Networking uses corporate network access (10.0.0.0/8)
- Cross-account resources preserved (AMI from 422228628991, secrets access)
- Second drive requirement met (500GB gp3 already in config)

**Next steps:**
- Create tfvars file with CAST values
- Verify networking configuration
- Ready for testing when user is ready

## 2025-01-23 - Second Drive Made Configurable

**What we accomplished:**
- Added variables for second drive configuration (size, type, device name)
- Created example tfvars file showing different scenarios
- Made it easy to swap out drives for different use cases

**Key improvements:**
- `second_drive_size` - easily change from 500GB to 1000GB or any size
- `second_drive_type` - switch between gp3, io2, etc. for performance needs
- `second_drive_device_name` - change device if /dev/sdf is taken
- Example scenarios in `cast.tfvars.example` for common use cases

**Benefits:**
- Easy to upgrade drive size without code changes
- Can swap to high-performance drives (io2) when needed
- Can change device names if conflicts occur
- All configuration in tfvars file for easy management

**Files modified:**
- `variables.tf` - Added CAST-specific variables
- `main.tf` - Updated to use variables
- `iam.tf` - Updated to use variables
