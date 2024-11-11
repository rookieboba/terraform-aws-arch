provider "aws" {
  region = var.region
}

# 로드 밸런서 생성
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
}

# 웹 서버 EC2 인스턴스 생성
resource "aws_instance" "web_server" {
  count         = 2
  ami           = "ami-0abcdef1234567890"  # AWS 무료 티어에서 사용 가능한 AMI ID
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_ids[0]
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# RDS 데이터베이스 생성 (무료 티어)
resource "aws_db_instance" "my_db" {
  allocated_storage    = 20  # 무료 티어 최소 스토리지
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"  # 무료 티어 호환 버전
  instance_class       = var.db_instance_type
  name                 = "mydatabase"
  username             = "admin"
  password             = "password"  # 실제로는 Terraform Vault나 다른 보안 방법 사용 권장
  parameter_group_name = "default.mysql5.7"
  multi_az             = false  # 무료 티어에서는 단일 AZ만 지원
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_ids           = var.subnet_ids
}
