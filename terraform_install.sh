#!/bin/bash

yum install unzip -y
curl -LO "https://releases.hashicorp.com/terraform/1.5.6/terraform_1.5.6_linux_amd64.zip"
unzip terraform_1.5.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -v
