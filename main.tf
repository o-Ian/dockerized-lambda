terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.20.0"
    }
  }

  backend "s3" {
    bucket         = "terraformbucket12345"
    key            = "terraform.tfstate"
    dynamodb_table = "vwsermi_terraform"
    region         = "eu-west-1"
    encrypt        = true
  }

  required_version = ">= 1.5.7"
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      context = "vwsermi"
    }
  }
}

resource "aws_s3_bucket" "vwsermi_terraform" {
  bucket = "terraformbucket12345"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "vwsermi_terraform" {
  bucket = aws_s3_bucket.vwsermi_terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vwsermi_terraform" {
  bucket = aws_s3_bucket.vwsermi_terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vwsermi_terraform" {
  bucket = aws_s3_bucket.vwsermi_terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "vwsermi_terraform" {
  name         = "vwsermi_terraform"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_lambda_function" "vwsermi_notification" {
  role = "arn:aws:iam::746950625370:role/iam_role_lambda_default"
  function_name = "vwsermi_notification"
  handler       = "lambda.project.HelloLambda::handleRequest"
  image_uri     = "746950625370.dkr.ecr.eu-west-1.amazonaws.com/lambda:latest"
  package_type = "Image"
  timeout = 10
  memory_size = 512

  runtime = "java17"
}
