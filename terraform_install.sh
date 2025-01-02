#!/bin/bash

# 필요한 패키지 설치
yum install -y unzip curl

# HashiCorp에서 최신 Terraform 버전 가져오기
LATEST_VERSION=$(curl -s https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# 최신 버전 다운로드
echo "Downloading Terraform version: $LATEST_VERSION"
curl -LO "https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip"

# 압축 해제 및 실행 파일 이동
unzip terraform_${LATEST_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# 설치된 버전 확인
terraform -v
