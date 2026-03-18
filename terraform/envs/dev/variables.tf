variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment for which the infrastructure is being provisioned (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}

variable "profile_table_name" {
  description = "Name of the DynamoDB table for user profiles"
  type        = string
} 

