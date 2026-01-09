# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# Naming Convention
variable "namespace" {
  description = "Namespace (e.g., company name or organization)"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "stage" {
  description = "Stage name (e.g., production, development)"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "amplify-app"
}

# Repository Configuration
variable "repository_url" {
  description = "GitHub repository URL (e.g., https://github.com/username/repo)"
  type        = string
}

variable "main_branch_name" {
  description = "Main branch name to deploy"
  type        = string
  default     = "main"
}

variable "github_token_secret_name" {
  description = "AWS Secrets Manager secret name containing GitHub token"
  type        = string
  default     = "amplify/github-token"
}

# Build Configuration
variable "enable_auto_build" {
  description = "Enable automatic builds on git push"
  type        = bool
  default     = true
}

variable "enable_pr_preview" {
  description = "Enable pull request preview deployments"
  type        = bool
  default     = false
}

variable "platform" {
  description = "Platform type: WEB (static) or WEB_COMPUTE (SSR)"
  type        = string
  default     = "WEB"
  
  validation {
    condition     = contains(["WEB", "WEB_COMPUTE"], var.platform)
    error_message = "Platform must be either WEB or WEB_COMPUTE"
  }
}

variable "framework" {
  description = "Frontend framework"
  type        = string
  default     = "Web"
}

# Environment Variables
variable "environment_variables" {
  description = "Environment variables for the application"
  type        = map(string)
  default     = {}
}

# Custom Domain Configuration
variable "custom_domains" {
  description = "Custom domain configurations"
  type = list(object({
    domain_name           = string
    enable_auto_sub_domain = bool
    wait_for_verification = bool
    sub_domain = list(object({
      branch_name = string
      prefix      = string
    }))
  }))
  default = []
}

# Custom Rules (Redirects/Rewrites)
variable "custom_rules" {
  description = "Custom rewrite and redirect rules"
  type = list(object({
    source = string
    target = string
    status = string
  }))
  default = [
    {
      source = "/<*>"
      target = "/index.html"
      status = "404-200"
    }
  ]
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
