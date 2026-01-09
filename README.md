# AWS Amplify Deployment with Terraform

Complete guide to deploy a static web app to AWS Amplify using Terraform and CloudPosse module.

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ AWS Account with appropriate permissions
- ✅ AWS CLI installed and configured
- ✅ Terraform >= 1.5 installed
- ✅ Git installed
- ✅ GitHub account and repository
- ✅ GitHub Personal Access Token

### Check Prerequisites

```bash
# Check AWS CLI
aws --version
aws sts get-caller-identity

# Check Terraform
terraform --version

# Check Git
git --version
```

## 📁 Project Structure

```
simple-webapps-amplify/
├── index.html           # Your web application
├── main.tf              # Terraform configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Your configuration values
├── amplify.yml          # Build specification
└── README.md            # This file
```

## 🚀 Step-by-Step Deployment

### Step 1: Create Project Directory

```bash
mkdir simple-webapps-amplify
cd simple-webapps-amplify
```

### Step 2: Create Files

Create the following files in your project directory:

1. **index.html** - Your web application (copy from artifact)
2. **main.tf** - Terraform configuration (copy from artifact)
3. **variables.tf** - Variable definitions (copy from artifact)
4. **terraform.tfvars** - Your configuration (copy from artifact)
5. **amplify.yml** - Build specification (copy from artifact)

### Step 3: Configure Your Settings

Edit `terraform.tfvars`:

```hcl
# Change these values
namespace      = "mycompany"          # Your company name
app_name       = "my-webapp"          # Your app name
repository_url = "https://github.com/YOUR_USERNAME/YOUR_REPO"
```

**Important:** Update `repository_url` with your actual GitHub repository!

### Step 4: Create GitHub Repository

```bash
# Initialize git
git init
git add .
git commit -m "Initial commit"

# Create repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO
git branch -M main
git push -u origin main
```

### Step 5: Create GitHub Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Tokens (classic)"**
3. Give it a name: `amplify-deployment`
4. Select scopes:
   - ✅ **repo** (Full control of private repositories)
   - ✅ **admin:repo_hook** → **write:repo_hook** and **read:repo_hook**
5. Click **"Generate token"**
6. **Copy the token** (you won't see it again!)

### Step 6: Store GitHub Token in AWS Secrets Manager

```bash
# Store your GitHub token securely
aws secretsmanager create-secret \
    --name amplify/github-token \
    --description "GitHub token for Amplify deployments" \
    --secret-string '{"token":"YOUR_GITHUB_TOKEN_HERE"}' \
    --region us-east-1

# Verify secret was created
aws secretsmanager get-secret-value \
    --secret-id amplify/github-token \
    --region us-east-1 \
    --query 'SecretString' \
    --output text
```

**Replace `YOUR_GITHUB_TOKEN_HERE` with your actual token!**

### Step 7: Initialize Terraform

```bash
# Initialize Terraform (downloads CloudPosse module)
terraform init
```

Expected output:
```
Initializing modules...
Downloading cloudposse/amplify-app/aws 1.2.0...

Terraform has been successfully initialized!
```

### Step 8: Review Terraform Plan

```bash
# See what will be created
terraform plan
```

Review the output carefully. You should see:
- Amplify App
- Amplify Branch
- IAM Role
- IAM Role Policy Attachment

### Step 9: Deploy to AWS Amplify

```bash
# Deploy!
terraform apply

# Type 'yes' when prompted
```

Wait 2-3 minutes for deployment to complete.

### Step 10: Get Your App URL

```bash
# Get the app URL
terraform output app_url
```

Output example:
```
https://main.d1234567890abc.amplifyapp.com
```

**🎉 Your app is now live!** Open the URL in your browser.

## 🔄 Making Updates

### Update Your Website

1. **Edit your files** (e.g., `index.html`)
2. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update homepage"
   git push
   ```
3. **Amplify automatically rebuilds!** (takes 1-2 minutes)

Check build status:
```bash
# Get app ID
terraform output app_id

# Open Amplify Console
echo "https://console.aws.amazon.com/amplify/home#/$(terraform output -raw app_id)"
```

### Update Terraform Configuration

1. **Edit `terraform.tfvars`** or **`main.tf`**
2. **Apply changes:**
   ```bash
   terraform plan
   terraform apply
   ```

## 🌐 Add Custom Domain (Optional)

### Step 1: Own a Domain

You need a domain from Route53, GoDaddy, Namecheap, etc.

### Step 2: Configure Domain in terraform.tfvars

Edit `terraform.tfvars`:

```hcl
custom_domains = [
  {
    domain_name           = "example.com"
    enable_auto_sub_domain = true
    wait_for_verification = true
    sub_domain = [
      {
        branch_name = "main"
        prefix      = ""      # example.com
      },
      {
        branch_name = "main"
        prefix      = "www"   # www.example.com
      }
    ]
  }
]
```

### Step 3: Apply Changes

```bash
terraform apply
```

### Step 4: Update DNS

Amplify will show you DNS records to add. You can see them in the Amplify Console.

1. Get your app ID: `terraform output app_id`
2. Open console: `https://console.aws.amazon.com/amplify/home`
3. Click your app → Domain Management
4. Copy the DNS records
5. Add them to your domain provider (Route53, GoDaddy, etc.)

Wait 10-15 minutes for DNS propagation.

## 🔧 Common Configurations

### Add Environment Variables

Edit `terraform.tfvars`:

```hcl
environment_variables = {
  API_URL     = "https://api.example.com"
  ENVIRONMENT = "production"
  DEBUG       = "false"
}
```

Apply:
```bash
terraform apply
```

### Enable Pull Request Previews

Edit `terraform.tfvars`:

```hcl
enable_pr_preview = true
```

Now every PR will get its own preview URL!

### Change AWS Region

Edit `terraform.tfvars`:

```hcl
aws_region = "ap-southeast-1"  # Singapore
```

## 📊 Useful Commands

```bash
# View outputs
terraform output

# Get specific output
terraform output app_url
terraform output app_id

# Check Terraform state
terraform show

# View Amplify app in console
aws amplify get-app --app-id $(terraform output -raw app_id)

# List deployments
aws amplify list-jobs --app-id $(terraform output -raw app_id) --branch-name main

# View build logs (get job-id from list-jobs)
aws amplify get-job --app-id $(terraform output -raw app_id) --branch-name main --job-id <job-id>
```

## 🗑️ Destroy Resources

When you want to delete everything:

```bash
# Destroy all resources
terraform destroy

# Type 'yes' when prompted
```

**Warning:** This will delete your Amplify app and all deployments!

## 🐛 Troubleshooting

### Issue: "Secret not found"

**Error:** `Error retrieving secret version: ResourceNotFoundException`

**Solution:**
```bash
# Create the secret
aws secretsmanager create-secret \
    --name amplify/github-token \
    --secret-string '{"token":"YOUR_TOKEN"}' \
    --region us-east-1
```

### Issue: "Access denied to repository"

**Error:** Build fails with repository access error

**Solution:**
1. Check GitHub token has `repo` and `admin:repo_hook` permissions
2. Regenerate token if needed
3. Update secret:
   ```bash
   aws secretsmanager update-secret \
       --secret-id amplify/github-token \
       --secret-string '{"token":"NEW_TOKEN"}'
   ```
4. Redeploy:
   ```bash
   terraform apply -replace=module.amplify.aws_amplify_app.this[0]
   ```

### Issue: "Build fails"

**Check build logs:**
```bash
# Get app ID
APP_ID=$(terraform output -raw app_id)

# Open Amplify Console
echo "https://console.aws.amazon.com/amplify/home#/$APP_ID"
```

**Common fixes:**
- Check `amplify.yml` build commands match your project
- Verify `baseDirectory` is correct
- Check Node.js version if using npm

### Issue: "Wrong AWS Account"

**Solution:**
```bash
# Check current account
aws sts get-caller-identity

# Use specific profile
export AWS_PROFILE=production
aws sts get-caller-identity
```

### Issue: "Terraform state locked"

**Error:** `Error: Error acquiring the state lock`

**Solution:**
```bash
# Force unlock (use lock ID from error message)
terraform force-unlock <LOCK_ID>
```

## 📚 Advanced Topics

### Using Different Branches

Deploy staging from a different branch:

```hcl
# In main.tf, modify environments:
environments = {
  main = {
    branch_name = "main"
    stage       = "PRODUCTION"
    # ...
  }
  staging = {
    branch_name = "staging"
    stage       = "DEVELOPMENT"
    # ...
  }
}
```

### Remote State Backend

For team collaboration, use S3 backend:

Add to `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "amplify/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Multiple Environments

Create separate directories:

```
terraform/
├── prod/
│   ├── main.tf
│   └── terraform.tfvars
└── staging/
    ├── main.tf
    └── terraform.tfvars
```

## 🔐 Security Best Practices

1. **Never commit secrets** - Use AWS Secrets Manager
2. **Use IAM roles** when possible instead of access keys
3. **Enable CloudTrail** for audit logging
4. **Use separate AWS accounts** for prod/staging
5. **Rotate GitHub tokens** regularly
6. **Review IAM permissions** periodically

## 💰 Cost Estimation

**AWS Amplify Pricing:**

- **Build minutes:** $0.01 per minute (free tier: 1000 minutes/month)
- **Hosting:** $0.15 per GB served (free tier: 15 GB/month)
- **Storage:** $0.023 per GB/month (free tier: 5 GB)

**Typical costs for a small app:**
- ~$0/month (stays in free tier)
- After free tier: ~$5-20/month depending on traffic

## 🔗 Resources

- [CloudPosse Amplify Module](https://github.com/cloudposse/terraform-aws-amplify-app)
- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amplify Pricing](https://aws.amazon.com/amplify/pricing/)

## 📞 Support

**Need help?**

1. Check the troubleshooting section
2. Review Amplify Console logs
3. Check Terraform plan output
4. Verify AWS credentials and permissions

## ✅ Quick Reference

```bash
# Setup
terraform init

# Deploy
terraform plan
terraform apply

# Update website
git add .
git commit -m "Update"
git push

# Get URL
terraform output app_url

# Destroy
terraform destroy
```

---

**You're ready to deploy! 🚀**

Start with Step 1 and follow each step carefully. Good luck!
