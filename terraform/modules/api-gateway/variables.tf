variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authorization"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito User Pool Client ID (audience for JWT)"
  type        = string
}

variable "get_profile_lambda_arn" {
  description = "ARN of the get-profile Lambda function"
  type        = string
}

variable "get_profile_lambda_invoke_arn" {
  description = "Invoke ARN of the get-profile Lambda function"
  type        = string
}
