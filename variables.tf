variable "aws_region" {
  type        = string
  description = "AWS Region - from scale unit module"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "OIDC provider for the the EKS cluster"
}

variable "environment" {
  type        = string
  description = "environment - from scale unit module"
}

variable "environment_type" {
  type        = string
  description = "environment type - from scale unit module"
}

variable "scale_unit" {
  type        = string
  description = "scale unit uname - from scale unit module"
}

variable "dynamodb_billing_mode" {
  type        = string
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)"
  default     = "PAY_PER_REQUEST"
  
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "DynamoDB billing mode must be either PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "dynamodb_read_capacity" {
  type        = number
  description = "DynamoDB read capacity units (only used if billing_mode is PROVISIONED)"
  default     = null
}

variable "dynamodb_write_capacity" {
  type        = number
  description = "DynamoDB write capacity units (only used if billing_mode is PROVISIONED)"
  default     = null
}

variable "enable_point_in_time_recovery" {
  type        = bool
  description = "Enable point-in-time recovery for DynamoDB table"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources"
  default     = {}
}