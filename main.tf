locals {
  namespace    = "halow"
  service_name = "halow"
  root_arn     = "arn:aws:iam::${var.account_id}:root"
  table_name   = "halow-${var.environment}-${var.scale_unit}"
}

###############################################################################
# External Secrets Operator
###############################################################################
module "eso" {
  source                  = "git@github.com:highspot/tf-eks-irsa-eso.git?ref=v1.0.0"
  aws_region              = var.aws_region
  environment             = var.environment
  scale_unit              = var.scale_unit
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = local.namespace
  service_name            = local.service_name
}

###############################################################################
# KMS Key and Alias for DynamoDB Table
###############################################################################
resource "aws_kms_key" "dynamodb_halow" {
  description = "Key for encryption of ${local.table_name} DynamoDB table"
  policy      = data.aws_iam_policy_document.kms_dynamodb_halow.json

  tags = {
    Name        = "dynamodb-${local.table_name}"
    Environment = var.environment
    ScaleUnit   = var.scale_unit
    Service     = local.service_name
  }
}

resource "aws_kms_alias" "dynamodb_halow" {
  name          = "alias/dynamodb/${local.table_name}"
  target_key_id = aws_kms_key.dynamodb_halow.arn
}

data "aws_iam_policy_document" "kms_dynamodb_halow" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.root_arn]
    }
  }

  statement {
    sid = "Allow DynamoDB Service"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }
  }
}

###############################################################################
# DynamoDB Table
###############################################################################
resource "aws_dynamodb_table" "halow" {
  name           = local.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_halow.arn
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Add tags
  tags = {
    Name        = local.table_name
    Environment = var.environment
    ScaleUnit   = var.scale_unit
    Service     = local.service_name
  }
}

###############################################################################
# IAM Role for Halow Service Account
# 
# Allows access to KMS and DynamoDB created above
###############################################################################
module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role      = true
  role_name        = "${var.cluster_name}-${local.namespace}-${local.service_name}"
  provider_url     = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.iam_assumable_role.arn]
  oidc_subjects_with_wildcards = [
    "system:serviceaccount:${local.namespace}:${local.service_name}"
  ]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = {
    Environment = var.environment
    ScaleUnit   = var.scale_unit
    Service     = local.service_name
  }
}

resource "aws_iam_policy" "iam_assumable_role" {
  name        = "${var.cluster_name}-${local.namespace}-${local.service_name}"
  description = "${var.cluster_name} ${local.namespace}-${local.service_name} service account policy"
  policy      = data.aws_iam_policy_document.iam_assumable_role.json

  tags = {
    Environment = var.environment
    ScaleUnit   = var.scale_unit
    Service     = local.service_name
  }
}

data "aws_iam_policy_document" "iam_assumable_role" {
  # DynamoDB table access
  statement {
    sid    = "DynamoDBTableAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.halow.arn,
      "${aws_dynamodb_table.halow.arn}/index/*"
    ]
  }

  # KMS key access for DynamoDB encryption
  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.dynamodb_halow.arn]
  }

  # CloudWatch Logs (optional, for application logging)
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/eks/${var.cluster_name}/halow*"
    ]
  }

  # AWS Secrets Manager access (for Secrets tab functionality)
  statement {
    sid    = "SecretsManagerAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${var.account_id}:secret:*"
    ]
  }
}