output "user_pull_id" {
  description = "Cognito user pull id"
  value       = aws_cognito_user_pool.main.id
}

output "user_pull_client_id" {
  description = "Cognito user pull client id"
  value       = aws_cognito_user_pool_client.client.id
}

output "user_pull_domain_id" {
  description = "Cognito user pull domain id"
  value       = aws_cognito_user_pool_domain.domain.domain

}
