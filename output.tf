output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "The public subnets in the VPC"
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "The private subnets in the VPC"
}

output "rds_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "The endpoint of the RDS instance"
}

output "autoscaling_group_name" {
  value       = aws_autoscaling_group.web_asg.name
  description = "The name of the Auto Scaling Group"
}

output "key_pair_name" {
  value       = aws_key_pair.main.key_name
  description = "The name of the key pair used for EC2 instances"
}