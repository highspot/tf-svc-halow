terraform {
  required_version = ">= 1.1.7"

  # Adding hard AWS provider versioning to ensure DynamoDB resources are created correctly
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}