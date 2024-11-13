provider "aws" {
  region = var.region
}

# 키 페어 생성
resource "aws_key_pair" "main" {
  key_name   = "web-key"
  public_key = file(var.ssh_public_key_path)
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# 퍼블릭 서브넷
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# 프라이빗 서브넷
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-internet-gateway"
  }
}

# NAT 게이트웨이
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "main-nat-gateway"
  }
}

resource "aws_eip" "main" {
  vpc = true
  tags = {
    Name = "main-eip"
  }
}

# 로드 밸런서 생성
resource "aws_alb" "main" {
  name            = "web-alb"
  security_groups = [aws_security_group.web_sg.id]
  subnets         = aws_subnet.public[*].id
  tags = {
    Name = "web-alb"
  }
}

# Auto Scaling 그룹 추가
resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = var.autoscaling_min_size
  max_size             = var.autoscaling_max_size
  vpc_zone_identifier  = aws_subnet.public[*].id
  tags = [
    {
      key                 = "Name"
      value               = "web-instance"
      propagate_at_launch = true
    }
  ]
}

resource "aws_launch_configuration" "web_lc" {
  name          = "web-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.main.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}

# RDS 데이터베이스 생성
resource "aws_db_instance" "main" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydatabase"
  username             = var.db_username
  password             = var.db_password
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  tags = {
    Name = "main-database"
  }
}