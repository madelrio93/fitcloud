output "workouts_table_name" {
  value = aws_dynamodb_table.workouts.name
  description = "Name of the DynamoDB table for workouts"          
}

output "workouts_table_arn" {
  value = aws_dynamodb_table.workouts.arn
  description = "ARN of the DynamoDB table for workouts"
}