variable "region" {
  description = "AWS Region"
  default     = "ap-northeast-2" # 한국 리전
}

variable "db_username" {
  description = "Database username"
  default     = "sungbin"
}

variable "db_password" {
  description = "Database password"
  default     = "sungbin"
}

variable "autoscaling_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  default     = 1
}

variable "autoscaling_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  default     = 4
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  default     = "~/.ssh/id_rsa.pub"
}