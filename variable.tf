variable "region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"  # 서울 리전
}

variable "instance_type" {
  description = "웹 및 애플리케이션 서버의 인스턴스 타입"
  type        = string
  default     = "t2.micro"  # 무료 티어 적용 가능
}

variable "key_name" {
  description = "EC2 인스턴스에 사용할 키 페어 이름"
  type        = string
}

variable "db_instance_type" {
  description = "RDS DB 인스턴스 타입"
  type        = string
  default     = "db.t2.micro"  # 무료 티어 적용 가능
}

variable "vpc_id" {
  description = "사용할 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "서브넷 ID 목록"
  type        = list(string)
}