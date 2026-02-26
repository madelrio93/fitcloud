# AGENTS.md - FitCloud Project Guidelines

> Guidelines for AI coding agents working on FitCloud - AWS Serverless Fitness Tracker

## Project Overview

FitCloud is a serverless fitness and nutrition tracking application built on AWS. The project uses:
- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS + shadcn/ui
- **Backend**: Node.js 20 Lambda functions (TypeScript)
- **Infrastructure**: Terraform
- **Database**: DynamoDB
- **Auth**: AWS Cognito
- **Testing**: Vitest (unit), Jest (backend), Playwright (E2E)

## Project Structure

```
fitcloud/
├── frontend/          # React SPA
├── backend/           # Lambda functions
├── terraform/         # Infrastructure as Code
├── docs/             # Documentation
├── .github/          # CI/CD workflows
└── scripts/          # Utility scripts
```

---

## Build Commands

### Frontend (in `frontend/` directory)

```bash
# Install dependencies
npm install

# Development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint

# Fix lint issues
npm run lint:fix

# Type check
npm run typecheck

# Run unit tests
npm test

# Run single test file
npm test -- path/to/test.test.ts

# Run single test by name
npm test -- --grep "test name"

# Run tests with coverage
npm test -- --coverage

# Run E2E tests
npm run test:e2e

# Run E2E tests (headed)
npm run test:e2e:headed
```

### Backend (in `backend/` directory)

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Watch mode for development
npm run build:watch

# Lint code
npm run lint

# Fix lint issues
npm run lint:fix

# Type check
npm run typecheck

# Run unit tests
npm test

# Run single test file
npm test -- path/to/test.test.ts

# Run single test by name pattern
npm test -- --testNamePattern="should create user"

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test:watch
```

### Terraform (in `terraform/` directory)

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Lint with tflint (if installed)
tflint
```

### Root Level Commands

```bash
# Install all dependencies (monorepo)
npm run install:all

# Build everything
npm run build

# Run all linters
npm run lint

# Run all tests
npm run test

# Run all type checks
npm run typecheck
```

---

## Code Style Guidelines

### TypeScript

- **Strict mode**: Always enabled (`"strict": true` in tsconfig.json)
- **No `any`**: Use `unknown` and type guards, or define proper types
- **Explicit return types**: Required for all function declarations
- **Prefer interfaces**: For object shapes, use `interface` over `type`
- **Use `const` assertions**: For literal types and readonly arrays

### Naming Conventions

```typescript
// Variables and functions: camelCase
const userName = 'John';
function getUserById(id: string): User { }

// Components: PascalCase
export function UserProfile() { }
export const WorkoutCard = () => { }

// Types and Interfaces: PascalCase
interface UserProfile { }
type ApiResult<T> = { data: T; error: Error | null };

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRIES = 3;
const API_BASE_URL = 'https://api.example.com';

// Enums: PascalCase for name, PascalCase for values
enum GoalType {
  WeightLoss = 'WEIGHT_LOSS',
  MuscleGain = 'MUSCLE_GAIN',
  Maintenance = 'MAINTENANCE',
}

// Files: kebab-case
// user-profile.tsx, workout-card.tsx, api-client.ts
```

### Import Order

```typescript
// 1. Node.js built-ins
import { createHash } from 'crypto';

// 2. External packages
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { z } from 'zod';

// 3. Internal packages (monorepo)
import { dbClient } from '@fitcloud/database';
import { Logger } from '@fitcloud/logger';

// 4. Relative imports (parent directories)
import { config } from '../../config';
import { User } from '../types';

// 5. Relative imports (same directory)
import { validateInput } from './validation';
import { formatResponse } from './response';

// 6. Type-only imports (last)
import type { APIGatewayProxyEvent } from 'aws-lambda';
import type { User } from '../types';
```

### React Component Structure

```typescript
// 1. Imports
import { useState, useEffect } from 'react';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/hooks/use-auth';
import type { User } from '@/types';

// 2. Types
interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

// 3. Component
export function UserProfile({ userId, onUpdate }: UserProfileProps) {
  // 3a. Hooks at the top
  const { user } = useAuth();
  const [loading, setLoading] = useState(false);
  
  // 3b. Effects
  useEffect(() => {
    fetchUser();
  }, [userId]);
  
  // 3c. Handlers
  const handleUpdate = async (data: Partial<User>) => {
    // ...
  };
  
  // 3d. Render
  if (loading) {
    return <LoadingSpinner />;
  }
  
  return (
    <div className="...">
      {/* Component JSX */}
    </div>
  );
}
```

### Lambda Function Structure

```typescript
// 1. Imports
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { response } from '../utils/response';
import { validateInput } from '../utils/validation';
import type { User } from '../types';

// 2. Initialize clients outside handler
const dynamoClient = new DynamoDBClient({});

// 3. Handler
export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    // 3a. Extract and validate input
    const userId = event.requestContext.authorizer?.claims?.sub;
    const body = JSON.parse(event.body || '{}');
    const validated = validateInput(body, userSchema);
    
    // 3b. Business logic
    const result = await processData(validated);
    
    // 3c. Return success
    return response(200, result);
  } catch (error) {
    // 3d. Handle errors
    console.error('Error:', error);
    return response(500, { error: 'Internal server error' });
  }
};
```

### Error Handling

```typescript
// Custom error classes
class ValidationError extends Error {
  constructor(message: string, public details: unknown) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NotFoundError extends Error {
  constructor(resource: string) {
    super(`${resource} not found`);
    this.name = 'NotFoundError';
  }
}

// Use try-catch with typed errors
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    if (error instanceof AxiosError) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User');
      }
      throw new ValidationError('Invalid request', error.response?.data);
    }
    throw error; // Re-throw unknown errors
  }
}

// Result pattern for operations
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

async function deleteUser(id: string): Promise<Result<void>> {
  try {
    await api.delete(`/users/${id}`);
    return { success: true, data: undefined };
  } catch (error) {
    return { success: false, error: error as Error };
  }
}
```

### Validation with Zod

```typescript
// Define schemas
const userSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
  age: z.number().min(13).max(120),
  goals: z.enum(['weight_loss', 'muscle_gain', 'maintenance']),
});

type User = z.infer<typeof userSchema>;

// Use in API handlers
const validated = userSchema.parse(body);

// Use safe parse for error handling
const result = userSchema.safeParse(body);
if (!result.success) {
  return response(400, { errors: result.error.errors });
}
```

---

## Formatting

- **Formatter**: Prettier (auto-format on save)
- **Linting**: ESLint with TypeScript rules
- **Print width**: 100 characters
- **Indentation**: 2 spaces
- **Quotes**: Single quotes for JS/TS, double for JSX
- **Trailing commas**: ES5 (objects, arrays)
- **Semicolons**: Required

### Prettier Config (`.prettierrc`)

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "jsxSingleQuote": false
}
```

---

## Testing Guidelines

### Unit Tests

- **Naming**: `*.test.ts` or `*.spec.ts`
- **Framework**: Vitest (frontend), Jest (backend)
- **Location**: Next to source files or in `__tests__/` directory

```typescript
// user.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { UserService } from './user-service';

describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
  });

  it('should create a user with valid data', async () => {
    const data = { name: 'John', email: 'john@example.com' };
    const user = await service.create(data);
    expect(user.name).toBe('John');
  });

  it('should throw ValidationError for invalid email', async () => {
    const data = { name: 'John', email: 'invalid' };
    await expect(service.create(data)).rejects.toThrow(ValidationError);
  });
});
```

### E2E Tests (Playwright)

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test('user can register', async ({ page }) => {
  await page.goto('/register');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'Password123!');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');
});
```

---

## AWS Best Practices

### Lambda Functions

- Keep functions small and single-purpose
- Use environment variables for configuration
- Initialize clients outside the handler
- Implement structured logging
- Use X-Ray for tracing
- Set appropriate timeouts (default: 30s)
- Right-size memory allocation

### DynamoDB

- Use on-demand capacity for unpredictable workloads
- Design for queries, not normalization
- Use GSIs for alternate access patterns
- Implement optimistic locking with version attributes
- Use pagination for large result sets

### Security

- Never hardcode secrets
- Use AWS Secrets Manager or SSM Parameter Store
- Implement least privilege IAM policies
- Enable CloudTrail and CloudWatch logging
- Use HTTPS everywhere
- Validate all inputs

---

## Git Commit Messages

Use conventional commits format:

```
feat: add user profile management
fix: resolve authentication token refresh issue
docs: update API documentation
style: format code with prettier
refactor: extract user validation logic
test: add unit tests for workout service
chore: update dependencies
```

---

## Important Files to Check

Before making changes, review these files:
- `tsconfig.json` - TypeScript configuration
- `.eslintrc.js` - Linting rules
- `.prettierrc` - Formatting rules
- `.env.example` - Environment variables
- `package.json` - Dependencies and scripts
- `README.md` - Project documentation

---

## Task Completion Checklist

Before submitting changes:
- [ ] Code compiles without TypeScript errors
- [ ] ESLint passes with no warnings
- [ ] Prettier has formatted all files
- [ ] Unit tests pass
- [ ] New code has test coverage
- [ ] Documentation updated if needed
- [ ] Commit message follows convention
