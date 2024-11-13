#!/bin/bash

read -p "Enter AWS region (default: ap-northeast-2): " region
region=${region:-ap-northeast-2}

read -p "Enter DB username (default: sungbin): " db_username
db_username=${db_username:-sungbin}

read -p "Enter DB password (default: sungbin): " db_password
db_password=${db_password:-sungbin}

read -p "Enter SSH public key path (default: ~/.ssh/id_rsa.pub): " ssh_public_key_path
ssh_public_key_path=${ssh_public_key_path:-~/.ssh/id_rsa.pub}

cat <<EOF > terraform.tfvars
region = "$region"
db_username = "$db_username"
db_password = "$db_password"
ssh_public_key_path = "$ssh_public_key_path"
autoscaling_min_size = 1
autoscaling_max_size = 4
EOF
