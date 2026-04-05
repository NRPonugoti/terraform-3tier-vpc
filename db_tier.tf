# Step 9: Database tier (RDS in isolated private subnets)
resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.db_private_az1.id, aws_subnet.db_private_az2.id]

  tags = merge(var.tags, {
    Name = "db-subnet-group"
  })
}

resource "aws_db_instance" "main" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp3"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_tier.id]
  username               = var.db_username
  password               = var.db_password
  port                   = var.db_port
  publicly_accessible    = false
  multi_az               = var.db_multi_az
  apply_immediately      = true
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = merge(var.tags, {
    Name = var.db_identifier
  })
}
