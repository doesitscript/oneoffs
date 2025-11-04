#!/usr/bin/env python3
"""
Get the location of the certifi certificate bundle.
This script provides the same output as: python3 -c "import certifi; print(certifi.where())"
"""

import certifi
import sys

def get_certifi_location():
    """
    Get the location of the certifi certificate bundle.
    
    Returns:
        str: Path to the certificate bundle file
    """
    try:
        cert_path = certifi.where()
        return cert_path
    except Exception as e:
        print(f"Error getting certifi location: {e}", file=sys.stderr)
        raise

if __name__ == '__main__':
    try:
        cert_location = get_certifi_location()
        print(f"Certifi certificate bundle location:")
        print(cert_location)
        
        # Additional useful information
        print(f"\nYou can use this in your environment variables:")
        print(f"export SSL_CERT_FILE='{cert_location}'")
        print(f"export REQUESTS_CA_BUNDLE='{cert_location}'")
        
    except Exception as e:
        print(f"Failed to get certifi location: {e}", file=sys.stderr)
        sys.exit(1)