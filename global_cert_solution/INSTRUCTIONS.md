# Global Certificate Solution - Implementation Instructions

## Overview

This guide walks through creating a combined certificate bundle that includes both corporate and public CA certificates, solving the problem of managing SSL certificates across different tools and environments.

## Step-by-Step Instructions

### Step 1: Locate Your Corporate CA Bundle

First, identify where your corporate certificate bundle is located. Common locations:
- `/Users/username/certs/corp-rootCA-bundle.pem`
- `/etc/ssl/certs/corporate-ca-bundle.pem`
- Provided by your IT department

**Example:**
```bash
CORP_CERT_BUNDLE="/Users/a805120/certs/corp-rootCA-bundle.pem"
```

Verify it exists and contains certificates:
```bash
grep -c "BEGIN CERTIFICATE" "$CORP_CERT_BUNDLE"
```

### Step 2: Download Mozilla CA Bundle (Public CAs)

Download the official Mozilla CA bundle which contains all public root certificates:

```bash
MOZILLA_CERT_BUNDLE="/tmp/mozilla-cacert.pem"
curl -s https://curl.se/ca/cacert.pem -o "$MOZILLA_CERT_BUNDLE"
```

**Alternative:** If you have `certifi` installed:
```bash
python3 -c "import certifi; print(certifi.where())"
```

Or install certifi first (if your current setup allows):
```bash
pip3 install certifi --user
python3 -c "import certifi; print(certifi.where())"
```

Verify the download:
```bash
grep -c "BEGIN CERTIFICATE" "$MOZILLA_CERT_BUNDLE"
# Should show ~148 certificates
```

### Step 3: Create Combined Certificate Bundle

Combine both bundles into a single file:

```bash
CORP_CERT_BUNDLE="/Users/a805120/certs/corp-rootCA-bundle.pem"
MOZILLA_CERT_BUNDLE="/tmp/mozilla-cacert.pem"
COMBINED_BUNDLE="/Users/a805120/certs/combined-ca-bundle.pem"

# Create the combined bundle
cat "$CORP_CERT_BUNDLE" "$MOZILLA_CERT_BUNDLE" > "$COMBINED_BUNDLE"

# Verify
echo "Combined bundle created with $(grep -c 'BEGIN CERTIFICATE' "$COMBINED_BUNDLE") certificates"
ls -lh "$COMBINED_BUNDLE"
```

**Note:** The corporate bundle should come first, then the public bundle. This ensures corporate certificates take precedence when both exist.

### Step 4: Update Shell Configuration

Update your shell profile to use the combined bundle. Choose the appropriate file for your shell:

**For bash:**
```bash
PROFILE_FILE="$HOME/.bash_profile"
```

**For zsh:**
```bash
PROFILE_FILE="$HOME/.zshrc"
```

Add or update these lines in your profile:

```bash
# Combined bundle: corporate CAs + public Mozilla CAs (for PyPI, GitHub, etc.)
export SSL_CERT_FILE="/Users/a805120/certs/combined-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="/Users/a805120/certs/combined-ca-bundle.pem"
```

**Example update:**
```bash
# Backup your profile first
cp "$PROFILE_FILE" "${PROFILE_FILE}.backup.$(date +%Y%m%d)"

# Add or update the SSL certificate settings
cat >> "$PROFILE_FILE" << 'EOF'

# Combined SSL Certificate Bundle (corporate + public CAs)
export SSL_CERT_FILE="/Users/a805120/certs/combined-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="/Users/a805120/certs/combined-ca-bundle.pem"
EOF
```

**Or replace existing SSL_CERT_FILE lines:**
```bash
# Remove old SSL_CERT_FILE settings
sed -i.bak '/^export SSL_CERT_FILE=/d' "$PROFILE_FILE"
sed -i.bak '/^export REQUESTS_CA_BUNDLE=/d' "$PROFILE_FILE"

# Add new combined bundle settings
cat >> "$PROFILE_FILE" << 'EOF'
# Combined bundle: corporate CAs + public Mozilla CAs (for PyPI, GitHub, etc.)
export SSL_CERT_FILE="/Users/a805120/certs/combined-ca-bundle.pem"
export REQUESTS_CA_BUNDLE="/Users/a805120/certs/combined-ca-bundle.pem"
EOF
```

### Step 5: Apply Changes

Reload your shell configuration:

```bash
source "$PROFILE_FILE"
```

Or restart your terminal.

### Step 6: Verify the Setup

Test that the combined bundle is being used:

```bash
# Check environment variables
echo "SSL_CERT_FILE: $SSL_CERT_FILE"
echo "REQUESTS_CA_BUNDLE: $REQUESTS_CA_BUNDLE"

# Verify Python can see the certificates
python3 << 'EOF'
import ssl
context = ssl.create_default_context()
certs = context.get_ca_certs()
print(f"Python loaded {len(certs)} certificates from the bundle")
print(f"First few cert subjects:")
for cert in certs[:3]:
    subject = dict(x[0] for x in cert['subject'])
    print(f"  - {subject.get('commonName', 'N/A')}")
EOF

# Test pip can connect to PyPI (should work now)
pip3 install --dry-run certifi 2>&1 | head -5
```

### Step 7: (Optional) Add to System Keychain for Maximum Compatibility

Some tools (like `uv`, Go tools) don't respect `SSL_CERT_FILE`. To make certificates work system-wide, add the corporate certs to the macOS keychain:

```bash
# Add corporate certs to system keychain (requires sudo)
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain \
  "$CORP_CERT_BUNDLE"
```

**Note:** This step is optional. The combined bundle with env vars should work for most Python tools. System keychain is only needed for tools that don't respect environment variables.

## Verification Checklist

- [ ] Corporate CA bundle exists and is readable
- [ ] Mozilla CA bundle downloaded successfully
- [ ] Combined bundle created with expected number of certificates
- [ ] Shell profile updated with new SSL_CERT_FILE paths
- [ ] Environment variables set correctly (check with `echo $SSL_CERT_FILE`)
- [ ] Python can load certificates from the bundle
- [ ] pip can connect to PyPI (test with `pip install --dry-run certifi`)
- [ ] (Optional) Corporate certs added to system keychain

## Troubleshooting

### Issue: pip still can't connect to PyPI

**Solution:** Verify the combined bundle includes public CAs:
```bash
grep -i "mozilla\|digicert\|let's encrypt" "$COMBINED_BUNDLE" | head -5
```

If nothing appears, the Mozilla bundle didn't download correctly. Re-download it.

### Issue: Environment variables not set

**Solution:** Check which shell you're using and ensure you updated the correct profile file:
```bash
echo $SHELL  # Shows your default shell
# Then check the corresponding profile file
```

### Issue: Tools like `uv` still fail

**Solution:** `uv` doesn't respect `SSL_CERT_FILE`. You have two options:
1. Use `pip` instead (works with the combined bundle)
2. Add corporate certs to system keychain and use `uv --native-tls`

### Issue: Permission denied when creating combined bundle

**Solution:** Ensure you have write permissions to the certs directory:
```bash
mkdir -p "$(dirname "$COMBINED_BUNDLE")"
chmod 755 "$(dirname "$COMBINED_BUNDLE")"
```

## Maintenance

### Updating the Corporate Bundle

When your IT department updates corporate certificates:

1. Replace the corporate bundle:
   ```bash
   cp /path/to/new-corp-certs.pem "$CORP_CERT_BUNDLE"
   ```

2. Recreate the combined bundle:
   ```bash
   cat "$CORP_CERT_BUNDLE" "$MOZILLA_CERT_BUNDLE" > "$COMBINED_BUNDLE"
   ```

3. No need to update environment variables (they point to the combined bundle)

### Updating the Mozilla Bundle

The Mozilla bundle updates periodically. To update:

```bash
# Re-download the latest Mozilla bundle
curl -s https://curl.se/ca/cacert.pem -o "$MOZILLA_CERT_BUNDLE"

# Recreate the combined bundle
cat "$CORP_CERT_BUNDLE" "$MOZILLA_CERT_BUNDLE" > "$COMBINED_BUNDLE"
```

## Benefits of This Approach

1. **Single source of truth** - One combined bundle instead of managing multiple files
2. **Works everywhere** - Python tools, curl, wget, and any tool respecting `SSL_CERT_FILE`
3. **Complete coverage** - Both corporate and public certificate validation
4. **Easy maintenance** - Update either bundle independently and recreate the combined one
5. **Reduced environment variable management** - Set once in shell profile, works everywhere

## Next Steps

- Review the automated setup script: `setup_combined_certs.sh`
- Run verification: `./verify_setup.sh`
- Consider adding corporate certs to system keychain for maximum compatibility

