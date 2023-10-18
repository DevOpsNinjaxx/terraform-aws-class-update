# Uncomment To use default vpc
#data "aws_vpc" "default_vpc" {
#  default = true
#}

# Uncomment To use default subnet
#data "aws_subnet_ids" "default_subnets" {
#  vpc_id = data.aws_vpc.default_vpc.id
#}

# Create a Custom VPC
resource "aws_vpc" "my-custom-vpc" {
  cidr_block = "192.0.0.0/16"
  tags = {
    Name = "my-custom-vpc"
  }
}

resource "aws_subnet" "public-SN" {
  count = 2

  vpc_id            = aws_vpc.my-custom-vpc.id
  cidr_block        = element(["192.0.100.0/24", "192.0.101.0/24"], count.index)
  availability_zone = element(["us-east-2a", "us-east-2b"], count.index)

  tags = {
    Name = "public-SN-${count.index}"
    environment = var.environment_name
  }
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.my-custom-vpc.id

  tags = {
    Name = "internet-gw"
    environment = var.environment_name
  }
}

resource "aws_route_table" "public-RT" {
  count = 2

  vpc_id = aws_vpc.my-custom-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "public-RT-${count.index}"
    environment = var.environment_name
  }
}

resource "aws_route_table_association" "RT-association" {
  count = 2

  subnet_id      = element(aws_subnet.public-SN.*.id, count.index)
  route_table_id = element(aws_route_table.public-RT.*.id, count.index)
}
