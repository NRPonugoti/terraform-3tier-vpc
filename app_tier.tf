# Step 8: App tier instances in private subnets
resource "aws_instance" "app_server_az1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app_private_az1.id
  vpc_security_group_ids = [aws_security_group.app_tier.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-17-amazon-corretto
              EOF

  tags = merge(var.tags, {
    Name = "app-server-1"
    Tier = "app"
  })
}

resource "aws_instance" "app_server_az2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app_private_az2.id
  vpc_security_group_ids = [aws_security_group.app_tier.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-17-amazon-corretto
              EOF

  tags = merge(var.tags, {
    Name = "app-server-2"
    Tier = "app"
  })
}
