terraform {
  ## Assumes s3 bucket and dynamo DB table already set up
  ## See /code/03-basics/aws-backend
#  backend "s3" {
#    bucket         = "terraformstate-bucket-aminundakun" # REPLACE WITH YOUR BUCKET NAME
#    key            = "terraform-state-file/project/terraform.tfstate"
#    region         = "us-east-2"
#    dynamodb_table = "terraform-state-locking"
#    encrypt        = true
#  }
#
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}