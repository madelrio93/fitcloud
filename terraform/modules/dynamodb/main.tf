resource "aws_dynamodb_table" "workouts" {
    name = "${var.project_name}-workouts-${var.environment}"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "userId"
    range_key = "workoutId"

    attribute {
      name = "userId"
      type = "S"
    }

    attribute {
      name = "workoutId"
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