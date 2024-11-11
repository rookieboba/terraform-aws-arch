# 키 페어, VPC ID, 서브넷 ID 가져오기
KEY_NAME=$(aws ec2 describe-key-pairs --query "KeyPairs[0].KeyName" --output text)
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --query "Subnets[*].SubnetId" --output text | sed 's/ /", "/g')

# tfvars 파일에 저장
echo "key_name = \"$KEY_NAME\"" > terraform.tfvars
echo "vpc_id = \"$VPC_ID\"" >> terraform.tfvars
echo "subnet_ids = [\"$SUBNET_IDS\"]" >> terraform.tfvars
