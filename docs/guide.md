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
