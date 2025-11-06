#!/usr/bin/env bash
#
# Verification script for combined certificate bundle setup
# This script checks that the combined certificate bundle is properly configured
#
# Usage:
#   ./verify_setup.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED++)) || true
}

log_failure() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED++)) || true
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check environment variables
check_env_vars() {
    log_info "Checking environment variables..."
    
    if [[ -n "${SSL_CERT_FILE:-}" ]]; then
        if [[ -f "$SSL_CERT_FILE" ]]; then
            CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" "$SSL_CERT_FILE" 2>/dev/null || echo "0")
            log_success "SSL_CERT_FILE is set and points to a valid bundle with $CERT_COUNT certificates"
        else
            log_failure "SSL_CERT_FILE is set but file does not exist: $SSL_CERT_FILE"
        fi
    else
        log_failure "SSL_CERT_FILE is not set"
    fi
    
    if [[ -n "${REQUESTS_CA_BUNDLE:-}" ]]; then
        if [[ -f "$REQUESTS_CA_BUNDLE" ]]; then
            log_success "REQUESTS_CA_BUNDLE is set and points to a valid bundle"
        else
            log_failure "REQUESTS_CA_BUNDLE is set but file does not exist: $REQUESTS_CA_BUNDLE"
        fi
    else
        log_warning "REQUESTS_CA_BUNDLE is not set (may still work depending on tool)"
    fi
    
    # Check if they point to the same file
    if [[ -n "${SSL_CERT_FILE:-}" ]] && [[ -n "${REQUESTS_CA_BUNDLE:-}" ]]; then
        if [[ "$SSL_CERT_FILE" == "$REQUESTS_CA_BUNDLE" ]]; then
            log_success "SSL_CERT_FILE and REQUESTS_CA_BUNDLE point to the same bundle"
        else
            log_warning "SSL_CERT_FILE and REQUESTS_CA_BUNDLE point to different files"
        fi
    fi
}

# Check Python SSL context
check_python_ssl() {
    log_info "Checking Python SSL context..."
    
    if ! command -v python3 &> /dev/null; then
        log_failure "python3 is not installed"
        return
    fi
    
    CERT_COUNT=$(python3 << 'EOF' 2>/dev/null || echo "0"
import ssl
try:
    context = ssl.create_default_context()
    certs = context.get_ca_certs()
    print(len(certs))
except Exception as e:
    print(f"ERROR: {e}")
    exit(1)
EOF
    )
    
    if [[ "$CERT_COUNT" =~ ^[0-9]+$ ]] && [[ "$CERT_COUNT" -gt 0 ]]; then
        log_success "Python can load $CERT_COUNT certificates from the bundle"
        
        # Try to identify some certs
        python3 << 'EOF' 2>/dev/null | head -5 | while read -r line; do
            echo "  $line"
        done || true
import ssl
context = ssl.create_default_context()
certs = context.get_ca_certs()
print("Sample certificate subjects:")
for cert in certs[:5]:
    subject = dict(x[0] for x in cert.get('subject', []))
    cn = subject.get('commonName', 'N/A')
    print(f"  - {cn}")
EOF
    else
        log_failure "Python cannot load certificates (got: $CERT_COUNT)"
    fi
}

# Test pip connection
test_pip_connection() {
    log_info "Testing pip connection to PyPI..."
    
    if ! command -v pip3 &> /dev/null; then
        log_warning "pip3 is not installed, skipping connection test"
        return
    fi
    
    # Try to connect to PyPI (dry run)
    if pip3 install --dry-run certifi > /dev/null 2>&1; then
        log_success "pip can connect to PyPI"
    else
        # Check if it's a certificate issue or something else
        ERROR_OUTPUT=$(pip3 install --dry-run certifi 2>&1 || true)
        if echo "$ERROR_OUTPUT" | grep -qi "certificate\|ssl\|tls"; then
            log_failure "pip cannot connect to PyPI (SSL/certificate error)"
            echo "  Error: $(echo "$ERROR_OUTPUT" | head -1)"
        else
            log_warning "pip connection test failed (may be network issue, not certificate)"
        fi
    fi
}

# Check certificate bundle composition
check_bundle_composition() {
    log_info "Checking certificate bundle composition..."
    
    if [[ -z "${SSL_CERT_FILE:-}" ]] || [[ ! -f "$SSL_CERT_FILE" ]]; then
        log_warning "Cannot check bundle composition (SSL_CERT_FILE not set or file missing)"
        return
    fi
    
    TOTAL_CERTS=$(grep -c "BEGIN CERTIFICATE" "$SSL_CERT_FILE" 2>/dev/null || echo "0")
    
    if [[ "$TOTAL_CERTS" -gt 100 ]]; then
        log_success "Bundle appears to be combined (contains $TOTAL_CERTS certificates)"
        
        # Check for corporate certs
        if grep -qi "corporate\|ads\|bread\|alliancedata" "$SSL_CERT_FILE" 2>/dev/null; then
            log_success "Bundle contains corporate certificates"
        else
            log_warning "Bundle may not contain corporate certificates (check manually)"
        fi
        
        # Check for public certs (Mozilla bundle signature)
        if grep -qi "mozilla\|curl.se" "$SSL_CERT_FILE" 2>/dev/null; then
            log_success "Bundle contains public CA certificates (Mozilla bundle)"
        else
            log_warning "Bundle may not contain public CA certificates (check manually)"
        fi
    elif [[ "$TOTAL_CERTS" -gt 0 ]]; then
        log_warning "Bundle contains only $TOTAL_CERTS certificates (may be corporate-only, missing public CAs)"
    else
        log_failure "Bundle appears to be empty or invalid"
    fi
}

# Check shell profile
check_shell_profile() {
    log_info "Checking shell profile configuration..."
    
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        PROFILE_FILE="${HOME}/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        if [[ -f "${HOME}/.bash_profile" ]]; then
            PROFILE_FILE="${HOME}/.bash_profile"
        else
            PROFILE_FILE="${HOME}/.bashrc"
        fi
    else
        PROFILE_FILE="${HOME}/.profile"
    fi
    
    if [[ ! -f "$PROFILE_FILE" ]]; then
        log_warning "Shell profile not found: $PROFILE_FILE"
        return
    fi
    
    if grep -q "SSL_CERT_FILE" "$PROFILE_FILE" 2>/dev/null; then
        SSL_LINE=$(grep "SSL_CERT_FILE" "$PROFILE_FILE" | grep -v "^#" | head -1)
        log_success "Shell profile contains SSL_CERT_FILE configuration"
        echo "  $SSL_LINE"
    else
        log_failure "Shell profile does not contain SSL_CERT_FILE configuration"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Certificate Bundle Setup Verification"
    echo "=========================================="
    echo ""
    
    check_env_vars
    echo ""
    check_bundle_composition
    echo ""
    check_python_ssl
    echo ""
    test_pip_connection
    echo ""
    check_shell_profile
    echo ""
    
    echo "=========================================="
    echo "Summary: $PASSED passed, $FAILED failed"
    echo "=========================================="
    echo ""
    
    if [[ $FAILED -eq 0 ]]; then
        log_success "All checks passed! Your certificate setup is working correctly."
        exit 0
    else
        log_failure "Some checks failed. Please review the errors above."
        exit 1
    fi
}

# Run main function
main

