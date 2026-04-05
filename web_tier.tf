# Step 7: Web tier instances + ALB
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "web_server_az1" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.web_public_az1.id
  vpc_security_group_ids      = [aws_security_group.web_tier.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server 1 - AZ1</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.tags, {
    Name = "web-server-1"
    Tier = "web"
  })
}

resource "aws_instance" "web_server_az2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.web_public_az2.id
  vpc_security_group_ids      = [aws_security_group.web_tier.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server 2 - AZ2</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.tags, {
    Name = "web-server-2"
    Tier = "web"
  })
}

resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_tier.id]
  subnets            = [aws_subnet.web_public_az1.id, aws_subnet.web_public_az2.id]

  tags = merge(var.tags, {
    Name = "web-alb"
  })
}

resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = merge(var.tags, {
    Name = "web-tg"
  })
}

resource "aws_lb_target_group_attachment" "web_server_az1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_server_az1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_az2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web_server_az2.id
  port             = 80
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
