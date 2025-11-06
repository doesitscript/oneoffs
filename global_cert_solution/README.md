# Global Certificate Solution

## Problem Statement

Corporate environments often require managing SSL/TLS certificates for both:
1. **Corporate/internal CAs** - For validating certificates issued by your company's PKI (e.g., proxy, internal services, TLS inspection)
2. **Public CAs** - For validating certificates from public services (PyPI, GitHub, AWS, etc.)

### The Environment Variable Problem

The traditional approach uses environment variables to point tools to certificate bundles:

```bash
export SSL_CERT_FILE="/path/to/corp-certs.pem"
export REQUESTS_CA_BUNDLE="/path/to/corp-certs.pem"
```

**Issues with this approach:**
- ❌ **Incomplete**: Corporate bundles typically only contain internal CAs, missing public CAs needed for PyPI, GitHub, etc.
- ❌ **Tool incompatibility**: Some tools (like `uv`, Go tools) don't respect Python's SSL environment variables
- ❌ **Manual management**: Must remember to set these in every shell session, every CI/CD pipeline, every container
- ❌ **Fragile**: If the cert file path changes or is deleted, tools fail silently
- ❌ **Inconsistent**: Different tools need different configuration methods

### The Solution

**Combine corporate and public CA bundles into a single, comprehensive certificate bundle** that works system-wide.

This approach:
- ✅ Works with all Python tools (pip, requests, boto3, etc.)
- ✅ Works with tools that respect `SSL_CERT_FILE` environment variable
- ✅ Provides complete certificate chain validation (corporate + public)
- ✅ Can be combined with system keychain for maximum compatibility
- ✅ Reduces environment variable management overhead

## What This Solution Does

This solution creates a **combined certificate bundle** that includes:
1. Your corporate/internal CA certificates (from your existing bundle)
2. Public Mozilla CA bundle (for validating public SSL certificates)

The combined bundle is then:
- Set as the default via `SSL_CERT_FILE` and `REQUESTS_CA_BUNDLE` environment variables
- Can optionally be added to system keychain for tools that don't respect env vars (like `uv`)

## Files in This Directory

- `README.md` - This file (overview and problem statement)
- `INSTRUCTIONS.md` - Step-by-step implementation guide
- `setup_combined_certs.sh` - Automated setup script (optional)
- `verify_setup.sh` - Verification script to test the setup

## Quick Start

1. Review the [INSTRUCTIONS.md](./INSTRUCTIONS.md) for detailed steps
2. Run the automated setup script (if available):
   ```bash
   ./setup_combined_certs.sh
   ```
3. Verify the setup:
   ```bash
   ./verify_setup.sh
   ```

## Prerequisites

- Corporate CA bundle file (typically provided by your IT department)
- Access to download Mozilla CA bundle (or already have certifi installed)
- Shell access to modify `~/.bash_profile` or equivalent
- (Optional) sudo access if adding to system keychain

## Next Steps

See [INSTRUCTIONS.md](./INSTRUCTIONS.md) for detailed implementation steps.

