# Uncomment and configure for remote state (S3 backend)
terraform {
  backend "s3" {
    bucket         = "ssnc-poc-tfstate-bucket"
    key            = "ssnc-iac-aws/development.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# For local backend (default), no configuration needed
