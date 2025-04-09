import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import * as apigateway from "@pulumi/aws-apigateway";

// Create a DynamoDB table
const todoTable = new aws.dynamodb.Table("todo-table", {
    attributes: [
        { name: "id", type: "S" },
    ],
    hashKey: "id",
    billingMode: "PAY_PER_REQUEST",
    tags: {
        Environment: "dev",
        Project: "x-as-code-demo"
    },
});

// Create an IAM role for the Lambda function
const lambdaRole = new aws.iam.Role("lambda-role", {
    assumeRolePolicy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
            Action: "sts:AssumeRole",
            Effect: "Allow",
            Principal: {
                Service: "lambda.amazonaws.com",
            },
        }],
    }),
});

// Attach DynamoDB policy to the Lambda role
const dynamoPolicy = new aws.iam.RolePolicy("dynamo-policy", {
    role: lambdaRole.id,
    policy: todoTable.arn.apply(arn => JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
            Action: [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan",
                "dynamodb:UpdateItem",
            ],
            Resource: arn,
            Effect: "Allow",
        }],
    })),
});

// Also attach the basic Lambda execution role policy
const lambdaBasicExecutionPolicy = new aws.iam.RolePolicyAttachment("lambda-basic-execution", {
    policyArn: "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    role: lambdaRole,
});

// Create a Lambda function for getting todos
const getTodosFunction = new aws.lambda.Function("get-todos", {
    runtime: aws.lambda.NodeJS16dXRuntime,
    code: new pulumi.asset.AssetArchive({
        ".": new pulumi.asset.FileArchive("./lambdas"),
    }),
    handler: "getTodos.handler",
    role: lambdaRole.arn,
    environment: {
        variables: {
            TABLE_NAME: todoTable.name,
        },
    },
    tags: {
        Environment: "dev",
        Project: "x-as-code-demo"
    },
});

// Create a Lambda function for creating a todo
const createTodoFunction = new aws.lambda.Function("create-todo", {
    runtime: aws.lambda.NodeJS16dXRuntime,
    code: new pulumi.asset.AssetArchive({
        ".": new pulumi.asset.FileArchive("./lambdas"),
    }),
    handler: "createTodo.handler",
    role: lambdaRole.arn,
    environment: {
        variables: {
            TABLE_NAME: todoTable.name,
        },
    },
    tags: {
        Environment: "dev",
        Project: "x-as-code-demo"
    },
});

// Create an API Gateway REST API
const api = new apigateway.RestAPI("todo-api", {
    routes: [
        {
            path: "/todos",
            method: "GET",
            eventHandler: getTodosFunction,
        },
        {
            path: "/todos",
            method: "POST",
            eventHandler: createTodoFunction,
        },
    ],
});

// Export the API URL
export const apiUrl = api.url;
export const dynamoTableName = todoTable.name;
