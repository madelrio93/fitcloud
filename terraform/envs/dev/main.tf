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

module "lambda" {
  source = "../../modules/lambda"

  project_name                = var.project_name
  environment                 = var.environment
  dynamodb_profile_table_name = module.dynamodb.profile_table_name
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  project_name                  = var.project_name
  environment                   = var.environment
  cognito_user_pool_id          = module.cognito.user_pull_id
  cognito_client_id             = module.cognito.user_pull_client_id
  get_profile_lambda_arn        = module.lambda.profile_lambda_function_arn
  get_profile_lambda_invoke_arn = module.lambda.get_profile_invoke_arn
}