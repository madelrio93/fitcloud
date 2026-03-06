# Full Stack Project Roadmap

> Living documentation for FitCloud - AWS Serverless Fitness Tracker

---

## Table of Contents

- [Project Philosophy](#project-philosophy)
- [AWS Services Used](#aws-services-used)
- [Tech Stack](#tech-stack)
- [Module Templates](#module-templates)

---

## Project Philosophy

- **Serverless-first**: Use managed services, avoid server maintenance
- **Cost optimization**: Target < $10/month using Free Tier
- **Infrastructure as Code**: Everything in Terraform
- **Learn-by-building**: Hands-on experience for AWS Cloud Practitioner certification
- **Living documentation**: Document as we go, step by step

---

## AWS Services Used

| Service | Purpose | Free Tier Notes |
|---------|---------|-----------------|
| S3 | Static website hosting, Terraform state | 5GB, 20K GET requests |
| CloudFront | CDN for static assets | 1GB transfer out |
| Cognito | User authentication | 50K MAU |
| Lambda | Serverless functions | 1M requests/month |
| API Gateway | REST API | 1M requests |
| DynamoDB | NoSQL database | 25 GB storage |
| Bedrock | AI (Claude) for workout plans | Paid (on-demand) |
| CloudWatch | Monitoring & logging | Basic metrics |
| IAM | Access management | Free |
| Route 53 | DNS (optional) | $0.50/month for hosted zone |
| CloudTrail | Audit logging | 1 trail, 90 days |

---

## Tech Stack

### Frontend
- React 18 + TypeScript
- Vite (build tool)
- Tailwind CSS + shadcn/ui
- AWS Amplify SDK (Cognito integration)

### Backend
- Node.js 20 (Lambda runtime)
- TypeScript
- AWS SDK v3

### Infrastructure
- Terraform (IaC)
- AWS CLI v2

### Database
- DynamoDB (single-table design)
- Partition key: `userId`
- Sort key: `entityType#timestamp`

### Authentication
- Cognito User Pools
- JWT tokens for API authorization

### AI
- AWS Bedrock (Anthropic Claude)
- Generate personalized workout plans

---

## Module Templates

### Module 0: Cloud Fundamentals & Environment Setup

**Status:** Completed
**Completed Date:** 2026-02-26

#### Task 0.1: AWS Account Security Setup
**Status:** Completed

**How-to:**
1. **Enable MFA on root account**
   - Go to AWS Console → IAM → Users → Select root account
   - Navigate to Security credentials
   - Click "Assign MFA device"
   - Choose "Virtual MFA device"
   - Use Google Authenticator or Authy to scan QR code
   - Enter two consecutive MFA codes
   - Save the MFA device ARN securely

2. **Create IAM administrator user**
   - IAM → Users → Create user
   - User name: `admin`
   - Select "Provide user access to the AWS Management Console"
   - Choose "I want to create an IAM user"
   - Enable Console password
   - Attach policy: `AdministratorAccess` (for learning)
   - Create access keys for CLI use

3. **Test IAM user access**
   - Sign out of root account
   - Sign in with new IAM user credentials
   - Verify access to billing dashboard

**Lessons Learned:**
- Never use root account for daily operations
- Root MFA is critical - no CLI access needed for root
- Create separate IAM users for each use case
- Store access keys securely - never commit to git

**Code Snippets:**
```bash
# Configure AWS CLI with new user
aws configure --profile fitcloud

# Enter when prompted:
# Access Key ID: [your-access-key]
# Secret Access Key: [your-secret-key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity --profile fitcloud

# Set as default profile
export AWS_PROFILE=fitcloud
# Or on Windows:
setx AWS_PROFILE fitcloud
```

**Resources:**
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Enabling MFA on AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable.html)

---

#### Task 0.2: Billing & Cost Management Setup
**Status:** Completed

**How-to:**
1. **Configure billing alerts**
   - Go to AWS Console → Billing → Budgets → Create budget
   - Budget type: Cost budget
   - Set budget amount: $10/month
   - Configure alert thresholds ($5, $10, $15)
   - Enter email for notifications

2. **Create AWS Budget**
   - Billing → Budgets → Create budget
   - Monthly budget: $10
   - Add alert at 50%, 80%, 100%
   - Set notification email

3. **Review Free Tier dashboard**
   - Go to Billing → Free Tier
   - Review current usage
   - Set alerts for free tier usage

**Lessons Learned:**
- Always set budgets BEFORE creating resources
- AWS Free Tier expires after 12 months for new accounts
- Some services don't have free tier (e.g., CloudWatch logs after 30 days)

---

#### Task 0.3: Local Development Tools Installation
**Status:** Completed

**How-to:**
1. **Install AWS CLI v2**
   - Windows: Download MSI installer from AWS
   - Mac: `brew install awscli` or download pkg
   - Linux: Use install script

2. **Configure AWS CLI profile**
   - Run `aws configure --profile fitcloud`
   - Enter credentials from Task 0.1
   - Set region: `us-east-1`
   - Set output: `json`

3. **Install Terraform**
   - Windows: Download from terraform.io or use chocolatey `choco install terraform`
   - Mac: `brew install terraform`
   - Linux: Use package manager or download binary

**Lessons Learned:**
- Use named profiles for different projects
- Verify installation: `aws --version` and `terraform --version`
- Keep CLI and Terraform updated

**Code Snippets:**
```bash
# Verify AWS CLI
aws --version
# Expected: aws-cli/2.x.x

# Verify Terraform
terraform --version
# Expected: Terraform v1.x.x

# Test credentials
aws sts get-caller-identity
```

---

#### Task 0.4: CloudTrail & Audit Logging
**Status:** Completed

**How-to:**
1. **Enable CloudTrail**
   - Go to CloudTrail → Create trail
   - Trail name: `fitcloud-audit-trail`
   - Storage location: Create new S3 bucket
   - Enable for all regions: Yes
   - Enable log file validation: Yes

2. **Review CloudTrail logs**
   - Go to CloudTrail → Event history
   - Filter by: Event name, Resource, Time
   - Look for API calls made during setup

**Lessons Learned:**
- CloudTrail is free for the first 90 days per trail
- Event history shows last 90 days
- Enable log file integrity validation to detect tampering

---

#### Task 0.5: Terraform State Backend Setup
**Status:** Completed

**How-to:**
1. **Create S3 bucket for Terraform state**
   - S3 → Create bucket
   - Bucket name: `fitcloud-terraform-state-<unique-id>`
   - Region: us-east-1
   - Uncheck "Block all public access" (keep all other blocks on)
   - Enable default encryption: AES-256
   - Create bucket

2. **Enable bucket versioning**
   - Go to bucket → Properties
   - Bucket Versioning → Edit → Enable
   - This allows recovery of previous state versions

3. **Create DynamoDB table for state locking**
   - DynamoDB → Create table
   - Table name: `fitcloud-terraform-locks`
   - Partition key: `LockID` (String)
   - Capacity mode: On-demand (or Provisioned with 1 RCU/WCU)
   - Create table

4. **Configure backend.tf**
   - Create file `terraform/backend.tf`:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "fitcloud-terraform-state-mdr-v1"
       key            = "dev/terraform.tfstate"
       region         = "us-east-1"
       dynamodb_table = "fitcloud-terraform-locks"
       encrypt        = true
     }
   }
   ```

5. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

**Lessons Learned:**
- Bucket names must be globally unique
- Keep backend resources in the same region as your project
- State locking prevents corruption from concurrent terraform apply
- Versioning allows recovery from accidental state deletions

**Code Snippets:**
```bash
# List S3 buckets
aws s3 ls

# Get bucket versioning status
aws s3api get-bucket-versioning --bucket fitcloud-terraform-state-mdr-v1

# Describe DynamoDB table
aws dynamodb describe-table --table-name fitcloud-terraform-locks

# Initialize Terraform backend
cd terraform
terraform init
# Expected: Successfully configured the backend "s3"!
```

**Resources:**
- [Terraform S3 Backend Documentation](https://developer.hashicorp.com/terraform/language/backend/s3)
- [S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)

---

### Module 1: Static Website Hosting (S3 + CloudFront)

**Status:** Pending

#### Task 1.1: S3 Bucket Setup
**Status:** Pending

**How-to:**

**Lessons Learned:**

**Code Snippets:**

**Resources:**

---

#### Task 1.2: CloudFront Distribution
**Status:** Pending

**How-to:**

**Lessons Learned:**

**Code Snippets:**

**Resources:**

---

#### Task 1.3: DNS & Domain (Optional)
**Status:** Pending

**How-to:**

**Lessons Learned:**

**Code Snippets:**

**Resources:**

---

### Module 2: Authentication (Cognito)

**Status:** Pending

#### Task 2.1: Cognito User Pool Setup
**Status:** Pending

#### Task 2.2: App Client Configuration
**Status:** Pending

#### Task 2.3: Cognito Identity Pool (Optional)
**Status:** Pending

---

### Module 3: Workout Tracking (DynamoDB + Lambda)

**Status:** Pending

#### Task 3.1: DynamoDB Table Design
**Status:** Pending

#### Task 3.2: Lambda Functions
**Status:** Pending

#### Task 3.3: API Gateway
**Status:** Pending

---

### Module 4: Nutrition Tracking (DynamoDB + Lambda)

**Status:** Pending

---

### Module 5: AI Workout Plans (Bedrock)

**Status:** Pending

---

### Module 6: Analytics & Dashboards

**Status:** Pending

---

### Module 7: Monitoring (CloudWatch)

**Status:** Pending

---

### Module 8: CI/CD (GitHub Actions)

**Status:** Pending

---

### Module 9: Frontend Development

**Status:** Pending

---

### Module 10: Testing & Security

**Status:** Pending

---

### Module 11: Documentation & Portfolio

**Status:** Pending

---

## Quick Reference

### Common AWS CLI Commands

```bash
# S3
aws s3 ls
aws s3 mb s3://bucket-name
aws s3 sync ./dist s3://bucket-name

# DynamoDB
aws dynamodb list-tables
aws dynamodb describe-table --table-name name

# Lambda
aws lambda list-functions
aws lambda invoke --function-name name response.json

# CloudFormation
aws cloudformation list-stacks
aws cloudformation describe-stacks --stack-name name
```

### Terraform Commands

```bash
terraform init          # Initialize backend
terraform plan          # Preview changes
terraform apply        # Apply changes
terraform destroy      # Destroy resources
terraform state list   # List resources
terraform output       # Show outputs
```

---

## Cost Tracking

| Month | Budget | Actual | Notes |
|-------|--------|--------|-------|
| Month 1 | $10 | $ | |

---

*Document last updated: 2026-02-26*
