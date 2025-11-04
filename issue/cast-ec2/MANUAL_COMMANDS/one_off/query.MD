Usage:

Basic command (uses default values):
```bash
python3 query_ami_via_mcp.py
```

This uses the default values:
- Owner: `422228628991`
- Tag Name: `GoldenAMI`
- Platform: `winserver2022`
- Region: `us-east-2`

Override parameters (in order):
```bash
python3 query_ami_via_mcp.py [OWNER] [TAG_NAME] [PLATFORM] [REGION]
```

Examples:
1. Use defaults:
   ```bash
   python3 query_ami_via_mcp.py
   ```

2. Override only the owner:
   ```bash
   python3 query_ami_via_mcp.py 123456789012
   ```

3. Override owner and tag name:
   ```bash
   python3 query_ami_via_mcp.py 123456789012 CustomTagName
   ```

4. Override all parameters:
   ```bash
   python3 query_ami_via_mcp.py 123456789012 CustomTagName winserver2019 us-west-2
   ```

The script outputs the AMI ID on the last line for use in Terraform.

Note: Ensure AWS credentials are configured (via `~/.aws/credentials`, environment variables, or AWS profile) and that the SSL certificate paths are correct for your Python installation.
python3 query_ami_via_mcp.py [OWNER] [TAG_NAME] [PLATFORM] [REGION]

python3 query_ami_via_mcp.py [OWNER] [TAG_NAME] [PLATFORM] [REGION]