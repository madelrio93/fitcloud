output "user_pull_client_id" {
  description = "Cognito user pool client id (from module cognito)"
  value       = module.cognito.user_pull_client_id
}

output "cognito_hosted_ui_url" {
  description = "Hosted UI URL"
  value       = module.cognito.cognito_hosted_ui_url
}