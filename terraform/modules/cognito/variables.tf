variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}
variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}

variable "domain" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}