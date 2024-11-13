#!/bin/bash

cat <<EOF > terraform.tfvars
region = "ap-northeast-2"
db_username = "sungbin"
db_password = "sungbin"
autoscaling_min_size = 1
autoscaling_max_size = 4
ssh_public_key_path = "~/.ssh/id_rsa.pub"
EOF