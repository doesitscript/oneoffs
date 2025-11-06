Aspect	Current (ViaService only)	Enhanced (with EncryptionContext)
Prevents direct KMS calls	Yes	Yes
Validates service context	Yes	Yes
Validates which secret	No	Yes
Scoped to specific secrets	No	Yes
Defense-in-depth	Basic	Stronger
Recommendation
Use the enhanced approach for better security. It ensures the key can only decrypt secrets matching your pattern, not all secrets encrypted with that key.