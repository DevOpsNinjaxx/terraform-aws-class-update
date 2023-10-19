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

#Uncomment to use RDS password in module
#variable "db_pass" {
#  type      = string
#  sensitive = true
#}


#Uncomment to manage workspaces
locals {
  environment_name = terraform.workspace
}


#locals {
#  environment_name = var.environment_name
#}


provider "aws" {
  region = var.region
}

module "web_app" {
  source = "../web-app-module"

  # Input Variables
  bucket           = "aminundakun-web-app-bucket-${local.environment_name}"
  db_identfier     = "web-app-db-${local.environment_name}"
  app_name         = "web-app-${local.environment_name}"
  environment_name = local.environment_name
  instance_type    = "t2.micro"
  db_name          = "webappdb-${local.environment_name}"
  db_user          = "foo"
#  db_pass          = var.db_pass             #uncomment to use RDS password in module
  ami              = "ami-0430580de6244e02e"
}