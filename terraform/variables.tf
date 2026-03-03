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
