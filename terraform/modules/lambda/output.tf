output "profile_lambda_function_arn" {
  description = "Get Profile Lambda function ARN"
  value       = aws_lambda_function.get_profile.arn
}

output "get_profile_invoke_arn" {
  description = "Get Profile Lambda function Invoke ARN"
  value       = aws_lambda_function.get_profile.invoke_arn
}