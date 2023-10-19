resource "aws_key_pair" "ssh_key" {
  key_name   = "SSH-KEY-${var.environment_name}"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "web-server-SG" {
  name        = "web-server-SG-${var.environment_name}"
  description = "Allow inbound traffic on port 80"
  vpc_id      = aws_vpc.my-custom-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-SG-${var.environment_name}"
    environment = var.environment_name
  }
}

resource "aws_security_group" "loadbalancer-SG" {
  name        = "loadbalancer-SG-${var.environment_name}"
  description = "Allow inbound traffic to loadbalancer"
  vpc_id      = aws_vpc.my-custom-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer-SG${var.environment_name}"
    environment = var.environment_name
  }
}

resource "aws_instance" "web_server" {
  count                       = 2
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = element(aws_subnet.public-SN.*.id, count.index)
  key_name                    = aws_key_pair.ssh_key.key_name
  security_groups             = [aws_security_group.web-server-SG.id]
  user_data                   = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 sudo bash -c 'echo "<h1>Terraform Website</h1> from" $(hostname -f) > /var/www/html/index.html'
                 EOF

  tags = {
    Name = "web-server-${count.index}-${var.environment_name}"
    environment = var.environment_name
  }
  depends_on = [
    aws_key_pair.ssh_key
  ]
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lb" "web-app-loadbalancer" {
  name               = "${var.environment_name}-web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer-SG.id]
  subnets            = [element(aws_subnet.public-SN.*.id, 0), element(aws_subnet.public-SN.*.id, 1)]

  tags = {
    Environment = var.environment_name
  }
}

resource "aws_lb_target_group" "web-app-loadbalancer-TG" {
  name     = "lb-TG-${var.app_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-custom-vpc.id
  tags = {
    Name = "lb-TG-${var.app_name}"
    environment = var.environment_name
  }
}

resource "aws_lb_target_group_attachment" "TG-attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.web-app-loadbalancer-TG.arn
  target_id        = element(aws_instance.web_server.*.id, count.index)
  port             = 80
}

resource "aws_lb_listener" "loadbalancer-listener" {
  load_balancer_arn = aws_lb.web-app-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.loadbalancer-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-loadbalancer-TG.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
