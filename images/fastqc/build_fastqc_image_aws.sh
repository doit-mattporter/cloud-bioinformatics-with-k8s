#!/usr/bin/env bash

# Build FastQC Docker image
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo newgrp docker
sudo yum -y install jq
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
AWSID=$(aws sts get-caller-identity --output text --query 'Account')
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWSID.dkr.ecr.$REGION.amazonaws.com
docker build -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:0.11.9_x86 -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest .
docker push $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc --all-tags
