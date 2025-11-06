# TLS Provider Flow Diagram

```mermaid
graph TD
    A[Terraform Configuration] --> B{Provider Declared?}
    B -->|No| C[❌ terraform init FAILS]
    B -->|Yes| D[✅ terraform init SUCCESS]
    
    D --> E[tls_private_key Resource]
    E --> F[Generate SSH Key Pair]
    F --> G[Store Private Key in Secrets Manager]
    F --> H[Create AWS Key Pair with Public Key]
    
    G --> I[EC2 Instance]
    H --> I
    I --> J[SSH Access Available]
    
    style C fill:#ffcccc
    style D fill:#ccffcc
    style J fill:#ccffcc
```

## Key Points:
- **Missing Provider Declaration** = Terraform init fails
- **Proper Provider Declaration** = Full SSH key workflow works
- **TLS Provider** handles cryptographic operations (key generation)
- **AWS Provider** handles AWS resources (EC2, Secrets Manager, Key Pairs)
