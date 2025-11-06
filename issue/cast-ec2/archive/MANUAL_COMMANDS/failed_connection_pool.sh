Client Certificates
You can also specify a client certificate. This is useful when both the server and the client need to verify each other’s identity. Typically these certificates are issued from the same authority. To use a client certificate, provide the full path when creating a PoolManager:

http = urllib3.PoolManager(
    cert_file='/path/to/your/client_cert.pem',
    cert_reqs='CERT_REQUIRED',
    ca_certs='/path/to/your/certificate_bundle')