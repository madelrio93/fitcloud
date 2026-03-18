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
