data "archive_file" "get_profile_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../backend/dist"
  output_path = "${path.module}/get-profile.zip"
}

resource "aws_iam_role" "get_profile_exec" {
  name = "${var.project_name}-get-profile-exec-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_policy" "get_profile_exec" {
  name        = "${var.project_name}-get-profile-exec-${var.environment}"
  description = "Policy for get-profile Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
        }, {
        Effect = "Allow",
        Action = [
          "dynamodb:Scan",
        ],
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_profile_table_name}"
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_policy_attachment" "get_profile_exec" {
  name       = "get_profile_exec_policy_attachment"
  policy_arn = aws_iam_policy.get_profile_exec.arn
  roles      = [aws_iam_role.get_profile_exec.name]
}

resource "aws_lambda_function" "get_profile" {
  filename      = data.archive_file.get_profile_lambda.output_path
  function_name = "${var.project_name}-get-profile-${var.environment}"
  role          = aws_iam_role.get_profile_exec.arn
  handler       = "modules/profile/handlers/get-profile.handleGetUser"
  runtime       = "nodejs20.x"

  source_code_hash = data.archive_file.get_profile_lambda.output_base64sha256

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
