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

# --- Cognito App Client ---
resource "aws_cognito_user_pool_client" "client" {
  name = "fitcloud-client-${var.environment}"

  user_pool_id                 = aws_cognito_user_pool.main.id
  supported_identity_providers = ["COGNITO"]

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = [
    "http://localhost:5173",
    "https://${var.domain != "" ? var.domain : "localhost:5173"}"
  ]

  logout_urls = [
    "http://localhost:5173",
    "https://${var.domain != "" ? var.domain : "localhost:5173"}"
  ]

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  enable_token_revocation = true

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]

  prevent_user_existence_errors = "ENABLED"

  read_attributes  = ["email", "email_verified", "name", "sub"]
  write_attributes = ["email", "name"]

  depends_on = [aws_cognito_user_pool.main]
}
