output "profile_table_name" {
  value = aws_dynamodb_table.profile.name
  description = "Name of the DynamoDB table for profile"          
}

output "profile_table_arn" {
  value = aws_dynamodb_table.profile.arn
  description = "ARN of the DynamoDB table for profile"
}