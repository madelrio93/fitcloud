provider "aws" {
  region = var.aws_region
}

module "website" {
  source = "../../modules/website"

  project_name        = var.project_name
  environment         = var.environment
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
}

module "cognito" {
  source = "../../modules/cognito"

  project_name = var.project_name
  environment  = var.environment
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}
