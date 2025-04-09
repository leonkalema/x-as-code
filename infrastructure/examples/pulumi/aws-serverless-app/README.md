# AWS Serverless Application with Pulumi

This example demonstrates how to use Pulumi to create a serverless application on AWS with the following components:

- DynamoDB table for data storage
- Lambda functions for backend logic
- API Gateway for REST API endpoints
- IAM roles and policies for security

## Architecture

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│              │      │              │      │              │
│ API Gateway  │─────▶│    Lambda    │─────▶│   DynamoDB   │
│              │      │              │      │              │
└──────────────┘      └──────────────┘      └──────────────┘
```

## Prerequisites

- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/)
- [Node.js](https://nodejs.org/en/download/) (v14 or later)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured

## Getting Started

1. Initialize a new stack (first time only):
   ```bash
   pulumi stack init dev
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure AWS region:
   ```bash
   pulumi config set aws:region us-west-2
   ```

4. Deploy the stack:
   ```bash
   pulumi up
   ```

5. Test the API:
   ```bash
   # Get the API URL from the output
   export API_URL=$(pulumi stack output apiUrl)
   
   # Create a new todo
   curl -X POST $API_URL/todos \
     -H "Content-Type: application/json" \
     -d '{"title": "Learn Pulumi"}'
   
   # Get all todos
   curl $API_URL/todos
   ```

6. When finished, destroy the resources:
   ```bash
   pulumi destroy
   ```

## Structure

- `index.ts` - Main Pulumi program defining the infrastructure
- `lambdas/` - Lambda function code
  - `getTodos.js` - Lambda to retrieve todos from DynamoDB
  - `createTodo.js` - Lambda to create new todos in DynamoDB

## Security Considerations

For a production deployment, consider the following improvements:

- Add authentication/authorization (e.g., with Amazon Cognito)
- Implement API key validation
- Use more restrictive IAM policies
- Enable AWS CloudTrail for auditing
- Add input validation and error handling in Lambda functions

## Integration Points

This example can be integrated with:
- CI/CD pipelines (e.g., GitHub Actions, AWS CodePipeline)
- Monitoring as Code (CloudWatch Alarms, X-Ray tracing)
- Security as Code (AWS Config rules, IAM policies)
