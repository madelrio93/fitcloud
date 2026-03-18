import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  QueryCommand,
  GetCommand,
  PutCommand,
  UpdateCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
export const ddbDocClient = DynamoDBDocumentClient.from(client);
export const ddbCommands = {
  scan: ScanCommand,
  query: QueryCommand,
  get: GetCommand,
  put: PutCommand,
  update: UpdateCommand,
  delete: DeleteCommand,
};
