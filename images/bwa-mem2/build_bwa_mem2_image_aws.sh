#!/usr/bin/env bash

# Build BWA Docker image

# Install pre-requisites
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker $USER
sudo newgrp docker
sudo yum -y install jq

# Region determination works on EC2, Cloudshell, and local dev env
TOKEN=`curl -m 3 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AWS_REGION=$(curl -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
if [ -z "$AWS_REGION" ]
then
  AWS_REGION=$AWS_DEFAULT_REGION
fi
if [ -z "$AWS_REGION" ]
then
  AWS_REGION=`aws configure get region`
fi
AWSID=$(aws sts get-caller-identity --output text --query 'Account')

# Build and push image to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWSID.dkr.ecr.$AWS_REGION.amazonaws.com
docker build \
    --build-arg aws_region=$AWS_AWS_REGION \
    -t $AWSID.dkr.ecr.$AWS_REGION.amazonaws.com/bwa-mem2:2.2.1_x86 \
    -t $AWSID.dkr.ecr.$AWS_REGION.amazonaws.com/bwa-mem2:latest \
    .
docker push $AWSID.dkr.ecr.$AWS_REGION.amazonaws.com/bwa-mem2 --all-tags
# Note: 2.80X faster on c5.24xlarge with a large WGS dataset when bwa-mem2 is used vs. bwa. 11h33m50s bwa-mem2 vs. 32h19m13s bwa-mem runtime

# Run with:
# AWSID=$(aws sts get-caller-identity --output text --query 'Account')
# AWS_REGION=your-region-2
# fastq_r1_path=s3://fastq-bucket/fastq_r1.fastq
# fastq_r2_path=s3://fastq-bucket/fastq_r2.fastq
# reference_path=s3://your-reference-bucket/bwa_reference_prefix
# bam_filename=desired_filename.bam
# output_path=s3://output-report-bucket/BAMs/
# cores=$(nproc --all)
# docker run -e $fastq_r1_path \
#     -e $fastq_r2_path \
#     -e $reference_path \
#     -e $bam_filename \
#     -e $output_path \
#     -e $cores \
#     -v /root/:/data/ \
#     $AWSID.dkr.ecr.$AWS_REGION.amazonaws.com/bwa-mem2:latest