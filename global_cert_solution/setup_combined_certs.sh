#!/usr/bin/env bash
#
# Automated setup script for combined certificate bundle
# This script combines corporate and public CA certificates into a single bundle
# and configures your shell environment to use it.
#
# Usage:
#   ./setup_combined_certs.sh [corporate-cert-path] [output-path]
#
# Example:
#   ./setup_combined_certs.sh /Users/username/certs/corp-rootCA-bundle.pem /Users/username/certs/combined-ca-bundle.pem

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default paths
CORP_CERT_BUNDLE="${1:-${HOME}/certs/corp-rootCA-bundle.pem}"
COMBINED_BUNDLE="${2:-${HOME}/certs/combined-ca-bundle.pem}"
MOZILLA_CERT_BUNDLE="/tmp/mozilla-cacert-$(date +%s).pem"

# Detect shell and profile file
detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        echo "zsh"
        echo "${HOME}/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        echo "bash"
        if [[ -f "${HOME}/.bash_profile" ]]; then
            echo "${HOME}/.bash_profile"
        else
            echo "${HOME}/.bashrc"
        fi
    else
        echo "unknown"
        echo "${HOME}/.profile"
    fi
}

SHELL_INFO=($(detect_shell))
DETECTED_SHELL="${SHELL_INFO[0]}"
PROFILE_FILE="${SHELL_INFO[1]}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        log_error "python3 is required but not installed"
        exit 1
    fi
    
    if [[ ! -f "$CORP_CERT_BUNDLE" ]]; then
        log_error "Corporate certificate bundle not found: $CORP_CERT_BUNDLE"
        log_info "Please provide the path to your corporate CA bundle as the first argument"
        exit 1
    fi
    
    CORP_CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" "$CORP_CERT_BUNDLE" || echo "0")
    if [[ "$CORP_CERT_COUNT" -eq 0 ]]; then
        log_error "Corporate certificate bundle appears to be empty or invalid: $CORP_CERT_BUNDLE"
        exit 1
    fi
    
    log_success "Found corporate bundle with $CORP_CERT_COUNT certificates"
}

# Download Mozilla CA bundle
download_mozilla_bundle() {
    log_info "Downloading Mozilla CA bundle..."
    
    if curl -s -f https://curl.se/ca/cacert.pem -o "$MOZILLA_CERT_BUNDLE"; then
        MOZILLA_CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" "$MOZILLA_CERT_BUNDLE" || echo "0")
        if [[ "$MOZILLA_CERT_COUNT" -gt 0 ]]; then
            log_success "Downloaded Mozilla bundle with $MOZILLA_CERT_COUNT certificates"
        else
            log_error "Downloaded file appears to be invalid"
            exit 1
        fi
    else
        log_error "Failed to download Mozilla CA bundle"
        log_info "You may need to check your network connection or proxy settings"
        exit 1
    fi
}

# Create combined bundle
create_combined_bundle() {
    log_info "Creating combined certificate bundle..."
    
    # Create output directory if it doesn't exist
    OUTPUT_DIR=$(dirname "$COMBINED_BUNDLE")
    mkdir -p "$OUTPUT_DIR"
    
    # Backup existing combined bundle if it exists
    if [[ -f "$COMBINED_BUNDLE" ]]; then
        BACKUP="${COMBINED_BUNDLE}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing bundle to: $BACKUP"
        cp "$COMBINED_BUNDLE" "$BACKUP"
    fi
    
    # Combine bundles (corporate first, then public)
    cat "$CORP_CERT_BUNDLE" "$MOZILLA_CERT_BUNDLE" > "$COMBINED_BUNDLE"
    
    COMBINED_COUNT=$(grep -c "BEGIN CERTIFICATE" "$COMBINED_BUNDLE" || echo "0")
    log_success "Created combined bundle with $COMBINED_COUNT certificates: $COMBINED_BUNDLE"
    
    # Clean up temporary Mozilla bundle
    rm -f "$MOZILLA_CERT_BUNDLE"
}

# Update shell profile
update_shell_profile() {
    log_info "Updating shell profile: $PROFILE_FILE"
    
    # Backup profile
    if [[ -f "$PROFILE_FILE" ]]; then
        BACKUP="${PROFILE_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up profile to: $BACKUP"
        cp "$PROFILE_FILE" "$BACKUP"
    fi
    
    # Remove old SSL_CERT_FILE and REQUESTS_CA_BUNDLE lines
    if [[ -f "$PROFILE_FILE" ]]; then
        sed -i.bak '/^export SSL_CERT_FILE=/d' "$PROFILE_FILE" 2>/dev/null || true
        sed -i.bak '/^export REQUESTS_CA_BUNDLE=/d' "$PROFILE_FILE" 2>/dev/null || true
        rm -f "${PROFILE_FILE}.bak" 2>/dev/null || true
    fi
    
    # Add new combined bundle configuration
    cat >> "$PROFILE_FILE" << EOF

# Combined SSL Certificate Bundle (corporate + public CAs)
# Automatically configured by setup_combined_certs.sh on $(date)
export SSL_CERT_FILE="$COMBINED_BUNDLE"
export REQUESTS_CA_BUNDLE="$COMBINED_BUNDLE"
EOF
    
    log_success "Updated $PROFILE_FILE"
}

# Verify setup
verify_setup() {
    log_info "Verifying setup..."
    
    # Check if combined bundle exists and is readable
    if [[ ! -f "$COMBINED_BUNDLE" ]]; then
        log_error "Combined bundle not found: $COMBINED_BUNDLE"
        return 1
    fi
    
    # Check if Python can load certificates
    if python3 << EOF &> /dev/null
import ssl
context = ssl.create_default_context()
certs = context.get_ca_certs()
assert len(certs) > 0, "No certificates loaded"
EOF
    then
        CERT_COUNT=$(python3 << 'EOF'
import ssl
context = ssl.create_default_context()
print(len(context.get_ca_certs()))
EOF
        )
        log_success "Python can load $CERT_COUNT certificates"
    else
        log_warning "Python may have issues loading certificates (try reloading your shell)"
    fi
    
    # Check if profile was updated
    if grep -q "SSL_CERT_FILE.*$COMBINED_BUNDLE" "$PROFILE_FILE" 2>/dev/null; then
        log_success "Shell profile updated correctly"
    else
        log_warning "Shell profile may not have been updated correctly"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Combined Certificate Bundle Setup"
    echo "=========================================="
    echo ""
    echo "Corporate bundle: $CORP_CERT_BUNDLE"
    echo "Combined bundle:  $COMBINED_BUNDLE"
    echo "Shell:            $DETECTED_SHELL"
    echo "Profile:          $PROFILE_FILE"
    echo ""
    
    check_prerequisites
    download_mozilla_bundle
    create_combined_bundle
    update_shell_profile
    verify_setup
    
    echo ""
    echo "=========================================="
    log_success "Setup complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Reload your shell configuration:"
    echo "   source $PROFILE_FILE"
    echo ""
    echo "2. Or restart your terminal"
    echo ""
    echo "3. Verify the setup:"
    echo "   echo \$SSL_CERT_FILE"
    echo "   python3 -c \"import ssl; print(len(ssl.create_default_context().get_ca_certs()))\""
    echo ""
    echo "4. Test pip connection:"
    echo "   pip3 install --dry-run certifi"
    echo ""
}

# Run main function
main

