#Uncomment to provision RDS

#resource "aws_db_instance" "web-app-db" {
#  allocated_storage    = 10
#  name                 = "var.db_name"
#  engine               = "mysql"
#  engine_version       = "5.7"
#  identifier           = var.db_identfier
#  instance_class       = var.db_instanceclass
#  username             = var.db_user
#  password             = var.db_pass
#  parameter_group_name = "default.mysql5.7"
#  skip_final_snapshot  = true
#}
