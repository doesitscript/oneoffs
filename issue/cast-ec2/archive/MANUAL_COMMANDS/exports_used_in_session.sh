#!/bin/bash
# Export statements used in this session
# Based on bash history and MCP server configuration

# SSL Certificate Configuration (from MCP server setup)
export AWS_CA_BUNDLE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export REQUESTS_CA_BUNDLE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"
export SSL_CERT_FILE="/opt/homebrew/lib/python3.13/site-packages/certifi/cacert.pem"

# Suppress Python/urllib3 SSL warnings
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
# AWS CLI SSL configuration (optional - matches MCP config)
export AWS_CLI_DISABLE_SSL_VERIFY="true"

# UV/MCP Server configuration (from MCP server setup)
export  echo $UV_INSECURE="1"
export  echo $FASTMCP_LOG_LEVEL="ERROR"
export  echo $UV_OFFLINE="1"

# AWS Profile and Region (if used)
# export AWS_PROFILE="bfh-mgmt_admin_739275453939"
# export AWS_REGION="us-east-2"

echo "✅ Exports from this session applied:"
echo "   REQUESTS_CA_BUNDLE=$REQUESTS_CA_BUNDLE"
echo "   SSL_CERT_FILE=$SSL_CERT_FILE"
echo "   PYTHONWARNINGS=$PYTHONWARNINGS"
echo "   AWS_CLI_DISABLE_SSL_VERIFY=$AWS_CLI_DISABLE_SSL_VERIFY"
echo "   UV_INSECURE=$UV_INSECURE"

