variable "region" {
  type    = string
  default = "us-east-2"
}

variable "ami" {
  type    = string
  default = "ami-0430580de6244e02e"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "db_name" {
  type    = string
  default = "mydb"
}

variable "db_identfier" {
  type    = string
  default = "my-web-app-db"
}

variable "db_instanceclass" {
  type    = string
  default = "db.t2.micro"
}

variable "db_user" {
  type    = string
  default = "admin"
}

#Uncomment to use 

#variable "db_pass" {
#  type = string
#  sensitive = true
#}

variable "bucket" {
  type = string
  default = "aminundakun-web-app-bucket"
}

variable "app_name" {
  type = string
  default = "web-app"
}

variable "environment_name" {
  type = string
   default = "development"
}
