## DynamoDB Table Schema

The created DynamoDB table has the following structure:

- **Table Name**: `halow-{environment}-{scale_unit}`
- **Partition Key**: `id` (String)
- **Billing Mode**: Configurable (default: PAY_PER_REQUEST)
- **Encryption**: Server-side encryption with customer-managed KMS key
- **Point-in-Time Recovery**: Enabled by default

## IAM Permissions

The created IAM role includes permissions for:

- Full DynamoDB access to the created table
- KMS key access for encryption/decryption
- CloudWatch Logs access for application logging

## Security

- **Encryption at Rest**: DynamoDB table encrypted with customer-managed KMS key
- **Principle of Least Privilege**: IAM role limited to specific resources
- **Service Account Integration**: Uses IRSA for secure AWS access from Kubernetes

## Monitoring

The module enables point-in-time recovery by default and creates CloudWatch logging permissions for the service.