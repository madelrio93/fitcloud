output "user_pull_client_id" {
  description = "Cognito user pool client id (from module cognito)"
  value       = module.cognito.user_pull_client_id
}

output "cognito_hosted_ui_url" {
  description = "Hosted UI URL"
  value       = module.cognito.cognito_hosted_ui_url
}

output "profile_lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.lambda.profile_lambda_function_arn
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}