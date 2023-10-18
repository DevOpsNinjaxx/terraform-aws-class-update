terraform {
  ## Assumes s3 bucket and dynamo DB table already set up
  ## See /code/03-basics/aws-backend
  backend "s3" {
    bucket         = "terraformstate-bucket-aminundakun" # REPLACE WITH YOUR BUCKET NAME
    key            = "terraform-state-file/project-modules/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "db_pass" {
  type      = string
  sensitive = true
}


provider "aws" {
  region = var.region
}

module "web_app_1" {
  source = "../web-app-module"

  # Input Variables
  bucket           = "prod-app-data-aminundakun"
  db_identfier     = "prod-web-app-db"
  app_name         = "prod-app"
  environment_name = "production"
  instance_type    = "t3.micro"
  db_name          = "prod-webappdb"
  db_user          = "foo"
#  db_pass          = var.db_pass
  ami              = "ami-0430580de6244e02e"
}
