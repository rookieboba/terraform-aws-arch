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

# Auto Scaling Launch Template
resource "aws_launch_template" "web_server_template" {
  name_prefix   = "web-server-template"
  image_id      = "ami-0abcdef1234567890"  # 실제 사용 가능한 AMI ID 입력
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_ids[0]
    security_groups             = [aws_security_group.web_sg.id]
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_server_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.web_server_template.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tags = [
    {
      key                 = "Name"
      value               = "web-server"
      propagate_at_launch = true
    }
  ]
}

# RDS 데이터베이스 생성
resource "aws_db_instance" "my_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.db_instance_type
  name                 = "mydatabase"
  username             = "admin"
  password             = "password"  # 실제로는 Terraform Vault나 다른 보안 방법 사용 권장
  parameter_group_name = "default.mysql5.7"
  multi_az             = false  # 무료 티어에서 단일 AZ만 지원
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_ids           = var.subnet_ids
}