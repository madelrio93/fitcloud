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

| Service     | Purpose                                 | Free Tier Notes             |
| ----------- | --------------------------------------- | --------------------------- |
| S3          | Static website hosting, Terraform state | 5GB, 20K GET requests       |
| CloudFront  | CDN for static assets                   | 1GB transfer out            |
| Cognito     | User authentication                     | 50K MAU                     |
| Lambda      | Serverless functions                    | 1M requests/month           |
| API Gateway | REST API                                | 1M requests                 |
| DynamoDB    | NoSQL database                          | 25 GB storage               |
| Bedrock     | AI (Claude) for workout plans           | Paid (on-demand)            |
| CloudWatch  | Monitoring & logging                    | Basic metrics               |
| IAM         | Access management                       | Free                        |
| Route 53    | DNS (optional)                          | $0.50/month for hosted zone |
| CloudTrail  | Audit logging                           | 1 trail, 90 days            |

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

**Status:** In Progress
**AWS Domain:** Global Infrastructure, S3, CloudFront | Estimated: 3-4 hours | Priority: High
**Free Tier:** S3 = 5GB + 20K GET requests/month | CloudFront = 1GB transfer out/month

#### Key Concepts to Understand

**Amazon S3 (Simple Storage Service):**

- **Bucket** - A container for objects. Bucket names are **globally unique** across all AWS accounts.
- **Object** - A file + metadata. Identified by a key (the file path, e.g. `index.html` or `assets/style.css`).
- **Region** - Buckets live in a specific AWS region (ours: `us-east-1`).
- **Bucket Policy** - A JSON document that defines who can access what in the bucket.
- **Block Public Access** - A safety mechanism that overrides any policy to prevent accidental public exposure. **Keep this ON.**
- **Versioning** - Keeps multiple versions of objects. Useful for rollback.
- S3 has 99.999999999% (11 nines) durability.
- S3 is NOT a file system -- it's object storage (no folders, just key prefixes).
- Maximum object size: 5 TB.
- S3 supports server-side encryption (SSE-S3, SSE-KMS, SSE-C).

**Amazon CloudFront (CDN):**

- **Distribution** - A CloudFront configuration that tells AWS which origin to pull content from and how to serve it.
- **Origin** - Where CloudFront fetches the original content (your S3 bucket).
- **Edge Location** - A data center close to end users where content gets cached. 400+ worldwide.
- **TTL (Time to Live)** - How long CloudFront caches content before checking the origin again.
- **Cache Invalidation** - Force CloudFront to re-fetch content from origin (costs money after 1,000 paths/month).
- **Default Root Object** - The file served when someone visits the root URL (e.g., `index.html`).
- **Viewer Protocol Policy** - Controls HTTP vs HTTPS (`redirect-to-https` is recommended).
- **Price Class** - Limits which edge locations are used to reduce cost:
  - `PriceClass_100` = cheapest (US, Canada, Europe)
  - `PriceClass_200` = adds Asia, Middle East, Africa
  - `PriceClass_All` = all edge locations
- CloudFront is a **global service** (not regional).
- Supports HTTPS via ACM certificates (must be in `us-east-1`).

**Origin Access Control (OAC):**

- The **modern, recommended** way to connect CloudFront to a private S3 bucket. Replaced the older OAI (Origin Access Identity).
- Your S3 bucket stays **100% private** (Block Public Access = ON).
- Only CloudFront can read from S3 using cryptographic signing (SigV4).
- Users **cannot** bypass CloudFront and hit S3 directly.
- How it works:
  1. CloudFront signs every request to S3 using SigV4
  2. S3 bucket policy checks the signature matches CloudFront's ARN
  3. If valid, S3 returns the object; if not, 403 Access Denied

#### Architecture Diagram

```
User (browser)
    |
    v
CloudFront (edge location, HTTPS)
    |
    v (OAC - signed request)
S3 Bucket (private, stores index.html, assets, etc.)
```

- Users **never** talk to S3 directly
- CloudFront caches content close to users
- S3 stays private and secure

---

#### Task 1.1: S3 Bucket Setup

**Status:** Pending

**What you'll create:**

1. An S3 bucket for your website files
2. Block Public Access settings (all ON)
3. Bucket versioning enabled

**Terraform resources used:**

| Resource                            | Purpose                  |
| ----------------------------------- | ------------------------ |
| `aws_s3_bucket`                     | Creates the bucket       |
| `aws_s3_bucket_versioning`          | Enables versioning       |
| `aws_s3_bucket_public_access_block` | Blocks all public access |

**How-to:**

1. **Create S3 bucket for website hosting**
   - In `terraform/main.tf`, declare an `aws_s3_bucket` resource
   - Use a naming convention like `fitcloud-website-<environment>`
   - Add `Project` and `Environment` tags for cost tracking
   - Bucket names must be globally unique across ALL AWS accounts

2. **Configure bucket for static website hosting**
   - We do **NOT** enable S3 static website hosting (that requires public access)
   - Instead, we keep the bucket private and serve content via CloudFront + OAC
   - This is the modern, secure approach

3. **Enable bucket versioning**
   - Declare an `aws_s3_bucket_versioning` resource
   - Set `status = "Enabled"`
   - This allows recovery if files are accidentally overwritten or deleted

4. **Block all public access**
   - Declare an `aws_s3_bucket_public_access_block` resource
   - Set all four settings to `true`:
     - `block_public_acls` - Blocks new public ACLs
     - `block_public_policy` - Blocks new public bucket policies
     - `ignore_public_acls` - Ignores existing public ACLs
     - `restrict_public_buckets` - Restricts public bucket policies

**Lessons Learned:**

- Never enable S3 static website hosting when using CloudFront + OAC. It requires public access which defeats the purpose.
- Bucket names are globally unique -- if `fitcloud-website-dev` is taken, you need a different name.
- Versioning adds a small storage cost but is worth it for recovery.
- Block Public Access is a safety net -- even if a bucket policy allows public access, this overrides it.

**Code Snippets:**

```hcl
# terraform/main.tf - S3 Bucket resources

resource "aws_s3_bucket" "website" {
  bucket = "fitcloud-website-${var.environment}"

  tags = {
    Project     = "FitCloud"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

```bash
# Verify bucket was created
aws s3 ls | grep fitcloud

# Check versioning status
aws s3api get-bucket-versioning --bucket fitcloud-website-dev

# Check public access block
aws s3api get-public-access-block --bucket fitcloud-website-dev
```

**Study Questions:**

- Why do we keep the bucket private instead of enabling S3 static website hosting?
- What does each of the 4 `block_public_access` settings do?
- Why enable versioning on a website bucket?
- What happens if the bucket name is already taken by another AWS account?

**Resources:**

- [S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [Terraform aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
- [Terraform aws_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)

---

#### Task 1.2: CloudFront Distribution

**Status:** Pending

**What you'll create:**

1. Origin Access Control (OAC) for secure S3 access
2. CloudFront distribution pointing to S3
3. S3 bucket policy that only allows CloudFront
4. Custom error pages for SPA routing (React needs this!)

**Terraform resources used:**

| Resource                               | Purpose                          |
| -------------------------------------- | -------------------------------- |
| `aws_cloudfront_origin_access_control` | Creates OAC for S3               |
| `aws_cloudfront_distribution`          | Creates the CDN distribution     |
| `data.aws_iam_policy_document`         | Builds the bucket policy as JSON |
| `aws_s3_bucket_policy`                 | Applies the policy to the bucket |

**How-to:**

1. **Create Origin Access Control (OAC)**
   - Declare an `aws_cloudfront_origin_access_control` resource
   - Set `origin_access_control_origin_type = "s3"`
   - Set `signing_behavior = "always"` (CloudFront always signs requests)
   - Set `signing_protocol = "sigv4"` (AWS Signature Version 4)

2. **Create CloudFront distribution**
   - Declare an `aws_cloudfront_distribution` resource
   - Set origin to S3 bucket using `bucket_regional_domain_name` (NOT the website endpoint)
   - Link OAC via `origin_access_control_id`
   - Set `default_root_object = "index.html"`
   - Set `price_class = "PriceClass_100"` (cheapest - US, Canada, Europe)
   - Configure `default_cache_behavior`:
     - `allowed_methods = ["GET", "HEAD", "OPTIONS"]` (read-only)
     - `viewer_protocol_policy = "redirect-to-https"` (force HTTPS)
     - Set TTL values for caching (default: 1 hour)
   - Add `custom_error_response` blocks for 403 and 404 errors:
     - Return `/index.html` with status 200
     - This is **critical** for React SPA client-side routing
   - Use `cloudfront_default_certificate = true` for the free `*.cloudfront.net` domain

3. **Configure SSL/TLS certificate (ACM)**
   - For now, we use the default CloudFront certificate (`*.cloudfront.net`)
   - If adding a custom domain later, create an ACM certificate in `us-east-1`
   - CloudFront **only** accepts ACM certs from `us-east-1` (N. Virginia)

4. **Set up custom error pages (SPA routing)**
   - Since FitCloud is a React SPA, routes like `/dashboard` or `/workouts` don't exist as files in S3
   - When CloudFront asks S3 for `/dashboard`, S3 returns 403 (object not found in private bucket)
   - The `custom_error_response` catches 403/404 and returns `index.html` with status 200
   - React Router then handles the route client-side

5. **Create S3 bucket policy allowing CloudFront**
   - Use `data.aws_iam_policy_document` to build the policy
   - Allow `s3:GetObject` from `cloudfront.amazonaws.com` service principal
   - Add a condition: `AWS:SourceArn` must match your CloudFront distribution ARN
   - This ensures only YOUR CloudFront distribution can read from the bucket
   - Add `depends_on = [aws_s3_bucket_public_access_block.website]` to ensure correct ordering

**Lessons Learned:**

- Use OAC, not the legacy OAI. OAC is the AWS-recommended approach and supports all S3 regions.
- Use `bucket_regional_domain_name` (not `bucket_domain_name`) to avoid redirect issues.
- The `custom_error_response` for SPA routing is essential -- without it, refreshing on any route other than `/` returns an error.
- CloudFront distributions take 5-15 minutes to deploy. Be patient.
- The `AWS:SourceArn` condition in the bucket policy is important -- without it, ANY CloudFront distribution could access your bucket.
- `PriceClass_100` is sufficient for learning and costs significantly less than `PriceClass_All`.
- Cache invalidation is free for the first 1,000 paths per month. After that, $0.005 per path.

**Code Snippets:**

```hcl
# terraform/main.tf - CloudFront + OAC resources

# --- OAC ---
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "fitcloud-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- CloudFront Distribution ---
resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
    origin_id                = "S3-fitcloud-website"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-fitcloud-website"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # IMPORTANT for React SPA: return index.html for 403/404
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = "FitCloud"
    Environment = var.environment
  }
}

# --- S3 Bucket Policy (allow CloudFront) ---
data "aws_iam_policy_document" "website" {
  statement {
    sid    = "AllowCloudFrontReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website.json

  depends_on = [aws_s3_bucket_public_access_block.website]
}
```

```hcl
# terraform/outputs.tf

output "website_bucket_name" {
  description = "Name of the S3 website bucket"
  value       = aws_s3_bucket.website.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (your site URL)"
  value       = aws_cloudfront_distribution.website.domain_name
}
```

```bash
# Deploy the infrastructure
cd terraform
terraform fmt -recursive
terraform validate
terraform plan
terraform apply

# Note the cloudfront_domain_name output after apply

# Upload a test index.html to verify
echo "<h1>FitCloud Works!</h1>" > /tmp/index.html
aws s3 cp /tmp/index.html s3://fitcloud-website-dev/index.html

# Visit https://<cloudfront-domain>.cloudfront.net in your browser

# Verify S3 direct access is blocked (should return 403)
# Try: https://fitcloud-website-dev.s3.amazonaws.com/index.html

# Invalidate cache if needed (after updating files)
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"
```

**Study Questions:**

- What is the difference between OAC and the older OAI?
- Why must `signing_behavior` be `"always"`?
- Why use `PriceClass_100` instead of `PriceClass_All`?
- What does `viewer_protocol_policy = "redirect-to-https"` do?
- Why do we need `depends_on` for the bucket policy?
- Why do we need `custom_error_response` for a React SPA?
- What is the `AWS:SourceArn` condition protecting against?
- Why use `bucket_regional_domain_name` instead of `bucket_domain_name`?

**Resources:**

- [CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- [OAC vs OAI comparison](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
- [Terraform aws_cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)
- [Terraform aws_cloudfront_origin_access_control](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control)

---

#### Task 1.3: DNS & Domain (Optional)

**Status:** Pending

**What you'll create (if you choose to):**

1. Route 53 hosted zone for your domain
2. ACM certificate for SSL/TLS (must be in `us-east-1`)
3. Route 53 alias record pointing to CloudFront

**Note:** Skip this task if you don't want to pay for a domain. The free `*.cloudfront.net` URL works fine for learning. You can always add a custom domain later.

**Cost:** ~$0.50/month for Route 53 hosted zone + ~$12/year for `.com` domain registration.

**How-to:**

1. **Register domain (Route 53)**
   - Go to Route 53 Console -> Registered domains -> Register domain
   - Choose a domain name (e.g., `fitcloud-app.com`)
   - Complete registration (~$12/year for `.com`)
   - Route 53 automatically creates a hosted zone

2. **Create Route 53 hosted zone** (if not auto-created)
   - Route 53 -> Hosted zones -> Create hosted zone
   - Enter your domain name
   - Note the NS (nameserver) records

3. **Create ACM certificate**
   - **IMPORTANT:** Must be created in `us-east-1` for CloudFront
   - ACM Console (in us-east-1) -> Request certificate
   - Request a public certificate
   - Domain: `*.yourdomain.com` and `yourdomain.com`
   - Validation: DNS validation (recommended)
   - Add the CNAME validation records to Route 53
   - Wait for validation (usually 5-30 minutes)

4. **Configure alias record for CloudFront**
   - Route 53 -> Hosted zone -> Create record
   - Record type: A (IPv4)
   - Enable "Alias"
   - Route traffic to: CloudFront distribution
   - Select your distribution

5. **Update CloudFront distribution**
   - Add `aliases` with your domain name
   - Update `viewer_certificate` to use your ACM certificate ARN
   - Set `ssl_support_method = "sni-only"`

**Lessons Learned:**

- ACM certificates for CloudFront **must** be in `us-east-1` regardless of where other resources live.
- DNS validation is preferred over email validation -- it auto-renews.
- Route 53 alias records are free (no per-query charge for alias to AWS resources).
- Domain registration takes up to 3 days but usually completes in minutes.

**Code Snippets:**

```hcl
# terraform/main.tf - Optional DNS & Domain resources
# Only add these if you want a custom domain

# ACM Certificate (must be in us-east-1 for CloudFront)
resource "aws_acm_certificate" "website" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  subject_alternative_names = [var.domain_name]

  tags = {
    Project     = "FitCloud"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "website" {
  name = var.domain_name

  tags = {
    Project     = "FitCloud"
    Environment = var.environment
  }
}

# DNS Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.website.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Certificate Validation
resource "aws_acm_certificate_validation" "website" {
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Alias Record pointing to CloudFront
resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.website.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Then update CloudFront distribution to include:
# aliases = [var.domain_name, "www.${var.domain_name}"]
# viewer_certificate {
#   acm_certificate_arn = aws_acm_certificate_validation.website.certificate_arn
#   ssl_support_method  = "sni-only"
# }
```

```bash
# Verify ACM certificate status
aws acm list-certificates --region us-east-1

# Check Route 53 hosted zone
aws route53 list-hosted-zones

# Test DNS resolution
nslookup yourdomain.com
```

**Study Questions:**

- Why must ACM certificates for CloudFront be in us-east-1?
- What is the difference between DNS and email validation for ACM?
- What is a Route 53 alias record and why is it free?
- What is SNI (Server Name Indication) and why use `sni-only`?

**Resources:**

- [Route 53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
- [ACM User Guide](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
- [Terraform aws_acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)
- [Terraform aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)

---

#### Module 1 Deployment Workflow

```bash
cd terraform

# 1. Format code
terraform fmt -recursive

# 2. Validate syntax
terraform validate

# 3. Preview what will be created
terraform plan

# 4. Apply (creates real AWS resources)
terraform apply

# 5. Note the cloudfront_domain_name output

# 6. Upload a test index.html
aws s3 cp test-index.html s3://fitcloud-website-dev/index.html

# 7. Visit https://<cloudfront-domain>.cloudfront.net
```

#### Module 1 Verification Checklist

- [ ] S3 bucket exists with Block Public Access = all ON
- [ ] Bucket versioning is enabled
- [ ] CloudFront distribution is deployed and status = "Deployed"
- [ ] OAC is configured (not legacy OAI)
- [ ] Bucket policy only allows CloudFront via `AWS:SourceArn` condition
- [ ] Visiting the CloudFront URL shows your `index.html`
- [ ] Visiting the S3 URL directly returns Access Denied
- [ ] `terraform plan` shows no pending changes (everything is in sync)

#### AWS Cloud Practitioner Exam Topics Covered

| Exam Domain    | Topic from this module                                         |
| -------------- | -------------------------------------------------------------- |
| Cloud Concepts | Serverless hosting, global infrastructure                      |
| Security       | Least privilege (bucket policy), encryption in transit (HTTPS) |
| Technology     | S3 storage classes, CloudFront CDN, edge locations             |
| Billing        | Free tier limits, Price Classes, cost of cache invalidation    |

#### Common Mistakes to Avoid

1. **Enabling S3 static website hosting** - Don't. It requires public access. Use CloudFront + OAC instead.
2. **Using OAI instead of OAC** - OAI is legacy. AWS recommends OAC.
3. **Forgetting `custom_error_response`** - Your React SPA routes will return 403/404 without this.
4. **Creating ACM cert outside `us-east-1`** - CloudFront only accepts certs from N. Virginia.
5. **Not adding `depends_on` for bucket policy** - The public access block must be created before the policy.
6. **Using `PriceClass_All`** - Costs more; `PriceClass_100` is fine for learning.
7. **Missing S3 resource declarations** - The CloudFront distribution references the S3 bucket; declare the bucket first.
8. **Using `bucket_domain_name` instead of `bucket_regional_domain_name`** - Can cause redirect issues.

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

| Month   | Budget | Actual | Notes |
| ------- | ------ | ------ | ----- |
| Month 1 | $10    | $      |       |

---

_Document last updated: 2026-02-26_
