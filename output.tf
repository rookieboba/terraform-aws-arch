output "alb_dns_name" {
  description = "로드 밸런서의 DNS 이름"
  value       = aws_lb.my_alb.dns_name
}

output "web_server_ips" {
  description = "웹 서버의 공인 IP 주소"
  value       = aws_instance.web_server[*].public_ip
}

output "db_endpoint" {
  description = "RDS 인스턴스의 엔드포인트"
  value       = aws_db_instance.my_db.endpoint
}
