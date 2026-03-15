variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}