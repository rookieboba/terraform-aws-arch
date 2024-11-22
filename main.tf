provider "aws" {
  region = var.region
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# 퍼블릭 서브넷
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# 프라이빗 서브넷
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "private-subnet"
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
  subnet_id     = aws_subnet.public.id
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

# Web Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "web-sg"
  }
}

# 수정 사항: web_sg를 사용하려는 모든 리소스에서 참조가 제대로 연결되지 않아 생기는 에러를 수정함.
# 기존 코드에서 선언되지 않은 `aws_security_group.web_sg`를 선언하여 참조 가능하도록 수정함.

# 로드 밸런서
resource "aws_alb" "main" {
  name            = "web-alb"
  security_groups = [aws_security_group.web_sg.id] # 수정: 선언된 web_sg 참조 추가
  subnets         = [aws_subnet.public.id]

  tags = {
    Name = "web-alb"
  }
}

# Auto Scaling 그룹
resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = var.autoscaling_min_size
  max_size             = var.autoscaling_max_size
  vpc_zone_identifier  = [aws_subnet.public.id]
  tags = [
    {
      key                 = "Name"
      value               = "web-instance"
      propagate_at_launch = true
    }
  ]
}

# Launch Configuration
resource "aws_launch_configuration" "web_lc" {
  name          = "web-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_sg.id] # 수정: 선언된 web_sg 참조 추가
  key_name      = "web-key"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # 수정: 선언된 web_sg 참조 추가
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# RDS 데이터베이스
resource "aws_db_instance" "main" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydatabase"
  username             = var.db_username
  password             = var.db_password
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.db_sg.id] # 수정: 선언된 db_sg 참조 추가
  db_subnet_group_name = aws_db_subnet_group.main.name
  tags = {
    Name = "main-database"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
  tags = {
    Name = "main-db-subnet-group"
  }
}
