output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.halow.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.halow.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_halow.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_halow.arn
}

output "service_account_role_arn" {
  description = "ARN of the IAM role for the service account"
  value       = module.iam_assumable_role.iam_role_arn
}

output "service_account_role_name" {
  description = "Name of the IAM role for the service account"
  value       = module.iam_assumable_role.iam_role_name
}

output "eso" {
  description = "External Secrets Operator module outputs"
  value       = module.eso
}