#!/usr/bin/env bash

# Build FastQC Docker image

# Install pre-requisites
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo newgrp docker
sudo yum -y install jq

# Region determination works on EC2, Cloudshell, and local dev env
TOKEN=`curl -m 3 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(curl -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
if [ -z "$REGION" ]
then
  REGION=$AWS_DEFAULT_REGION
fi
if [ -z "$REGION" ]
then
  REGION=`aws configure get region`
fi
AWSID=$(aws sts get-caller-identity --output text --query 'Account')

# Build and push image to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWSID.dkr.ecr.$REGION.amazonaws.com
# docker build -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:0.11.9_x86 -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest .
docker build --build-arg region=$REGION \
    -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:0.11.9_x86 \
    -t $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest .
docker push $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc --all-tags
