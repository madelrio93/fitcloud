terraform {
  backend "s3" {
    # S3 bucket you created to store the state file
    bucket = "fitcloud-terraform-dev-state-mdr-v1"

    # The prefix is the path within the bucket where the state file will be stored
    key = "dev/terraform.tfstate"

    # The AWS region where your S3 bucket is located
    region = "us-east-1"

    # The DynamoDB table you created for state locking
    dynamodb_table = "fitcloud-terraform-dev-locks"

    # Enable encryption for the state file
    encrypt = true
  }
}
