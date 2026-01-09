terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = var.project_name
    }
  }
}

# Get GitHub token from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = var.github_token_secret_name
}

locals {
  github_token = jsondecode(data.aws_secretsmanager_secret_version.github_token.secret_string)["token"]
}

# CloudPosse Amplify App Module
module "amplify" {
  source  = "cloudposse/amplify-app/aws"
  version = "1.2.0"
  
  # Naming
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.app_name
  
  # GitHub Repository Configuration
  repository   = var.repository_url
  access_token = local.github_token
  oauth_token  = local.github_token
  
  # Build Configuration
  build_spec               = file("${path.module}/amplify.yml")
  enable_branch_auto_build = var.enable_auto_build
  
  # Platform (WEB for static, WEB_COMPUTE for SSR)
  platform = var.platform
  
  # Environment Variables
  environment_variables = var.environment_variables
  
  # Branch Configuration
  environments = {
    main = {
      branch_name                = var.main_branch_name
      framework                  = var.framework
      stage                      = "PRODUCTION"
      enable_auto_build          = var.enable_auto_build
      enable_pull_request_preview = var.enable_pr_preview
      environment_variables      = {}
    }
  }
  
  # Custom Domain (optional)
  domains = var.custom_domains
  
  # Custom Rules for SPA routing
  custom_rules = var.custom_rules
  
  # IAM Role
  iam_service_role_enabled = true
  
  # Additional Tags
  tags = var.additional_tags
}

# Outputs
output "app_id" {
  description = "Amplify App ID"
  value       = module.amplify.app_id
}

output "app_arn" {
  description = "Amplify App ARN"
  value       = module.amplify.arn
}

output "default_domain" {
  description = "Amplify default domain"
  value       = module.amplify.default_domain
}

output "app_url" {
  description = "Application URL"
  value       = "https://${module.amplify.default_domain}"
}

output "branch_names" {
  description = "Deployed branch names"
  value       = module.amplify.branch_names
}
