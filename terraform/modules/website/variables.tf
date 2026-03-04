variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Project name used in resource names and tags"
  type        = string
  default     = "fitcloud"
}

variable "default_root_object" {
  description = "Default root object for CloudFront" 
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}
