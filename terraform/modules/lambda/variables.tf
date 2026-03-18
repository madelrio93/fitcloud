variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}

variable "dynamodb_profile_table_name" {
  description = "Name of the DynamoDB table for user profiles"
  type        = string
}