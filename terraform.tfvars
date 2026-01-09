# AWS Configuration
aws_region  = "us-east-1"
aws_profile = "kompit"

# Naming
namespace    = "dso-poc-amplify" # Change to your company/org name
environment  = "poc"
stage        = "production"
app_name     = "simple-webapps-amplify" # Change to your app name
project_name = "dso-poc-amplify"

# GitHub Repository
repository_url   = "https://github.com/rguritno/simple-webapps-amplify" # CHANGE THIS
main_branch_name = "main"

# GitHub Token Secret (must exist in AWS Secrets Manager)
github_token_secret_name = "amplify/github-token"

# Build Settings
enable_auto_build = true
enable_pr_preview = false

# Platform
# Use "WEB" for static sites (HTML, React SPA, Vue, Angular)
# Use "WEB_COMPUTE" for SSR (Next.js, Nuxt.js)
platform  = "WEB"
framework = "Web"

# Environment Variables (optional)
environment_variables = {
  # Add your environment variables here
  # EXAMPLE_API_URL = "https://api.example.com"
  # NODE_ENV        = "production"
}

# Custom Domain (optional)
# Uncomment and configure if you have a custom domain
custom_domains = []
# custom_domains = [
#   {
#     domain_name           = "example.com"
#     enable_auto_sub_domain = true
#     wait_for_verification = true
#     sub_domain = [
#       {
#         branch_name = "main"
#         prefix      = ""      # apex domain (example.com)
#       },
#       {
#         branch_name = "main"
#         prefix      = "www"   # www subdomain (www.example.com)
#       }
#     ]
#   }
# ]

# Custom Rules - SPA routing (already configured by default)
custom_rules = [
  {
    source = "/<*>"
    target = "/index.html"
    status = "404-200"
  }
]

# Additional Tags
additional_tags = {
  Team       = "DevOps"
  CostCenter = "Engineering"
  ManagedBy  = "Terraform"
}
