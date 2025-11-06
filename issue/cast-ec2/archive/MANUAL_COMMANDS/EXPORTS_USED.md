# Export Statements Used in This Session

Based on your bash history and the MCP server configuration we worked with, here are the export statements you likely used:

## Primary SSL Fix Exports

```bash
export REQUESTS_CA_BUNDLE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export SSL_CERT_FILE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
```

## Additional Exports (From MCP Configuration)

```bash
export AWS_CLI_DISABLE_SSL_VERIFY="true"
export UV_INSECURE="1"
export FASTMCP_LOG_LEVEL="ERROR"
export UV_OFFLINE="1"
```

## AWS Configuration (If Used)

```bash
export AWS_PROFILE="bfh-mgmt_admin_739275453939"
export AWS_REGION="us-east-2"
```

## One-Line Version (Most Common)

```bash
export REQUESTS_CA_BUNDLE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem" && export SSL_CERT_FILE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem" && export PYTHONWARNINGS="ignore:Unverified HTTPS request"
```

## Source the Script

You can also source the script I created:

```bash
source /Users/a805120/develop/oneoffs/issue/cast-ec2/MANUAL_COMMANDS/exports_used_in_session.sh
```

## From Bash History

Your bash history shows these were the most recent exports related to SSL:

```bash
export REQUESTS_CA_BUNDLE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export SSL_CERT_FILE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export AWS_CLI_DISABLE_SSL_VERIFY="true"
export UV_INSECURE="1"
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
export FASTMCP_LOG_LEVEL="ERROR"
export UV_OFFLINE="1"
```

These match your MCP server configuration in `~/.cursor/mcp.json` for the `awslabs.ccapi-mcp-server` and `awslabs.terraform-mcp-server`.


