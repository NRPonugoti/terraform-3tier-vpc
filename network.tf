data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az1 = data.aws_availability_zones.available.names[0]
  az2 = data.aws_availability_zones.available.names[1]
}

# Step 1: Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "my-3tier-vpc"
  })
}

# Step 2: Create six subnets (2 per tier)
resource "aws_subnet" "web_public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "web-public-subnet-az1"
    Tier = "web"
  })
}

resource "aws_subnet" "web_public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az2
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "web-public-subnet-az2"
    Tier = "web"
  })
}

resource "aws_subnet" "app_private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.az1

  tags = merge(var.tags, {
    Name = "app-private-subnet-az1"
    Tier = "app"
  })
}

resource "aws_subnet" "app_private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = local.az2

  tags = merge(var.tags, {
    Name = "app-private-subnet-az2"
    Tier = "app"
  })
}

resource "aws_subnet" "db_private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = local.az1

  tags = merge(var.tags, {
    Name = "db-private-subnet-az1"
    Tier = "db"
  })
}

resource "aws_subnet" "db_private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = local.az2

  tags = merge(var.tags, {
    Name = "db-private-subnet-az2"
    Tier = "db"
  })
}

# Step 3: Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "my-3tier-igw"
  })
}

# Step 4: NAT Gateway + Elastic IP (in public subnet)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "my-3tier-nat-eip"
  })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_public_az1.id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(var.tags, {
    Name = "my-3tier-nat"
  })
}

# Step 5: Route tables and subnet associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "public-rt"
  })
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "app-private-rt"
  })
}

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "db-private-rt"
  })
}

resource "aws_route_table_association" "web_public_az1" {
  subnet_id      = aws_subnet.web_public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web_public_az2" {
  subnet_id      = aws_subnet.web_public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app_private_az1" {
  subnet_id      = aws_subnet.app_private_az1.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "app_private_az2" {
  subnet_id      = aws_subnet.app_private_az2.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "db_private_az1" {
  subnet_id      = aws_subnet.db_private_az1.id
  route_table_id = aws_route_table.db_private.id
}

resource "aws_route_table_association" "db_private_az2" {
  subnet_id      = aws_subnet.db_private_az2.id
  route_table_id = aws_route_table.db_private.id
}
