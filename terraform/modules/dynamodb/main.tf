resource "aws_dynamodb_table" "profile" {
    name = "${var.project_name}-profile-${var.environment}"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "userId"
    range_key = "sortKey"

    attribute {
      name = "userId"
      type = "S"
    }

    attribute {
      name = "sortKey"
      type = "S"
    }

    ttl {
      attribute_name = "expiresAt"
      enabled = false
    }

    tags = {
      Project = var.project_name
      Environment = var.environment
    }
}