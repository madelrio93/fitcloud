resource "aws_cognito_user_pool" "main" {
  name = "fitcloud-user-pool-${var.environment}"

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }


  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "fitcloud-auth-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "client" {
  name = "client"

  user_pool_id = aws_cognito_user_pool.main.id
}