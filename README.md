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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.7 |
| aws | ~> 4.22 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.22 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| eso | git@github.com:highspot/tf-eks-irsa-eso.git | v1.0.0 |
| iam_assumable_role | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| aws_dynamodb_table.halow | resource |
| aws_iam_policy.iam_assumable_role | resource |
| aws_kms_alias.dynamodb_halow | resource |
| aws_kms_key.dynamodb_halow | resource |
| aws_iam_policy_document.iam_assumable_role | data source |
| aws_iam_policy_document.kms_dynamodb_halow | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | AWS Account ID | `string` | n/a | yes |
| aws_region | AWS Region - from scale unit module | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_oidc_issuer_url | OIDC provider for the the EKS cluster | `string` | n/a | yes |
| environment | environment - from scale unit module | `string` | n/a | yes |
| environment_type | environment type - from scale unit module | `string` | n/a | yes |
| scale_unit | scale unit uname - from scale unit module | `string` | n/a | yes |
| dynamodb_billing_mode | DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED) | `string` | `"PAY_PER_REQUEST"` | no |
| dynamodb_read_capacity | DynamoDB read capacity units (only used if billing_mode is PROVISIONED) | `number` | `null` | no |
| dynamodb_write_capacity | DynamoDB write capacity units (only used if billing_mode is PROVISIONED) | `number` | `null` | no |
| enable_point_in_time_recovery | Enable point-in-time recovery for DynamoDB table | `bool` | `true` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| dynamodb_table_arn | ARN of the DynamoDB table |
| dynamodb_table_name | Name of the DynamoDB table |
| eso_service_account_role_arn | ARN of the External Secrets Operator service account role |
| kms_key_arn | ARN of the KMS key used for DynamoDB encryption |
| kms_key_id | ID of the KMS key used for DynamoDB encryption |
| service_account_role_arn | ARN of the IAM role for the service account |
| service_account_role_name | Name of the IAM role for the service account |

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
- AWS Secrets Manager read access for secret management functionality

Note: CloudWatch Logs permissions are not included as the application runs in Kubernetes pods and logs to stdout, which is shipped to New Relic via the cluster's logging infrastructure.

## Security

- **Encryption at Rest**: DynamoDB table encrypted with customer-managed KMS key
- **Principle of Least Privilege**: IAM role limited to specific resources
- **Service Account Integration**: Uses IRSA for secure AWS access from Kubernetes

## Monitoring

The module enables point-in-time recovery by default and creates CloudWatch logging permissions for the service.