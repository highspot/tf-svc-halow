# tf-svc-halow

Terraform module for Halow service per-SU resources

This module creates the AWS infrastructure required for the Halow TypeScript service:
- DynamoDB table for data storage
- KMS key for encryption
- IAM role with appropriate permissions for the Kubernetes service account
- External Secrets Operator (ESO) integration

## Features

- **DynamoDB Table**: Encrypted table with configurable billing mode
- **KMS Encryption**: Dedicated KMS key for DynamoDB encryption
- **IAM Integration**: IRSA (IAM Roles for Service Accounts) support
- **Point-in-Time Recovery**: Optional PITR for data protection
- **CloudWatch Integration**: Permissions for application logging

## Usage

```hcl
module "halow_service" {
  source = "./tf-svc-halow"
  
  aws_region              = var.aws_region
  account_id              = var.account_id
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  environment             = var.environment
  environment_type        = var.environment_type
  scale_unit              = var.scale_unit
  
  # Optional: Configure DynamoDB billing
  dynamodb_billing_mode = "PAY_PER_REQUEST"
  
  # Optional: Enable/disable point-in-time recovery
  enable_point_in_time_recovery = true
  
  tags = {
    Owner = "platform-team"
  }
}
```

## Automated README Generation

Please use the `terraform-docs` tool available from Homebrew to update the README for this
project. You need only edit the README.header.md and README.footer.md files and run
`terraform-docs markdown . > README.md && git add README.*` once you've made your changes.