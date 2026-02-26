# ☁️ FitCloud - AWS Serverless Fitness Tracker

> A cloud-native fitness and nutrition tracking application built with AWS serverless services

## 🎯 Project Overview

FitCloud is a comprehensive fitness tracking application designed to help users:
- Track workouts and exercise progress
- Log nutrition and monitor caloric intake
- Generate AI-powered workout plans
- Visualize progress through analytics

**Primary Goals:**
- Learn AWS cloud computing fundamentals
- Prepare for AWS Cloud Practitioner certification
- Build a portfolio-ready serverless application

## 🏗️ Architecture

- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui
- **Backend**: AWS Lambda (Node.js 20) + API Gateway
- **Database**: DynamoDB (NoSQL)
- **Authentication**: AWS Cognito
- **Storage**: S3 + CloudFront CDN
- **AI**: AWS Bedrock (Claude)
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions

## 📁 Project Structure

```
fitcloud/
├── frontend/          # React SPA application
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── utils/
│   └── public/
├── backend/           # Lambda functions
│   ├── src/
│   │   ├── functions/
│   │   │   ├── auth/
│   │   │   ├── workouts/
│   │   │   ├── nutrition/
│   │   │   └── plans/
│   │   └── shared/
│   └── tests/
├── terraform/         # Infrastructure as Code
│   ├── modules/
│   └── environments/
├── docs/             # Documentation
├── scripts/          # Utility scripts
└── .github/          # CI/CD workflows
```

## 🚀 Quick Start

### Prerequisites

- Node.js 20+
- npm or yarn
- AWS CLI v2
- Terraform 1.6+
- Git

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd fitcloud

# Install frontend dependencies
cd frontend
npm install

# Install backend dependencies
cd ../backend
npm install

# Return to root
cd ..
```

### Development

```bash
# Start frontend development server
cd frontend
npm run dev

# In another terminal, start backend (if using LocalStack)
cd backend
npm run dev
```

### Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan infrastructure changes
terraform plan

# Apply changes
terraform apply
```

## 📚 Documentation

- [Architecture Guide](./docs/ARCHITECTURE.md)
- [API Documentation](./docs/API.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Contributing Guidelines](./CONTRIBUTING.md)
- [Agent Guidelines](./AGENTS.md)

## 🧪 Testing

```bash
# Run frontend tests
cd frontend
npm test

# Run backend tests
cd backend
npm test

# Run E2E tests
cd frontend
npm run test:e2e
```

## 📊 AWS Services Used

- **Compute**: Lambda, API Gateway
- **Storage**: S3, CloudFront
- **Database**: DynamoDB
- **Auth**: Cognito, IAM
- **Monitoring**: CloudWatch, X-Ray
- **AI**: Bedrock
- **DevOps**: EventBridge, OIDC

## 🎓 Learning Path

This project is structured to align with AWS Cloud Practitioner certification:

1. **Module 0**: AWS Fundamentals & Account Setup
2. **Module 1**: Static Website Hosting (S3 + CloudFront)
3. **Module 2**: Authentication (Cognito + IAM)
4. **Module 3**: Workout Tracking (Lambda + DynamoDB)
5. **Module 4**: Nutrition Tracking (External APIs)
6. **Module 5**: AI Features (Bedrock)
7. **Module 6**: Analytics & Dashboards
8. **Module 7**: Monitoring (CloudWatch)
9. **Module 8**: CI/CD (GitHub Actions)
10. **Module 9**: Frontend Development
11. **Module 10**: Testing & Security
12. **Module 11**: Documentation & Portfolio

## 💰 Cost

Estimated monthly cost: **< $10** (within AWS Free Tier for most services)

- Lambda: Free (under 1M requests)
- DynamoDB: Free (25GB storage, on-demand)
- S3: Free (5GB storage)
- CloudFront: Free (1TB transfer)
- Cognito: Free (50K MAUs)
- Bedrock: ~$2-5/month (depending on usage)

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](./LICENSE) for details.

## 🙏 Acknowledgments

Built as a learning project for AWS cloud computing and serverless architecture.
