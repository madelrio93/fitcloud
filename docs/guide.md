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
   - Go to AWS Console → Click your account name (top-right) → Security credentials
   - Or navigate directly to https://console.aws.amazon.comIAMv2#/security_credentials
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

---

#### Understanding IAM: Users, Groups, Roles & Policies

IAM (Identity and Access Management) is how you control **who** can access **what** in your AWS account. There are four core concepts you need to understand:

**IAM Users:**

- Represents a **single person** or application
- Has permanent credentials (access key + secret key, or console password)
- Best practice: One user per person; use IAM roles for applications
- Example: Your personal admin user for daily work

**IAM Groups:**

- A collection of IAM users
- Used to apply the same permissions to multiple users easily
- Example: A "Developers" group that all developer accounts belong to
- Best practice: Use groups to manage permissions at scale

**IAM Roles:**

- A set of temporary permissions that can be assumed by anyone who needs them
- No permanent credentials -- you "assume" a role to get temporary credentials
- Used for: Cross-account access, EC2/Lambda service access, federated users
- Example: A "LambdaExecutionRole" that your Lambda functions assume to access DynamoDB

**IAM Policies:**

- JSON documents that define **what actions are allowed or denied**
- Can be attached to: Users, Groups, or Roles
- Two types:
  - **Managed policies**: Reusable, created by AWS (e.g., `AdministratorAccess`) or you
  - **Inline policies**: Embedded directly in a single user/group/role

**The Relationship:**

```
IAM User ──belongs to──▶ IAM Group ──has attached──▶ IAM Policy(ies)
                                │
                                └──can also assume──▶ IAM Role ──has attached──▶ IAM Policy(ies)
```

**For FitCloud:**

- We create an IAM user (`admin`) for you to access the AWS Console and CLI
- We DON'T create IAM roles yet -- we'll add those when we create Lambda functions (Module 3)
- We'll use AWS managed policies like `AdministratorAccess` for learning simplicity

**Study Questions:**

- What's the difference between an IAM user and an IAM role? When would you use each?
- Why is it better to attach policies to groups rather than individual users?
- What happens if you attach both an Allow and Deny policy to the same user?
- Can an IAM role have a permanent password? Why or why not?

**Resources:**

- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM Identities](https://docs.aws.amazon.com/IAM/latest/UserGuide/id.html)

---

#### The AWS Shared Responsibility Model

The Shared Responsibility Model is one of the **most important concepts** in AWS -- and one of the most frequently tested topics on the AWS Cloud Practitioner exam. It defines what AWS manages versus what **you** manage.

**The Simple Breakdown:**

| What AWS Manages                                                 | What You Manage                                         |
| ---------------------------------------------------------------- | ------------------------------------------------------- |
| **Physical infrastructure** (data centers, servers, networking)  | **Your data** (what you store in S3, DynamoDB, RDS)     |
| **Hypervisor & hardware**                                        | **Your IAM configuration** (users, roles, policies)     |
| **Region/AZ infrastructure**                                     | **Your application code**                               |
| **Foundational services** (EC2, S3, DynamoDB core functionality) | **Operating systems** (on EC2, if you use it)           |
| **AWS global infrastructure** (Route 53, IAM, CloudFront)        | **Network configuration** (security groups, NACLs, VPC) |

**Security IN the Cloud vs. OF the Cloud:**

AWS uses two phrases that can be confusing:

- **Security OF the Cloud** (AWS's responsibility): AWS secures the infrastructure _itself_ -- the data centers, hardware, virtualization layer, and foundational services. This is always AWS's job.

- **Security IN the Cloud** (your responsibility): _You_ are responsible for how you _use_ AWS services. This includes:
  - Your data access (who can see what's in your S3 bucket?)
  - Your IAM policies (are you following least privilege?)
  - Your application code (does it have vulnerabilities?)
  - Your configuration (are your security groups too open?)

**Examples by Service (What You vs. AWS Manage):**

| Service      | AWS Manages                                                    | You Manage                                                        |
| ------------ | -------------------------------------------------------------- | ----------------------------------------------------------------- |
| **S3**       | Physical durability (11 nines), infrastructure, server patches | Bucket policies, access controls, encryption settings, versioning |
| **Cognito**  | User pool infrastructure, token signing, MFA infrastructure    | User pool configuration, app client settings, password policies   |
| **Lambda**   | Compute infrastructure, runtime execution, scaling             | Function code, environment variables, IAM execution role          |
| **DynamoDB** | Server infrastructure, data durability, automatic scaling      | Table design (partition keys), access via IAM, encryption at rest |

**The Rule of Thumb:**

> If you can configure it, you own it. If you can't configure it (like data center physical security), AWS owns it.

**Why This Matters for the Exam:**

The CCP exam _will_ ask you questions like:

- "Who is responsible for patching the operating system on an EC2 instance?" (You)
- "Who is responsible for the physical security of S3 data centers?" (AWS)
- "Who manages access to objects in an S3 bucket?" (You)

**Study Questions:**

- Is AWS responsible for data loss in S3 if you accidentally delete objects? Why or why not?
- If you deploy a Lambda function, who manages the underlying server it runs on?
- Can AWS access your S3 data without your permission? Under what circumstances?
- Who's responsible for encrypting data in DynamoDB -- AWS or you?

**Resources:**

- [AWS Shared Responsibility Model](https://aws.amazon.com/compliance/shared-responsibility-model/)
- [Security in AWS](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/security.html)

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

- CloudTrail **management events** (API calls) are free for **one trail per region** -- this trail can log to all regions
- CloudTrail **Event history** (the console view) is always free and shows the last 90 days of management events
- Additional trails, or trails that include **data events** (S3 object-level, Lambda invocation details), cost money
- Enable log file integrity validation to detect tampering

---

#### Task 0.5: Terraform State Backend Setup

**Status:** Completed

**How-to:**

1. **Create S3 bucket for Terraform state**
   - S3 → Create bucket
   - Bucket name: `fitcloud-terraform-state-<unique-id>`
   - Region: us-east-1
   - **Keep "Block all public access" turned ON** (this is correct -- the bucket should be private)
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

#### Task 0.6: Terraform Version & Provider Configuration

**Status:** Completed

**Why This Matters:**

Terraform needs to know two things before it can manage your infrastructure:

1. **Which version of Terraform** to use (the CLI tool)
2. **Which version of each provider** to use (the AWS provider in our case)

Without explicit version constraints, Terraform will use whatever version it finds, which can lead to unexpected changes when you run `terraform init` on a different machine or after an update.

**How-to:**

1. **Create a `versions.tf` file** in your `terraform/` directory:

```hcl
terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

2. **Run `terraform init`** to download the provider and initialize the backend

**What the version operators mean:**

| Operator  | Meaning                                       | Example                        |
| --------- | --------------------------------------------- | ------------------------------ |
| `~> 1.9`  | Any 1.9.x version (1.9.0, 1.9.1, 1.9.2, etc.) | "~> 1.9" = 1.9.0 to 1.99.99    |
| `~> 6.0`  | Any 6.x version (6.0.0 through 6.99.99)       | "~> 6.0" = 6.0.0 to 6.99.99    |
| `>= 1.0`  | Any version 1.0 or higher (risky!)            | Could jump to 2.0 unexpectedly |
| `= 1.9.5` | Exact version only (inflexible)               | Avoid unless necessary         |

**Best Practice:**

- Pin the **Terraform CLI version** to a minor version (e.g., `~> 1.9`)
- Pin the **provider version** to a major version (e.g., `~> 6.0`)
- This allows patch updates (bug fixes) but prevents breaking changes

**Code Snippets:**

```bash
# Check your Terraform version
terraform --version
# Expected: Terraform v1.9.x

# Check your AWS provider version (after terraform init)
cat .terraform.lock.hcl | grep aws
# Should show: version = "6.34.0" (or ~> 6.0 compatible)

# Update providers (when needed)
terraform init -upgrade

# See which providers are installed
terraform providers
```

**Lessons Learned:**

- Always version-pin your Terraform and providers for reproducibility
- Use `-upgrade` flag sparingly -- only when you intentionally want to update versions
- The `versions.tf` file is read before the backend is initialized, so it's required even when using a remote backend

**Resources:**

- [Terraform Version Constraints](https://developer.terraform.io/language/migrate/terraform-1-1)
- [Provider Versioning](https://developer.terraform.io/language/providers/version-constraints)

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

**Availability vs. Durability:**

Understanding the difference between availability and durability is important for the exam:

- **Durability** (S3): 99.999999999% (11 nines) -- means your data is _extremely unlikely_ to be lost. Even if you write 10 million objects to S3, you'd statistically lose only 1 object once every 10,000 years.

- **Availability** (S3 Standard): 99.99% -- means your data is accessible 99.99% of the time. That's about 53 minutes of downtime per year. S3 Standard has higher availability than IA or Glacier storage classes.

Think of it this way:

- **Durability** = "Will my data still be there tomorrow?" (S3's job)
- **Availability** = "Can I access my data right now?" (Your SLA)

---

#### Amazon S3 Storage Classes

S3 offers multiple **storage classes** optimized for different use cases. Understanding when to use each is a key exam topic:

**S3 Standard (Default):**

- **Use for**: Frequently accessed data, hot storage, primary data stores
- **Cost**: Highest per GB; has retrieval fees
- **Durability**: 11 nines | **Availability**: 99.99%
- **Example**: User-uploaded photos in an active fitness app

**S3 Standard-Infrequent Access (S3 Standard-IA):**

- **Use for**: Data accessed less than once a month but needs rapid access when needed
- **Cost**: Lower storage cost than Standard; per-GB retrieval fee applies
- **Durability**: 11 nines | **Availability**: 99.9%
- **Example**: Last month's workout logs (still need fast access occasionally)

**S3 One Zone-Infrequent Access (S3 One Zone-IA):**

- **Use for**: infrequently accessed data that can be recreated
- **Cost**: Even lower than Standard-IA (30-40% savings)
- **Durability**: 11 nines (but stored in ONE AZ -- if AZ is destroyed, data is lost)
- **Availability**: 99.5%
- **Example**: thumbnail images, derived data that can be regenerated
- **Exam tip**: Don't use for critical data that can't be recreated

**S3 Glacier Instant Retrieval:**

- **Use for**: Archive data that needs instant access (< 1 second) but is rarely accessed
- **Cost**: Very low storage; per-GB retrieval fee
- **Retrieval time**: Instant (milliseconds)
- **Example**: Historical annual fitness reports you might reference

**S3 Glacier Flexible Retrieval:**

- **Use for**: Long-term archives where retrieval time is flexible
- **Cost**: Lowest storage; free retrievals up to 5% of bucket per month
- **Retrieval times**:
  - Expedited: 1-5 minutes
  - Standard: 3-5 hours
  - Bulk: 5-12 hours
- **Example**: Tax documents, multi-year health data archives

**S3 Glacier Deep Archive:**

- **Use for**: Longest-term storage (7+ years), regulatory compliance
- **Cost**: Lowest of all classes
- **Retrieval times**:
  - Standard: 12 hours
  - Bulk: 48 hours
- **Example**: Legal records, compliance archives

**S3 Intelligent-Tiering:**

- **Use for**: Unknown or unpredictable access patterns
- **How it works**: Automatically moves objects between tiers based on access frequency
- **Cost**: Small monthly monitoring fee; no retrieval fees
- **Durability**: 11 nines | **Availability**: 99.9%
- **Example**: User-generated content where some workouts get viewed often, others rarely

**Choosing a Storage Class (Exam Tips):**

| If data access is...            | Use...                        |
| ------------------------------- | ----------------------------- |
| Frequent/hot                    | S3 Standard                   |
| Occasional (monthly)            | S3 Standard-IA                |
| Rare, can recreate if lost      | S3 One Zone-IA                |
| Archive, need instant retrieval | S3 Glacier Instant Retrieval  |
| Archive, flexible retrieval OK  | S3 Glacier Flexible Retrieval |
| Very long-term, compliance      | S3 Glacier Deep Archive       |
| Unpredictable                   | S3 Intelligent-Tiering        |

**For FitCloud:** We'll use S3 Standard for our website assets (hot storage, needs fast access). For a production fitness app, you might move old workout logs to Standard-IA after 30 days using S3 Lifecycle policies.

**Study Questions:**

- What's the main difference between S3 Standard-IA and S3 One Zone-IA?
- If you need to retrieve archived workout data within 1 hour, which storage class should you use?
- Can you lose data in S3 One Zone-IA? What's the risk?
- How does S3 Intelligent-Tiering decide when to move objects?

**Resources:**

- [S3 Storage Classes](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html)
- [S3 Pricing](https://aws.amazon.com/s3/pricing/)

**Amazon CloudFront (CDN):**

- **Distribution** - A CloudFront configuration that tells AWS which origin to pull content from and how to serve it.
- **Origin** - Where CloudFront fetches the original content (your S3 bucket).
- **Edge Location** - A data center close to end users where content gets cached. Hundreds worldwide.
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

---

#### Understanding AWS Global Infrastructure: Regions, Availability Zones & Edge Locations

This is a **core concept** for the Cloud Practitioner exam. AWS infrastructure is organized in three layers:

**AWS Regions:**

- A **Region** is a physical geographic location around the world where AWS has multiple data centers (Availability Zones)
- Examples: `us-east-1` (N. Virginia), `eu-west-1` (Ireland), `ap-southeast-1` (Singapore)
- Each Region is **isolated** -- resources in one Region don't automatically replicate to another
- **You choose which Region** when creating most resources
- Some services are **global** (IAM, Route 53, CloudFront) and don't require Region selection

**Availability Zones (AZs):**

- An **Availability Zone** is one or more discrete data centers within a Region, with independent power, networking, and cooling
- Each Region has multiple AZs (typically 3, sometimes more)
- AZs are connected with low-latency networking -- they're close enough to work together but far enough apart to survive a local disaster
- Example: `us-east-1a`, `us-east-1b`, `us-east-1c` are three AZs in the us-east-1 Region

**Why This Matters for High Availability:**

```
Region: us-east-1
├── AZ: us-east-1a  (data center in Virginia)
├── AZ: us-east-1b  (different data center in Virginia)
└── AZ: us-east-1c  (third data center in Virginia)
```

- If one AZ fails (power outage, network issue), your application can fail over to another
- For **high availability**, you deploy across multiple AZs
- For **disaster recovery**, you might deploy across multiple Regions

**Edge Locations:**

- **Edge Locations** are smaller data centers distributed globally, closer to users than Regions
- Used by **CloudFront** (CDN) to cache content near users
- Also used by **Route 53** for DNS routing
- There are **hundreds** of edge locations worldwide
- Edge locations don't run your EC2 instances or store your DynamoDB data -- they're for content delivery and low-latency routing

**The Hierarchy:**

```
AWS Global Infrastructure
├── Regions (15+ worldwide)
│   ├── Availability Zones (3-6 per Region)
│   │   └── Data Centers (1 or more per AZ)
│   └── Regional Services (EC2, Lambda, DynamoDB)
│
└── Edge Locations (hundreds worldwide)
    ├── CloudFront caching
    └── Route 53 DNS
```

**FitCloud's Infrastructure Location:**

| Resource   | Scope    | Location                    |
| ---------- | -------- | --------------------------- |
| S3 bucket  | Regional | `us-east-1` (we chose this) |
| DynamoDB   | Regional | `us-east-1` (future module) |
| Lambda     | Regional | `us-east-1` (future module) |
| CloudFront | Global   | Edge locations worldwide    |
| IAM        | Global   | Global (no Region needed)   |
| Cognito    | Regional | `us-east-1`                 |
| Route 53   | Global   | Global DNS                  |

**Key Exam Points:**

- Resources in one Region **do not** automatically replicate to another
- To achieve high availability, deploy across **multiple AZs** in the same Region
- Edge locations are for **content delivery** (CloudFront), not compute/storage
- IAM and CloudFront are **global services** -- they don't have a Region

**Study Questions:**

- If you deploy your application in two AZs and one AZ fails, what happens to your users?
- Can you access DynamoDB data from an edge location? Why or why not?
- What's the difference between deploying in `us-east-1` vs `eu-west-1`?
- Why does CloudFront use edge locations instead of just serving from the nearest Region?

**Resources:**

- [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
- [Regions and Availability Zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html)

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

    # Note: forwarded_values is the legacy approach. For production, consider using
    # aws_cloudfront_cache_policy and aws_cloudfront_origin_request_policy for
    # more control over caching behavior. The forwarded_values block still works
    # and is used here for simplicity.

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

**Status:** In Progress
**AWS Domain:** Cognito, IAM | Estimated: 3-4 hours | Priority: High
**Free Tier:** 50,000 MAU (Monthly Active Users) per month

---

#### Key Concepts to Understand

**What is Amazon Cognito?**
Amazon Cognito is AWS's fully managed identity and access management service. It handles user registration, authentication, and authorization for your applications. Think of it as "Auth0 or Firebase, but from AWS."

Cognito has two main components:

**User Pools:**

- A user directory that lets users sign up and sign in to your application
- Handles all aspects of user management: registration, sign-in, password reset, MFA, email/phone verification
- Issues JSON Web Tokens (JWTs) that your API can validate
- Free for first 50,000 MAU per month

**Identity Pools (Cognito Federated Identities):**

- Lets you grant temporary AWS credentials to access AWS services
- Useful when your frontend needs direct access to AWS services (like uploading directly to S3)
- Not needed for most web apps -- User Pools + API Gateway is usually sufficient

---

**Cognito vs. IAM: When to Use Which?**

A common point of confusion is: "When do I use Cognito vs. IAM?" Both are about identity and access, but they serve different purposes:

|                     | **IAM**                                                 | **Cognito**                               |
| ------------------- | ------------------------------------------------------- | ----------------------------------------- |
| **Manages**         | Access to **AWS services and resources**                | Access to **your application**            |
| **Users represent** | Employees, developers, systems that need AWS access     | End users of your application (customers) |
| **Credentials**     | Long-term access keys / console passwords               | Temporary JWT tokens (short-lived)        |
| **Use case**        | "Can this developer deploy to production?"              | "Can this user view their workout data?"  |
| **Examples**        | Admin user, Lambda execution role, EC2 instance profile | App sign-up/sign-in, social login         |

**The Key Distinction:**

- **IAM** answers: _"Who can access MY AWS ACCOUNT?"_ (developers, operators, IT)
- **Cognito** answers: _"Who can access MY APPLICATION?"_ (your app's users)

**For FitCloud:**

- We use **IAM** to give our Terraform CLI access to our AWS account
- We use **Cognito** to let end users sign up and sign in to our fitness app
- Our Lambda functions use **IAM roles** to access DynamoDB, but the _permission to call_ those Lambda functions is controlled by **Cognito** via API Gateway authorization

This is the Shared Responsibility Model in action: AWS manages Cognito's infrastructure, but _you_ manage who can sign up and sign in to your app.

**Study Questions:**

- If you wanted to give a developer access to view CloudWatch logs, would you use IAM or Cognito?
- Can Cognito users access the AWS Console directly? Why or why not?
- What's the security difference between an IAM access key (permanent) and a Cognito access token (expires in 1 hour)?

**For FitCloud:** We only need a **User Pool**. The JWT tokens will be validated by API Gateway, and our Lambda functions will use the `userId` from the token to scope data to the authenticated user. We do NOT need an Identity Pool.

**OAuth 2.0 Grants:**

- **Authorization Code Grant** (recommended): Client gets an authorization code first, then exchanges it for tokens. Most secure -- tokens never exposed to the browser.
- **Implicit Grant** (legacy): Tokens returned directly in URL. Less secure -- not recommended for production.
- **Client Credentials Grant**: For machine-to-machine communication, not user authentication.

We'll use **Authorization Code Grant** with PKCE (Proof Key for Code Exchange) for security.

**JWT Tokens (JSON Web Tokens):**
When a user signs in, Cognito returns three tokens:

1. **ID Token**: Contains user attributes (email, name, sub). Use for getting user info.
2. **Access Token**: Contains scopes and expiration. Use for API authorization.
3. **Refresh Token**: Long-lived token used to get new ID and access tokens without re-authenticating.

**How Cognito Connects to API Gateway (Preview for Module 3):**

```
User (React App)
    │
    ▼ (1. Sign in via Hosted UI)
Cognito User Pool
    │
    ▼ (2. Returns JWT tokens)
User's Browser (stores tokens)
    │
    ▼ (3. API request with Bearer token)
API Gateway
    │
    ▼ (4. Validates JWT with Cognito)
Lambda Function (receives userId in context)
    │
    ▼ (5. Query DynamoDB with userId)
DynamoDB (user's private data)
```

---

#### Architecture Diagram (FitCloud)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FITCLOUD ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐      ┌──────────────┐      ┌──────────────────┐    │
│  │  React   │──────▶│  API Gateway │──────▶│    Lambda        │    │
│  │  Frontend│      │  (Protected) │      │  (Workouts API)  │    │
│  └──────────┘      └──────────────┘      └────────┬─────────┘    │
│       │                     │                      │               │
│       │ JWT Bearer         │                      ▼               │
│       │ Token             │              ┌──────────────────┐       │
│       │                   │              │    DynamoDB      │       │
│       ▼                   │              │  (userId-based)  │       │
│  ┌──────────────┐        │              └──────────────────┘       │
│  │  Cognito     │◀───────┘                                           │
│  │  User Pool   │         Cognito validates JWT, API Gateway         │
│  │  (Auth)      │         authorizes request before Lambda runs      │
│  └──────────────┘                                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Key insight:** The frontend NEVER talks directly to DynamoDB. All requests go through API Gateway, which validates the JWT token from Cognito before allowing the request through.

---

#### Task 2.1: Cognito User Pool Setup

**Status:** Pending

**What you'll create:**

1. A Cognito User Pool with email-based sign-in
2. Password policy configuration
3. Email verification settings
4. Custom domain for the Hosted UI

**Terraform resources used:**

| Resource                       | Purpose                     |
| ------------------------------ | --------------------------- |
| `aws_cognito_user_pool`        | The user directory          |
| `aws_cognito_user_pool_domain` | Custom domain for Hosted UI |

**How-to:**

1. **Create Cognito User Pool**
   - Declare an `aws_cognito_user_pool` resource
   - Set `name` with environment suffix (e.g., `fitcloud-dev`)
   - Configure `alias_attributes` to allow sign-in with email
   - Set password policy (minimum 8 chars, require uppercase, lowercase, numbers, symbols)
   - Enable auto-verification for email
   - Configure email verification message

2. **Configure Password Policy**
   - `minimum_length`: 8 characters
   - `require_lowercase`: true
   - `require_uppercase`: true
   - `require_numbers`: true
   - `require_symbols`: true

3. **Set Up Email Verification**
   - `auto_verified_attributes`: ["email"]
   - Cognito will send a verification code to the user's email
   - For development, Cognito's default email sender is fine
   - For production, you'd configure SES (Simple Email Service)

4. **Create User Pool Domain**
   - Declare an `aws_cognito_user_pool_domain` resource
   - Set a unique `domain` prefix (e.g., `fitcloud-auth-dev`)
   - This creates the hosted UI URL: `https://fitcloud-auth-dev.auth.us-east-1.amazoncognito.com`

**Lessons Learned:**

- Cognito User Pools are free for up to 50,000 MAU -- more than enough for learning.
- Email is the easiest sign-in method. Phone numbers require AWS SNS costs.
- The domain prefix must be globally unique across all AWS accounts.
- Once created, you cannot change the sign-in method (email vs phone vs username). If you need to change, you must recreate the pool.
- The "sub" (subject) attribute is a unique user ID -- use this as the partition key in DynamoDB.

**Code Snippets:**

```hcl
# terraform/main.tf - Add after Module 1 resources

# --- Cognito User Pool ---
resource "aws_cognito_user_pool" "main" {
  name = "fitcloud-${var.environment}"

  # Allow users to sign in with email
  alias_attributes = ["email"]

  # Password policy - strong security
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
  }

  # Auto-verify email addresses
  auto_verified_attributes = ["email"]

  # Email configuration (use Cognito's default for dev)
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Schema attributes - what user data to store
  schema {
    name                = "email"
    attribute_data_type = "String"
    required           = true
    mutable            = false  # Cannot be changed after creation
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required           = false
    mutable            = true
  }

  # User invitation message (for admin-created users)
  user_invitation_message {
    subject   = "Your FitCloud login invite"
    html_body = "<p>Your temporary password is {####}</p>"
  }

  # Email subject for verification
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  tags = {
    Project     = "FitCloud"
    Environment = var.environment
  }
}

# --- Cognito User Pool Domain (for Hosted UI) ---
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "fitcloud-auth-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}
```

```bash
# Verify Cognito User Pool was created
aws cognito-idp list-user-pools --max-results 20

# Get User Pool details
aws cognito-idp describe-user-pool --user-pool-id <your-pool-id>

# Get Domain status
aws cognito-idp describe-user-pool-domain --domain fitcloud-auth-dev

# Test Hosted UI URL
# https://fitcloud-auth-dev.auth.us-east-1.amazoncognito.com
# (This will fail until we create the App Client in Task 2.2)
```

**Study Questions:**

- What's the difference between a User Pool and an Identity Pool?
- Why do we use email as the sign-in attribute?
- What does the "sub" attribute represent in Cognito?
- Why is the Authorization Code Grant preferred over Implicit Grant?
- What happens if you need to change sign-in method after creating the pool?

**Resources:**

- [Cognito User Pools Documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
- [Terraform aws_cognito_user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool)
- [Cognito Pricing](https://aws.amazon.com/cognito/pricing/)

---

#### Task 2.2: App Client Configuration

**Status:** Pending

**What you'll create:**

1. An App Client for the React frontend
2. OAuth 2.0 configuration with Authorization Code Grant
3. Callback and logout URLs
4. Token settings (validity periods)

**What is an App Client?**
An App Client is a configuration within the User Pool that represents your application. Each app (web, mobile, etc.) gets its own client with its own settings. The client ID is public, but the client secret (if generated) must be kept secure.

For a **public client** (like a React SPA), we do NOT generate a client secret because it would be exposed in the browser anyway.

**Terraform resources used:**

| Resource                       | Purpose                          |
| ------------------------------ | -------------------------------- |
| `aws_cognito_user_pool_client` | Application client configuration |

**How-to:**

1. **Create App Client**
   - Declare an `aws_cognito_user_pool_client` resource
   - Link to the User Pool
   - Set a friendly name (e.g., "FitCloud Web App")
   - Set `generate_secret = false` (public client for SPA)
   - Configure OAuth 2.0 settings

2. **Configure OAuth 2.0**
   - Enable OAuth for the client: `allowed_oauth_flows_user_pool_client = true`
   - Set OAuth flows: `["code"]` (Authorization Code Grant with PKCE)
   - Set OAuth scopes: `["openid", "email", "profile"]`
     - `openid`: Required for OIDC -- returns ID token
     - `email`: Returns email in ID token
     - `profile`: Returns name/picture in ID token

3. **Set Callback and Logout URLs**
   - `callback_urls`: Where to redirect after successful auth
     - Development: `["http://localhost:5173"]`
     - Later: `["https://yourdomain.com"]`
   - `logout_urls`: Where to redirect after sign out

4. **Configure Token Validity**
   - Access token: 1 hour (3600 seconds)
   - ID token: 1 hour
   - Refresh token: 30 days
   - Enable token revocation for security

**Lessons Learned:**

- The App Client ID is public (it's in your React code), but that's okay -- the actual authentication happens securely server-side.
- Use Authorization Code Grant with PKCE for SPAs -- it's the most secure OAuth flow for browser-based apps.
- You can create multiple App Clients for different platforms (web, mobile) with different settings.
- Once created, some settings cannot be changed. If you mess up, delete and recreate the client.
- The `generate_secret = true` is only for server-side apps (confidential clients). For React SPAs, always use `false`.

**Code Snippets:**

```hcl
# terraform/main.tf - Add App Client

# --- Cognito App Client ---
resource "aws_cognito_user_pool_client" "main" {
  name = "fitcloud-web-app"

  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth 2.0 Configuration
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  # IMPORTANT: Public clients (like SPAs) should NOT generate a client secret
  # because it would be exposed in the browser. Only use for confidential clients.
  generate_secret = false

  # Callback and Logout URLs
  callback_urls = [
    "http://localhost:5173",
    "https://${var.domain != "" ? var.domain : "localhost:5173"}"
  ]

  logout_urls = [
    "http://localhost:5173",
    "https://${var.domain != "" ? var.domain : "localhost:5173"}"
  ]

  # Token Settings - specify the units explicitly for clarity
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  access_token_validity  = 1  # 1 hour
  id_token_validity     = 1  # 1 hour
  refresh_token_validity = 30 # 30 days

  # Enable token revocation for security
  enable_token_revocation = true

  # Auth flows - SRP (Secure Remote Password) is the default and recommended
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Prevent user existence errors (security best practice)
  prevent_user_existence_errors = "ENABLED"

  # Read/Write attributes
  read_attributes  = ["email", "email_verified", "name", "sub"]
  write_attributes = ["email", "name"]

  depends_on = [aws_cognito_user_pool.main]
}
```

```hcl
# terraform/variables.tf - Add domain variable

variable "domain" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}
```

```hcl
# terraform/outputs.tf - Add Cognito outputs

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = aws_cognito_user_pool.main.endpoint
}

output "cognito_hosted_ui_url" {
  description = "Cognito Hosted UI URL"
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
}
```

**Testing the Hosted UI:**

Once both Task 2.1 and 2.2 are complete, you can test the Hosted UI:

```bash
# The Hosted UI URL format:
# https://<domain>.auth.<region>.amazoncognito.com/login?
#   client_id=<client-id>&
#   response_type=code&
#   scope=openid+email+profile&
#   redirect_uri=<callback-url>

# Example (replace with your values):
# https://fitcloud-auth-dev.auth.us-east-1.amazoncognito.com/login?
#   client_id=abc123def456&
#   response_type=code&
#   scope=openid+email+profile&
#   redirect_uri=http://localhost:5173

# Visit this URL in your browser:
# 1. You'll see the Cognito Hosted Login page
# 2. Click "Sign up" to create a new account
# 3. Enter email, password, name
# 4. Check email for verification code
# 5. Enter verification code
# 6. You'll be redirected to http://localhost:5173 with an authorization code
# 7. The React app will exchange the code for tokens (handled by Amplify)
```

**Study Questions:**

- What's the difference between a public client and a confidential client?
- Why do we use Authorization Code Grant instead of Implicit Grant?
- What is PKCE (Proof Key for Code Exchange) and why does it matter?
- What OAuth scopes do we need, and why each one?
- Why is `prevent_user_existence_errors = "ENABLED"` a security best practice?

**Resources:**

- [App Client Configuration](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html)
- [OAuth 2.0 Grants](https://docs.aws.amazon.com/cognito/latest/developerguide/federation-endpoints-oauth-grants.html)
- [Terraform aws_cognito_user_pool_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client)

---

#### Task 2.3: Cognito Identity Pool (Optional)

**Status:** Not Required for FitCloud

**What is an Identity Pool?**
A Cognito Identity Pool (also called "Cognito Federated Identities") provides temporary AWS credentials to access AWS services directly from your frontend. This is different from User Pools, which only handle authentication.

**When would you need an Identity Pool?**

- You want users to upload files directly to S3 from the browser (bypassing your API)
- You want to call AWS services (like DynamoDB, Lambda) directly from the frontend with fine-grained permissions
- You need to support social login (Google, Facebook) AND want AWS service access

**For FitCloud, we do NOT need an Identity Pool because:**

1. Our API Gateway + Lambda architecture handles all data access
2. Users never need to access AWS services directly
3. JWT tokens from User Pools are sufficient for API authorization

**If you wanted to explore it later, here's the concept:**

```
┌─────────────────────────────────────────────────────────────┐
│           IDENTITY POOL (COGNITO FEDERATED IDENTITIES)      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  User signs in with:  ──┐                                    │
│  - Cognito User Pool    │                                    │
│  - Social Provider      │                                    │
│  - Custom Auth          │                                    │
│                         ▼                                    │
│                    ┌─────────────┐                           │
│                    │   Identity  │                           │
│                    │    Pool     │                           │
│                    └──────┬──────┘                           │
│                           │                                   │
│         ┌────────────────┼────────────────┐                 │
│         ▼                ▼                ▼                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Unauth     │  │ Auth IAM   │  │ Auth IAM    │         │
│  │  (Guest)    │  │   Role     │  │   Role      │         │
│  │   Role      │  │  (Users)   │  │ (Admins)    │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                   │
│         ▼                ▼                ▼                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   AWS       │  │   AWS       │  │   AWS       │         │
│  │   Services  │  │   Services  │  │   Services  │         │
│  │  (Limited)  │  │  (Full)    │  │  (Full+)    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                              │
│  Use Case: Upload to S3, call DynamoDB directly              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Terraform code (for reference only, not implementing):**

```hcl
# Optional - Only if you need direct AWS service access from frontend

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name = "fitcloud-identity-pool-${var.environment}"
  allow_unauthenticated_identities = false  # No guest access

  cognito_identity_providers {
    user_pool_id         = aws_cognito_user_pool.main.id
    client_id            = aws_cognito_user_pool_client.main.id
    provider_name        = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
}

# IAM roles for authenticated users
resource "aws_iam_role" "authenticated" {
  name = "Cognito_${aws_cognito_identity_pool.main.id}_Auth_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud": aws_cognito_identity_pool.main.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr": ["authenticated"]
        }
      }
    }]
  })
}
```

**Study Questions:**

- What's the main difference between User Pools and Identity Pools?
- Why don't we need an Identity Pool for FitCloud?
- What are the security implications of allowing unauthenticated identities?

---

#### How Cognito Connects to API Gateway (Preview for Module 3)

In Module 3, we'll secure our API Gateway endpoints using Cognito. Here's the pattern:

```hcl
# terraform/main.tf - Preview (will add in Module 3)

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "fitcloud-cognito-authorizer"
  rest_api_id           = aws_api_gateway_rest_api.main.id
  type                   = "COGNITO_USER_POOLS"
  provider_arns         = [aws_cognito_user_pool.main.arn]

  # Cache authorizer results for 5 minutes
  authorizer_result_ttl_in_seconds = 300
}

# Then on each API Gateway method, add:
# authorization = "COGNITO_USER_POOLS"
# authorizer_id = aws_api_gateway_authorizer.cognito.id
```

**The Flow:**

1. User signs in via Hosted UI → gets JWT tokens
2. User makes API request with `Authorization: Bearer <access_token>`
3. API Gateway validates the token against Cognito User Pool
4. If valid, request passes through to Lambda
5. Lambda receives `event.requestContext.authorizer.claims.sub` as the userId

---

#### Module 2 Deployment Workflow

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

# 5. Note the outputs
# - cognito_user_pool_id
# - cognito_user_pool_client_id
# - cognito_hosted_ui_url

# 6. Test the Hosted UI
# Visit: https://fitcloud-auth-dev.auth.us-east-1.amazoncognito.com
# Sign up a test user
# Verify email
# Sign in
```

---

#### Module 2 Verification Checklist

- [ ] Cognito User Pool exists and is active
- [ ] Domain is created (verify at https://us-east-1.console.aws.amazon.com/cognito/home)
- [ ] App Client is created with OAuth 2.0 enabled
- [ ] OAuth Scopes include: openid, email, profile
- [ ] Callback URL matches your frontend (http://localhost:5173)
- [ ] Hosted UI loads and displays login page
- [ ] User can sign up with email
- [ ] Verification email is received
- [ ] User can confirm email and sign in
- [ ] After sign-in, redirected to callback URL with code
- [ ] terraform plan shows no pending changes

---

#### AWS Cloud Practitioner Exam Topics Covered

| Exam Domain | Topic from this module                                         |
| ----------- | -------------------------------------------------------------- |
| Security    | IAM roles, Cognito User Pools, OAuth 2.0, JWT tokens           |
| Technology  | Cognito vs Auth0/Firebase, API Gateway authorization           |
| Billing     | Cognito free tier (50,000 MAU), no hidden costs for basic auth |

**Key Exam Points:**

- Cognito User Pools handle user authentication (sign up, sign in, MFA)
- Identity Pools handle authorization (temporary AWS credentials)
- JWT tokens contain user identity information
- API Gateway can validate Cognito tokens without Lambda
- Cognito is a fully managed service (no servers to manage)

---

#### Common Mistakes to Avoid

1. **Using the wrong sign-in method**: Can't change email → phone after creation. Recreate pool if needed.
2. **Forgetting callback URLs**: The OAuth flow won't work without matching callback URLs.
3. **Not using PKCE**: Always use Authorization Code Grant with PKCE for SPAs, not Implicit Grant.
4. **Generating client secret for SPA**: Public clients shouldn't have secrets (exposed in browser).
5. **Ignoring token expiration**: Access tokens expire in 1 hour. Refresh tokens handle renewal.
6. **Missing OAuth scopes**: Without "openid" scope, you won't get an ID token.
7. **Not enabling token revocation**: Allows logout from all devices.
8. **Using Identity Pool when not needed**: Most web apps don't need it. User Pool + API Gateway is sufficient.

---

### Module 3: Workout Tracking (DynamoDB + Lambda + API Gateway)

**Status:** In Progress
**AWS Domain:** DynamoDB, Lambda, API Gateway, IAM | Estimated: 6-8 hours | Priority: High
**Free Tier:** DynamoDB = 25 GB storage (on-demand) | Lambda = 1M requests/month | API Gateway = 1M requests/month

---

#### Key Concepts to Understand

**What is Amazon DynamoDB?**
DynamoDB is AWS's fully managed NoSQL database service. It delivers single-digit millisecond performance at any scale. Think of it as "a key-value store with document support" -- you can store JSON documents, access them by key, and scale infinitely without managing servers.

DynamoDB has two data models:

- **Key-Value**: Primary key is either just a Partition Key (PK) or Partition Key + Sort Key (SK)
- **Document**: Values can be JSON objects, arrays, strings, numbers, booleans, and null

**Partition Key (PK) and Sort Key (SK):**

Every DynamoDB table has a primary key. Two options:

1. **Partition Key Only**: Just one key. All items with the same PK are stored together.
2. **Partition Key + Sort Key (Composite)**: Two keys. Items with the same PK are stored together, sorted by SK.

The combination of PK + SK must be unique for each item.

**Single-Table Design:**

In DynamoDB, the recommended pattern is **single-table design**:

- One table stores multiple entity types (users, workouts, exercises, sets)
- Different entity types use different key patterns
- Related data is denormalized (stored together)
- Uses **GSIs (Global Secondary Indexes)** for alternate access patterns
- This is different from relational database normalization!

**On-Demand vs Provisioned Capacity:**

| Mode            | Pricing                                                               | Use Case                                             |
| --------------- | --------------------------------------------------------------------- | ---------------------------------------------------- |
| **On-Demand**   | Pay per request ($0.25 per million WRU, $0.25 per million RRU)        | Unpredictable workloads, development, low traffic    |
| **Provisioned** | You reserve RCUs/WCUs per second ($0.00013 per RCU, $0.00065 per WCU) | Predictable high traffic, cost optimization at scale |

For learning: **Always use on-demand**. It fits the free tier perfectly and you won't accidentally spend money.

**Consistency Models:**

- **Eventual Consistency** (default): Reads may return stale data briefly. Cheaper (half the RCU). Most apps are fine with this.
- **Strong Consistency**: Reads always return the latest data. Costs double RCU. Use when data integrity is critical.

**RCUs and WCUs:**

- **RCU (Read Capacity Unit)**: 1 strongly consistent read/sec of up to 4KB, OR 2 eventually consistent reads/sec of up to 4KB
- **WCU (Write Capacity Unit)**: 1 write/sec of up to 1KB

For the exam: Remember that on-demand mode abstracts this away -- you just pay per request.

**Global Secondary Indexes (GSIs):**

- An GSI lets you query data using a different key pattern than the primary key
- Think of it as a "secondary index" like in relational databases
- Can have different partition key than the main table
- Read/write capacity can be separate from the main table
- Use for: alternate access patterns, denormalization, different query needs

---

#### DynamoDB Access Patterns for FitCloud

For a fitness tracker, here are our access patterns. We're using **single-table design** with composite primary key:

**Key Schema:**

| Entity Type           | Partition Key (PK) | Sort Key (SK)                              |
| --------------------- | ------------------ | ------------------------------------------ |
| User metadata         | `USER#<userId>`    | `PROFILE`                                  |
| Workout               | `USER#<userId>`    | `WORKOUT#<workoutId>#<timestamp>`          |
| Exercise (in workout) | `USER#<userId>`    | `EXERCISE#<workoutId>#<exerciseId>`        |
| Set (of exercise)     | `USER#<userId>`    | `SET#<workoutId>#<exerciseId>#<setNumber>` |

**Access Pattern Table:**

| #   | Access Pattern              | Query Type | Key Expression                                                    | Notes                     |
| --- | --------------------------- | ---------- | ----------------------------------------------------------------- | ------------------------- |
| 1   | Get all workouts for a user | Query      | `PK = USER#<userId>` AND `SK begins_with "WORKOUT#"`              | Paginated, sorted by date |
| 2   | Get a specific workout      | GetItem    | `PK = USER#<userId>`, `SK = WORKOUT#<id>#<timestamp>`             | Single item               |
| 3   | Get exercises for a workout | Query      | `PK = USER#<userId>` AND `SK begins_with "WORKOUT#<id>#EXERCISE"` | All exercises in workout  |
| 4   | Get user's profile          | GetItem    | `PK = USER#<userId>`, `SK = "PROFILE"`                            | User metadata             |
| 5   | Update workout status       | UpdateItem | `PK = USER#<userId>`, `SK = WORKOUT#<id>#<timestamp>`             | Change status field       |

**Entity Data Models:**

```typescript
// Workout Entity
{
  PK: "USER#abc123",
  SK: "WORKOUT#workout-001#1700000000",
  entityType: "WORKOUT",
  workoutId: "workout-001",
  name: "Morning Strength",
  type: "STRENGTH",
  date: "2025-01-01",
  duration: 3600,  // seconds
  notes: "Felt strong today",
  status: "COMPLETED",
  createdAt: "2025-01-01T08:00:00Z",
  updatedAt: "2025-01-01T09:00:00Z"
}

// Exercise Entity
{
  PK: "USER#abc123",
  SK: "EXERCISE#workout-001#ex-001",
  entityType: "EXERCISE",
  workoutId: "workout-001",
  exerciseId: "ex-001",
  name: "Bench Press",
  order: 1,
  notes: "Warm up set"
}

// Set Entity
{
  PK: "USER#abc123",
  SK: "SET#workout-001#ex-001#1",
  entityType: "SET",
  workoutId: "workout-001",
  exerciseId: "ex-001",
  setNumber: 1,
  reps: 10,
  weight: 135,  // lbs
  weightUnit: "lbs",
  completed: true
}
```

**Why This Design?**

1. **User isolation**: Every query starts with `USER#<userId>` -- users can ONLY access their own data
2. **Single-table**: All entities in one table means one IAM policy, one connection pool, simpler application
3. **Hierarchical SK**: `WORKOUT#<id>#<timestamp>` groups workout with its exercises/sets
4. **Sort key ordering**: Within a user's workouts, they're naturally sorted by timestamp

---

#### Task 3.1: DynamoDB Table Setup

**Status:** Pending

**What you'll create:**

1. A DynamoDB table with composite primary key (userId + entityType#timestamp)
2. On-demand billing mode (pay-per-request)
3. Server-side encryption (enabled by default)
4. Tags for cost tracking

**Terraform resources used:**

| Resource             | Purpose                    |
| -------------------- | -------------------------- |
| `aws_dynamodb_table` | Creates the DynamoDB table |

**How-to:**

1. **Create the DynamoDB table**
   - Create a new module: `terraform/modules/dynamodb/`
   - Declare `aws_dynamodb_table` resource
   - Set `name = "fitcloud-workouts-${var.environment}"`
   - Set `billing_mode = "PAY_PER_REQUEST"` (on-demand)
   - Define `hash_key` = `userId` (String)
   - Define `range_key` = `sortKey` (String)

2. **Configure the key schema**

   ```hcl
   hash_key  = "userId"
   range_key = "sortKey"

   attribute {
     name = "userId"
     type = "S"  # String
   }

   attribute {
     name = "sortKey"
     type = "S"  # String
   }
   ```

3. **Add tags for cost tracking**

   ```hcl
   tags = {
     Project     = var.project_name
     Environment = var.environment
   }
   ```

4. **Export the table name and ARN** for use by Lambda and IAM policies

**Lessons Learned:**

- On-demand billing is perfect for learning and development -- no capacity planning needed
- DynamoDB server-side encryption is enabled by default using AWS-managed keys
- The table name is used in Lambda IAM policies to grant access
- Single-table design means one table for all entity types

**Code Snippets:**

```hcl
# terraform/modules/dynamodb/main.tf

resource "aws_dynamodb_table" "workouts" {
  name           = "${var.project_name}-workouts-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  range_key      = "sortKey"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "sortKey"
    type = "S"
  }

  # Enable TTL for automatic cleanup (optional, for future use)
  ttl {
    attribute_name = "expiresAt"
    enabled        = false  # Enable when needed
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
```

```hcl
# terraform/modules/dynamodb/variables.tf

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}
```

```hcl
# terraform/modules/dynamodb/outputs.tf

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.workouts.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.workouts.arn
}
```

```bash
# Verify table creation
aws dynamodb list-tables

# Describe table
aws dynamodb describe-table --table-name fitcloud-workouts-dev

# Check billing mode
aws dynamodb describe-table --table-name fitcloud-workouts-dev | jq '.Table.BillingModeSummary'
```

**Study Questions:**

- Why is single-table design recommended for DynamoDB?
- What's the difference between partition key and sort key?
- When would you use a GSI (Global Secondary Index)?
- Why use on-demand billing for development?
- How does DynamoDB ensure data isolation between users?

**Resources:**

- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
- [DynamoDB Core Components](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html)
- [Single-Table Design](https://aws.amazon.com/blogs/database/single-table-vs-multi-table-design-in-aws-dynamodb-and-why-it-matters/)
- [Terraform aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)

---

#### Key Concepts: AWS Lambda

**What is AWS Lambda?**
Lambda is AWS's serverless compute service. You upload your code, and AWS runs it in response to events -- no servers to manage, no capacity to provision, pay only for what you use.

**How Lambda Works:**

1. **Upload code**: Package your function (runtime + code + dependencies) as a ZIP or container image
2. **Configure triggers**: Set up what invokes the function (API Gateway, S3, DynamoDB, CloudWatch, etc.)
3. **AWS manages infrastructure**: Servers, scaling, patching, high availability
4. **Pay per invocation**: You're charged for the number of requests + the duration of each request

**Lambda Execution Model:**

- **Cold Start**: First invocation after inactivity may take longer (200-500ms) while AWS provisions a runtime
- **Warm Container**: Subsequent invocations reuse the same container (typically <10ms)
- **Handler**: Your entry point function. Named `handler` by convention but can be anything you specify
- **Context**: AWS passes a context object with info about the invocation (request ID, memory limit, etc.)

**Lambda Configuration:**

| Setting               | Range                    | Recommendation for Learning                          |
| --------------------- | ------------------------ | ---------------------------------------------------- |
| Memory                | 128 MB - 10 GB           | Start with 256-512 MB. More memory = more CPU + cost |
| Timeout               | 1 - 900 seconds (15 min) | Start with 30 seconds for API handlers               |
| Ephemeral Disk (/tmp) | 512 KB - 10 GB           | Only if you need file caching                        |
| Concurrency           | 0 - (account limit)      | Default 1000 concurrent, can reserve                 |

**Key Insight**: Memory also determines CPU allocation. At 1,769 MB, you get the equivalent of 1 vCPU. Above that, you get 2 vCPUs (Lambda scales CPU proportionally with memory).

**Lambda Layers:**

- Share common code/dependencies across functions
- Upload once, reference in multiple functions
- Use for: shared utilities, SDKs, logging libraries

**Lambda Pricing (Free Tier):**

- **Requests**: First 1,000,000 requests/month are free
- **Duration**: First 400,000 GB-seconds/month are free
- **Calculation**: (Memory in GB) × (Execution time in seconds) × (Requests)

For learning: You will almost certainly stay within the free tier.

**Runtimes:**

Lambda supports many runtimes:

- Node.js 20, 18 (LTS)
- Python 3.11, 3.10, 3.9
- Java 17, 11, 8
- .NET 8, 7, 6
- Go
- Ruby 3.2

We use **Node.js 20** for FitCloud.

**Lambda + API Gateway Integration:**

When Lambda is integrated with API Gateway, Lambda receives the HTTP request as the `event` parameter, and returns an HTTP response. This is called **Lambda Proxy Integration**.

```typescript
// event structure from API Gateway
{
  httpMethod: "GET",
  path: "/workouts",
  headers: { ... },
  queryStringParameters: { ... },
  body: "...",  // POST body as string
  requestContext: {
    authorizer: {
      claims: {
        sub: "user-id-123"  // From Cognito JWT!
      }
    }
  }
}
```

**The Lambda Handler Pattern:**

```typescript
export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  // Your code here
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Success" }),
  };
};
```

---

#### Task 3.2: Lambda Functions & Backend Scaffolding

**Status:** Pending

**What you'll create:**

1. Backend project structure (`package.json`, `tsconfig.json`)
2. Lambda handler functions for CRUD operations
3. Shared utilities (response helper, validation, DynamoDB client)
4. Terraform for Lambda functions

**Directory Structure:**

```
backend/
├── package.json
├── tsconfig.json
├── jest.config.js
├── src/
│   ├── functions/
│   │   ├── workouts/
│   │   │   ├── create-workout.ts
│   │   │   ├── list-workouts.ts
│   │   │   ├── get-workout.ts
│   │   │   ├── update-workout.ts
│   │   │   └── delete-workout.ts
│   │   └── types/
│   │       └── workout.ts
│   └── shared/
│       ├── response.ts
│       ├── validation.ts
│       ├── dynamo.ts
│       └── types.ts
└── tests/
```

**How-to: 1. Create package.json**

```json
{
  "name": "@fitcloud/backend",
  "version": "1.0.0",
  "description": "FitCloud Lambda functions",
  "main": "dist/functions/workouts/create-workout.js",
  "scripts": {
    "build": "tsc",
    "test": "jest",
    "lint": "eslint src --ext .ts",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.500.0",
    "@aws-sdk/lib-dynamodb": "^3.500.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/aws-lambda": "^8.10.0",
    "@types/jest": "^29.0.0",
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "jest": "^29.0.0",
    "ts-jest": "^29.0.0",
    "esbuild": "^0.20.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "eslint": "^8.0.0"
  }
}
```

**How-to: 2. Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

**How-to: 3. Shared Utilities**

```typescript
// src/shared/response.ts
import type { APIGatewayProxyResult } from "aws-lambda";

export const response = (
  statusCode: number,
  body: unknown,
  headers?: Record<string, string>,
): APIGatewayProxyResult => ({
  statusCode,
  headers: {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
    ...headers,
  },
  body: JSON.stringify(body),
});
```

```typescript
// src/shared/validation.ts
import { z, ZodError } from "zod";

export const validateInput = <T>(data: unknown, schema: z.ZodSchema<T>): T => {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof ZodError) {
      throw new ValidationError("Invalid input", error.errors);
    }
    throw error;
  }
};

export class ValidationError extends Error {
  constructor(
    message: string,
    public details: unknown,
  ) {
    super(message);
    this.name = "ValidationError";
  }
}
```

```typescript
// src/shared/dynamo.ts
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  GetCommand,
  PutCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

export const docClient = DynamoDBDocumentClient.from(client, {
  marshallOptions: {
    removeUndefinedValues: true,
  },
});

export const TableName = process.env.WORKOUTS_TABLE || "fitcloud-workouts-dev";

// Helper to build sort key patterns
export const buildSortKey = (
  entityType: string,
  id: string,
  subId?: string,
): string => {
  if (subId) {
    return `${entityType}#${id}#${subId}`;
  }
  return `${entityType}#${id}`;
};

export const parseSortKey = (
  sortKey: string,
): { entityType: string; id: string; subId?: string } => {
  const parts = sortKey.split("#");
  return {
    entityType: parts[0],
    id: parts[1],
    subId: parts[2],
  };
};
```

**How-to: 4. Lambda Handler: Create Workout**

```typescript
// src/functions/workouts/create-workout.ts
import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { z } from "zod";
import { response } from "../../shared/response";
import { validateInput, ValidationError } from "../../shared/validation";
import { docClient, TableName, buildSortKey } from "../../shared/dynamo";
import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { randomUUID } from "crypto";

const workoutSchema = z.object({
  name: z.string().min(1).max(100),
  type: z.enum(["STRENGTH", "CARDIO", "FLEXIBILITY", "HIIT", "OTHER"]),
  date: z.string(), // ISO date string
  duration: z.number().min(0), // seconds
  notes: z.string().max(1000).optional(),
  exercises: z
    .array(
      z.object({
        name: z.string().min(1),
        order: z.number().int().positive(),
        sets: z
          .array(
            z.object({
              reps: z.number().int().min(0).optional(),
              weight: z.number().min(0).optional(),
              weightUnit: z.enum(["lbs", "kg"]).optional(),
              duration: z.number().min(0).optional(), // seconds
              completed: z.boolean().optional(),
            }),
          )
          .optional(),
      }),
    )
    .optional(),
});

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  try {
    // Extract userId from Cognito JWT (via API Gateway authorizer)
    const userId = event.requestContext.authorizer?.claims?.sub;
    if (!userId) {
      return response(401, { error: "Unauthorized: No user ID" });
    }

    // Parse and validate request body
    const body = JSON.parse(event.body || "{}");
    const validated = validateInput(body, workoutSchema);

    // Generate IDs and timestamps
    const workoutId = randomUUID();
    const now = new Date().toISOString();
    const timestamp = Math.floor(Date.now() / 1000);

    // Build the workout item
    const workoutItem = {
      userId: `USER#${userId}`,
      sortKey: buildSortKey("WORKOUT", workoutId, timestamp.toString()),
      entityType: "WORKOUT",
      workoutId,
      userIdOnly: userId, // For GSI if needed
      ...validated,
      status: "IN_PROGRESS",
      createdAt: now,
      updatedAt: now,
    };

    // Save to DynamoDB
    await docClient.send(
      new PutCommand({
        TableName,
        Item: workoutItem,
      }),
    );

    return response(201, {
      workoutId,
      message: "Workout created successfully",
    });
  } catch (error) {
    console.error("Error creating workout:", error);

    if (error instanceof ValidationError) {
      return response(400, { error: error.message, details: error.details });
    }

    return response(500, { error: "Internal server error" });
  }
};
```

**How-to: 5. Lambda Handler: List Workouts**

```typescript
// src/functions/workouts/list-workouts.ts
import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { response } from "../../shared/response";
import { docClient, TableName } from "../../shared/dynamo";
import { QueryCommand } from "@aws-sdk/lib-dynamodb";

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  try {
    const userId = event.requestContext.authorizer?.claims?.sub;
    if (!userId) {
      return response(401, { error: "Unauthorized: No user ID" });
    }

    // Parse query parameters for pagination
    const limit = event.queryStringParameters?.limit
      ? parseInt(event.queryStringParameters.limit)
      : 20;
    const lastKey = event.queryStringParameters?.lastKey
      ? JSON.parse(
          Buffer.from(event.queryStringParameters.lastKey, "base64").toString(),
        )
      : undefined;

    // Query DynamoDB for user's workouts
    const result = await docClient.send(
      new QueryCommand({
        TableName,
        KeyConditionExpression:
          "userId = :userId AND begins_with(sortKey, :prefix)",
        ExpressionAttributeValues: {
          ":userId": `USER#${userId}`,
          ":prefix": "WORKOUT#",
        },
        Limit: limit,
        ExclusiveStartKey: lastKey,
        ScanIndexForward: false, // Descending order (newest first)
      }),
    );

    // Transform items for response
    const workouts = (result.Items || []).map((item) => ({
      workoutId: item.workoutId,
      name: item.name,
      type: item.type,
      date: item.date,
      duration: item.duration,
      status: item.status,
      createdAt: item.createdAt,
    }));

    // Build pagination token
    const nextToken = result.LastEvaluatedKey
      ? Buffer.from(JSON.stringify(result.LastEvaluatedKey)).toString("base64")
      : undefined;

    return response(200, { workouts, nextToken });
  } catch (error) {
    console.error("Error listing workouts:", error);
    return response(500, { error: "Internal server error" });
  }
};
```

**How-to: 6. Lambda Handler: Get Workout**

```typescript
// src/functions/workouts/get-workout.ts
import type { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { response } from "../../shared/response";
import { docClient, TableName } from "../../shared/dynamo";
import { GetCommand, QueryCommand } from "@aws-sdk/lib-dynamodb";

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  try {
    const userId = event.requestContext.authorizer?.claims?.sub;
    if (!userId) {
      return response(401, { error: "Unauthorized: No user ID" });
    }

    const workoutId = event.pathParameters?.id;
    if (!workoutId) {
      return response(400, { error: "Missing workout ID" });
    }

    // Get workout details
    const workoutResult = await docClient.send(
      new QueryCommand({
        TableName,
        KeyConditionExpression: "userId = :userId AND sortKey = :sortKey",
        ExpressionAttributeValues: {
          ":userId": `USER#${userId}`,
          ":sortKey": `WORKOUT#${workoutId}`,
        },
      }),
    );

    const workout = workoutResult.Items?.[0];
    if (!workout) {
      return response(404, { error: "Workout not found" });
    }

    // Get exercises for this workout
    const exercisesResult = await docClient.send(
      new QueryCommand({
        TableName,
        KeyConditionExpression:
          "userId = :userId AND begins_with(sortKey, :prefix)",
        ExpressionAttributeValues: {
          ":userId": `USER#${userId}`,
          ":prefix": `EXERCISE#${workoutId}`,
        },
      }),
    );

    return response(200, {
      ...workout,
      exercises: exercisesResult.Items || [],
    });
  } catch (error) {
    console.error("Error getting workout:", error);
    return response(500, { error: "Internal server error" });
  }
};
```

**How-to: 7. Terraform for Lambda Functions**

```hcl
# terraform/modules/lambda/main.tf

# 1. IAM Role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 2. Attach basic execution role (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Custom policy for DynamoDB access
resource "aws_iam_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:ListTables"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

# 4. Lambda functions (one per handler)
resource "aws_lambda_function" "create_workout" {
  filename         = "../../../backend/dist/functions/workouts/create-workout.zip"
  source_code_hash = filebase64sha256("../../../backend/dist/functions/workouts/create-workout.zip")

  function_name = "${var.project_name}-create-workout-${var.environment}"
  description    = "Create a new workout"
  handler        = "functions/workouts/create-workout.handler"

  runtime     = "nodejs20.x"
  timeout      = 30
  memory_size = 256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      WORKOUTS_TABLE = var.dynamodb_table_name
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Repeat for list-workouts, get-workout, update-workout, delete-workout
```

**Lessons Learned:**

- Initialize AWS SDK clients **outside** the handler (reused across invocations)
- Use Zod for runtime validation of incoming JSON
- Always extract `userId` from `event.requestContext.authorizer.claims.sub` -- this is set by Cognito authorizer
- Return proper HTTP status codes: 201 for created, 200 for success, 400 for bad request, 401 for unauthorized, 404 for not found, 500 for errors
- Use UUIDs for unique IDs, timestamps for sort keys

**Study Questions:**

- Why should AWS SDK clients be initialized outside the Lambda handler?
- What is the difference between GetItem and Query in DynamoDB?
- How does the Cognito authorizer pass the user ID to Lambda?
- What happens if you don't validate input with Zod?

**Resources:**

- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/welcome.html)
- [Zod Validation](https://zod.dev/)

---

#### Key Concepts: Amazon API Gateway

**What is API Gateway?**
API Gateway is AWS's fully managed service for creating, publishing, maintaining, and securing APIs. It acts as the "front door" for your backend services -- accepting API requests, enforcing security, routing to backend services, and returning responses.

**REST API vs HTTP API:**

| Feature                  | REST API               | HTTP API               |
| ------------------------ | ---------------------- | ---------------------- |
| Cost                     | $3.50/million requests | $1.00/million requests |
| Features                 | Full API management    | Lightweight, modern    |
| Request/Response Mapping | Yes                    | No (simpler)           |
| API Key Support          | Yes                    | No                     |
| Usage Plans              | Yes                    | No                     |
| Request Validation       | Yes                    | No                     |
| AWS WAF Integration      | Yes                    | No                     |

For FitCloud: We use **REST API** because it has more CCP-relevant features and supports request validation.

**API Gateway Components:**

1. **REST API**: The container for your API
2. **Resource**: A path in your URL hierarchy (e.g., `/workouts`, `/workouts/{id}`)
3. **Method**: HTTP verb (GET, POST, PUT, DELETE, PATCH, OPTIONS)
4. **Integration**: Where the request goes (Lambda, HTTP, AWS service, mock)
5. **Stage**: A deployable version (e.g., `dev`, `prod`)
6. **Deployment**: A snapshot of the API configuration
7. **Authorizer**: Validates tokens (Cognito, Lambda)
8. **API Key**: For meter tracking

**CORS (Cross-Origin Resource Sharing):**

CORS is critical for React SPAs. Without proper CORS headers:

- Browser blocks frontend JavaScript from calling your API from a different origin
- `localhost:5173` (frontend) can't call `execute-api.us-east-1.amazonaws.com` (API)

You need to configure:

1. **OPTIONS method** on each resource (preflight handling)
2. **Response headers**:
   - `Access-Control-Allow-Origin: *` (or your domain)
   - `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
   - `Access-Control-Allow-Headers: Content-Type, Authorization`

**API Gateway + Lambda Integration:**

When API Gateway receives a request, it can invoke Lambda. This is called **Lambda Proxy Integration**:

```
User -> API Gateway -> Lambda (handler) -> DynamoDB
                                    <- Response <-
```

The Lambda function receives the full HTTP request and returns an HTTP response.

**Throttling and Rate Limiting:**

- **Burst Limit**: Maximum requests per second (default: 10,000 for REST API)
- **Rate Limit**: Requests per second (default: 5,000)
- **Usage Plans**: Track usage by API key (we won't use this)

---

#### Task 3.3: API Gateway Setup

**Status:** Pending

**What you'll create:**

1. API Gateway REST API
2. Resources for `/workouts` and `/workouts/{id}`
3. Methods (GET, POST, PUT, DELETE) for each resource
4. Lambda integrations for each method
5. Cognito authorizer (connect to existing User Pool from Module 2)
6. CORS configuration
7. Deployment and stage

**API Design:**

| Method | Path             | Lambda Function | Description        |
| ------ | ---------------- | --------------- | ------------------ |
| POST   | `/workouts`      | create-workout  | Create a workout   |
| GET    | `/workouts`      | list-workouts   | List all workouts  |
| GET    | `/workouts/{id}` | get-workout     | Get single workout |
| PUT    | `/workouts/{id}` | update-workout  | Update workout     |
| DELETE | `/workouts/{id}` | delete-workout  | Delete workout     |

**Terraform resources used:**

| Resource                      | Purpose             |
| ----------------------------- | ------------------- |
| `aws_api_gateway_rest_api`    | The API             |
| `aws_api_gateway_resource`    | Path resources      |
| `aws_api_gateway_method`      | HTTP methods        |
| `aws_api_gateway_integration` | Lambda integration  |
| `aws_api_gateway_authorizer`  | Cognito authorizer  |
| `aws_api_gateway_deployment`  | Deploy the API      |
| `aws_api_gateway_stage`       | Stage configuration |

**How-to:**

1. **Create the REST API**

   ```hcl
   resource "aws_api_gateway_rest_api" "main" {
     name        = "${var.project_name}-api-${var.environment}"
     description = "FitCloud REST API"
   }
   ```

2. **Create `/workouts` resource**

   ```hcl
   resource "aws_api_gateway_resource" "workouts" {
     rest_api_id = aws_api_gateway_rest_api.main.id
     parent_id   = aws_api_gateway_rest_api.main.root_resource_id
     path_part   = "workouts"
   }
   ```

3. **Create `/workouts/{id}` resource** (for single-item operations)

   ```hcl
   resource "aws_api_gateway_resource" "workout_id" {
     rest_api_id = aws_api_gateway_rest_api.main.id
     parent_id   = aws_api_gateway_resource.workouts.id
     path_part   = "{id}"
   }
   ```

4. **Create Cognito Authorizer** (connect to Module 2's User Pool)

   ```hcl
   resource "aws_api_gateway_authorizer" "cognito" {
     name                   = "${var.project_name}-authorizer-${var.environment}"
     rest_api_id           = aws_api_gateway_rest_api.main.id
     type                   = "COGNITO_USER_POOLS"
     provider_arns         = [var.cognito_user_pool_arn]
     authorizer_result_ttl_in_seconds = 300
   }
   ```

5. **Create methods with authorizer** (example: POST /workouts)

   ```hcl
   resource "aws_api_gateway_method" "workouts_post" {
     rest_api_id   = aws_api_gateway_rest_api.main.id
     resource_id   = aws_api_gateway_resource.workouts.id
     http_method   = "POST"
     authorization = "COGNITO_USER_POOLS"
     authorizer_id = aws_api_gateway_authorizer.cognito.id
   }
   ```

6. **Create Lambda integration**

   ```hcl
   resource "aws_api_gateway_integration" "workouts_post_lambda" {
     rest_api_id = aws_api_gateway_rest_api.main.id
     resource_id = aws_api_gateway_resource.workouts.id
     http_method = aws_api_gateway_method.workouts_post.http_method

     integration_http_method = "POST"
     type                     = "AWS_PROXY"  # Lambda proxy integration
     uri                      = aws_lambda_function.create_workout.invoke_arn
   }
   ```

7. **Add CORS configuration** (OPTIONS method on each resource)

   ```hcl
   resource "aws_api_gateway_method" "workouts_options" {
     rest_api_id   = aws_api_gateway_rest_api.main.id
     resource_id   = aws_api_gateway_resource.workouts.id
     http_method   = "OPTIONS"
     authorization = "NONE"
   }

   resource "aws_api_gateway_integration" "workouts_options_cors" {
     rest_api_id = aws_api_gateway_rest_api.main.id
     resource_id = aws_api_gateway_resource.workouts.id
     http_method = "OPTIONS"

     type = "MOCK"
     response_parameters = {
       "method.response.header.Access-Control-Allow-Origin"  = "'*'",
       "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
       "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
     }
     response_template = ""
   }
   ```

8. **Deploy the API**

   ```hcl
   resource "aws_api_gateway_deployment" "main" {
     rest_api_id = aws_api_gateway_rest_api.main.id

     depends_on = [
       aws_api_gateway_integration.workouts_post_lambda,
       # ... other integrations
     ]
   }

   resource "aws_api_gateway_stage" "dev" {
     deployment_id = aws_api_gateway_deployment.main.id
     rest_api_id  = aws_api_gateway_rest_api.main.id
     stage_name   = "dev"
   }
   ```

9. **Add Lambda permission** (allow API Gateway to invoke Lambda)
   ```hcl
   resource "aws_lambda_permission" "api_gateway" {
     statement_id  = "AllowExecutionFromApiGateway"
     action        = "lambda:InvokeFunction"
     function_name = aws_lambda_function.create_workout.function_name
     principal     = "apigateway.amazonaws.com"
     source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
   }
   ```

**Lessons Learned:**

- REST API uses `AWS_PROXY` integration for Lambda -- Lambda returns the full HTTP response
- The `authorizer_id` on each method connects to Cognito User Pool
- CORS is mandatory for browser clients -- OPTIONS method handles preflight requests
- API must be **deployed** before it can be accessed -- deployment creates a stage
- `depends_on` ensures integrations are ready before deployment

**Code Snippets:**

```bash
# Get the API endpoint after deployment
aws apigateway get-stage --rest-api-id <API_ID> --stage-name dev

# Test the API (after getting JWT token)
curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/dev/workouts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{"name":"Morning Workout","type":"STRENGTH","date":"2025-01-01","duration":3600}'

# List workouts
curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/dev/workouts \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

**Study Questions:**

- What is the difference between REST API and HTTP API in API Gateway?
- Why is CORS configuration needed for a React SPA?
- How does Cognito authorizer protect API Gateway endpoints?
- What is Lambda proxy integration?

**Resources:**

- [API Gateway Developer Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
- [API Gateway Pricing](https://aws.amazon.com/api-gateway/pricing/)
- [Terraform aws_api_gateway_rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api)

---

#### Key Concepts: IAM Roles for Lambda

**Why IAM Roles Matter Here:**

In Module 0, you learned about IAM users, groups, roles, and policies. Now you're applying that knowledge:

- Lambda functions need permissions to access DynamoDB
- Instead of embedding credentials, Lambda **assumes an IAM role**
- The role's permission policy defines what DynamoDB operations are allowed

**Trust Policy:**

Every IAM role has a trust policy (who can assume the role):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

This says: "Lambda service can assume this role."

**Permission Policy:**

The permission policy defines what actions are allowed:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/fitcloud-workouts-dev"
    }
  ]
}
```

This says: "The role can read/write/query the workouts table."

**Managed vs Custom Policies:**

- **Managed Policies**: Created by AWS, reusable (e.g., `AWSLambdaBasicExecutionRole`)
- **Custom Policies**: Created by you, specific to your application

For Lambda, we typically:

1. Attach `AWSLambdaBasicExecutionRole` (managed) for CloudWatch Logs
2. Attach a custom policy for DynamoDB access

**Principle of Least Privilege:**

The permission policy should only grant the minimum access needed:

- ✅ `dynamodb:GetItem` on specific table
- ❌ `dynamodb:*` on all tables (`*` is too broad)
- ❌ `dynamodb:GetItem` on `*` (any table)

**Exam Tip**: The CCP exam tests whether you understand least privilege.

---

#### Task 3.4: IAM Role & Permission Policy

**Status:** Pending

**What you'll create:**

1. IAM role for Lambda execution (trust policy)
2. Managed policy attachment for CloudWatch Logs
3. Custom IAM policy for DynamoDB access
4. Lambda permission to allow API Gateway invocation

**This task is already included in the Terraform from Task 3.2!**

See the Terraform code in Task 3.2 (`aws_iam_role`, `aws_iam_policy`, `aws_iam_role_policy_attachment`).

The key components:

```hcl
# Trust policy (in aws_iam_role resource)
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "lambda.amazonaws.com"
    }
  }]
})

# Permission policy (in aws_iam_policy resource)
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Effect = "Allow"
    Action = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    Resource = [
      var.dynamodb_table_arn,
      "${var.dynamodb_table_arn}/index/*"
    ]
  }]
})
```

**Lessons Learned:**

- IAM role = trust policy + permission policy
- Trust policy: "who can assume this role" (Lambda service)
- Permission policy: "what can this role do" (DynamoDB operations)
- Always scope DynamoDB permissions to specific table ARN
- Use managed policies for common needs (CloudWatch Logs)

**Study Questions:**

- between a trust policy What is the difference and a permission policy?
- Why should DynamoDB permissions be scoped to specific tables?
- What managed policy is needed for Lambda to write CloudWatch Logs?

---

#### Task 3.5: End-to-End Testing & Deployment

**Status:** Pending

**What you'll create:**

1. Deploy all Module 3 resources via Terraform
2. Test the full authentication + API flow
3. Verify data in DynamoDB

**Deployment Workflow:**

```bash
cd terraform/envs/dev

# 1. Add the new modules to envs/dev/main.tf
# (Add module "dynamodb", module "lambda", module "api_gateway")

# 2. Format code
terraform fmt -recursive

# 3. Validate syntax
terraform validate

# 4. Preview changes
terraform plan

# 5. Apply (creates real AWS resources)
terraform apply

# 6. Note outputs
# - API endpoint URL
# - DynamoDB table name
```

**Manual Testing Flow:**

1. **Get JWT Token** (via Cognito Hosted UI):
   - Visit: `https://<your-domain>.auth.us-east-1.amazoncognito.com/login?client_id=<client-id>&response_type=code&scope=openid+profile&redirect_uri=http://localhost:5173`
   - Sign up / Sign in
   - Copy the authorization code from the redirect URL

2. **Exchange code for tokens** (using Amplify or manually):

   ```bash
   curl -X POST https://<your-domain>.auth.us-east-1.amazoncognito.com/oauth2/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=authorization_code" \
     -d "client_id=<client-id>" \
     -d "code=<auth-code>" \
     -d "redirect_uri=http://localhost:5173"
   ```

3. **Test API endpoints**:

   ```bash
   # Replace <TOKEN> with your actual access_token
   TOKEN="eyJraWQiOi..."

   # Create a workout
   curl -X POST https://<API_ID>.execute-api.us-east-1.amazonaws.com/dev/workouts \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $TOKEN" \
     -d '{"name":"Morning Workout","type":"STRENGTH","date":"2025-01-01","duration":3600}'

   # List workouts
   curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/dev/workouts \
     -H "Authorization: Bearer $TOKEN"

   # Get specific workout (replace <WORKOUT_ID>)
   curl -X GET https://<API_ID>.execute-api.us-east-1.amazonaws.com/dev/workouts/<WORKOUT_ID> \
     -H "Authorization: Bearer $TOKEN"
   ```

4. **Verify in DynamoDB**:

   ```bash
   # Scan table (dev only - not for production!)
   aws dynamodb scan --table-name fitcloud-workouts-dev

   # Query specific user's workouts
   aws dynamodb query \
     --table-name fitcloud-workouts-dev \
     --key-condition-expression "userId = :uid" \
     --expression-attribute-values '{":uid":{"S":"USER#<user-id>"}}'
   ```

**Verification Checklist:**

- [ ] DynamoDB table exists with correct name
- [ ] Lambda functions deployed with correct runtime (nodejs20.x)
- [ ] Lambda execution role has DynamoDB permissions
- [ ] API Gateway REST API created
- [ ] All routes mapped to Lambda functions (/workouts, /workouts/{id})
- [ ] Cognito authorizer attached to methods
- [ ] CORS configured (OPTIONS methods return correct headers)
- [ ] API deployed to dev stage
- [ ] API responds to requests
- [ ] Unauthenticated requests return 401
- [ ] Authenticated requests return workout data
- [ ] Data appears in DynamoDB

**Common Mistakes to Avoid:**

1. **Forgetting Lambda permissions**: API Gateway returns 500 if Lambda can't access DynamoDB
2. **Missing CORS**: Browser JavaScript requests fail without OPTIONS methods
3. **Wrong authorizer type**: Use `COGNITO_USER_POOLS`, not `REQUEST` for simple Cognito
4. **Not deploying the API**: Changes don't take effect until you create a deployment
5. **Missing `depends_on`**: API deployment may fail if integrations aren't ready
6. **Wrong path parameters**: `{id}` in API Gateway becomes `event.pathParameters.id` in Lambda
7. **JSON parse errors**: Remember `event.body` is a string, must JSON.parse()
8. **Wrong JWT claim**: Cognito puts user ID in `event.requestContext.authorizer.claims.sub`

**Architecture Diagram (Full Module 3):**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          FITCLOUD ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐      ┌──────────────────┐      ┌──────────────────┐      │
│  │  React   │──────▶│  API Gateway    │──────▶│    Lambda        │      │
│  │  Frontend│      │  REST API        │      │  (Node.js 20)   │      │
│  └──────────┘      └────────┬─────────┘      └────────┬─────────┘      │
│       │                     │                       │                  │
│       │ JWT Bearer         │                       │                  │
│       │ Token             │                       ▼                  │
│       ▼                   │              ┌──────────────────┐          │
│  ┌──────────────┐        │              │    DynamoDB     │          │
│  │  Cognito     │◀───────┘              │  (Single-table) │          │
│  │  User Pool   │                       └──────────────────┘          │
│  │  (Auth)      │                       │  PK: userId              │
│  └──────────────┘                       │  SK: sortKey             │
│                                          │                            │
│  Cognito validates JWT,                   │                            │
│  API Gateway authorizes                   │                            │
│  Lambda receives userId                    │                            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

#### Module 3 Deployment Workflow

```bash
# Navigate to terraform
cd terraform/envs/dev

# 1. Add new modules to main.tf (see Task 3.1-3.4 for module code)
# - module "dynamodb" { source = "../../modules/dynamodb" ... }
# - module "lambda" { source = "../../modules/lambda" ... }
# - module "api_gateway" { source = "../../modules/api-gateway" ... }

# 2. Format code
terraform fmt -recursive

# 3. Validate syntax
terraform validate

# 4. Preview what will be created
terraform plan

# 5. Apply (creates real AWS resources)
terraform apply

# 6. Build and deploy Lambda functions
# (First build the TypeScript, then update Lambda)
cd ../../backend
npm install
npm run build

# 7. Update Lambda functions with new code
aws lambda update-function-code \
  --function-name fitcloud-create-workout-dev \
  --zip-file fileb://dist/functions/workouts/create-workout.zip

# (Repeat for other Lambda functions)

# 8. Test the API
# See testing section above
```

---

#### Module 3 Verification Checklist

- [ ] DynamoDB table `fitcloud-workouts-dev` exists
- [ ] Table uses on-demand billing (PAY_PER_REQUEST)
- [ ] Lambda functions deployed: create-workout, list-workouts, get-workout, update-workout, delete-workout
- [ ] Lambda execution role has DynamoDB permissions
- [ ] API Gateway REST API exists
- [ ] All 5 routes mapped: POST/GET /workouts, GET/PUT/DELETE /workouts/{id}
- [ ] Cognito authorizer attached to all methods
- [ ] CORS configured (OPTIONS methods present)
- [ ] API deployed to `dev` stage
- [ ] Unauthenticated request returns 401
- [ ] Authenticated request with valid JWT returns workout data
- [ ] Workout created appears in DynamoDB

---

#### AWS Cloud Practitioner Exam Topics Covered

| Exam Domain    | Topic from this module                                                                                  |
| -------------- | ------------------------------------------------------------------------------------------------------- |
| Technology     | DynamoDB (NoSQL, single-table, on-demand), Lambda (serverless, pricing), API Gateway (REST API, stages) |
| Security       | IAM roles for Lambda, least privilege policies, Cognito JWT authorization                               |
| Cloud Concepts | Serverless computing, managed services, event-driven architecture                                       |
| Billing        | DynamoDB on-demand ($0.25/million), Lambda free tier (1M requests), API Gateway free tier (1M requests) |

**Key Exam Points:**

- DynamoDB is a fully managed NoSQL service
- Lambda runs code without provisioning servers
- API Gateway manages API access and security
- Serverless means you don't manage the underlying compute
- All three services have generous free tiers for learning

---

#### Common Mistakes to Avoid

1. **Forgetting to deploy API Gateway** -- API changes don't work until deployed
2. **Missing CORS configuration** -- React SPA requests will fail
3. **Wrong userId extraction** -- Cognito authorizer puts it in `event.requestContext.authorizer.claims.sub`
4. **Using wrong DynamoDB SDK** -- Use `@aws-sdk/lib-dynamodb` for document client
5. **Not handling JSON parse errors** -- `event.body` is always a string
6. **Overly permissive IAM policies** -- Always scope to specific table ARN
7. **Missing Lambda permission** -- API Gateway can't invoke Lambda without it
8. **Using provisioned capacity** -- Stay with on-demand for free tier

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
