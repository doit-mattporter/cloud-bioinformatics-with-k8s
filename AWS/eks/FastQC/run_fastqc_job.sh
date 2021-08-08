#!/usr/bin/env bash

# Define input and output filepaths
INPUT_FILEPATH="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FILEPATH="s3://your-report-bucket/sample_name/"

# Install jq
# sudo apt-get install jq

# Authenticate kubectl with EKS cluster
aws eks update-kubeconfig --name bioinformatics-tasks

# Replace variables in FastQC job and launch job
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

rm -f fastqc_substitution.yaml
cp fastqc.yaml fastqc_substitution.yaml
sed -i -e "s|\\\${AWSID}|${AWSID}|g" -e "s|\\\${REGION}|${REGION}|g" -e "s|\\\${INPUT_FILEPATH}|${INPUT_FILEPATH}|g" -e "s|\\\${OUTPUT_FILEPATH}|${OUTPUT_FILEPATH}|g" fastqc_substitution.yaml
kubectl create -f fastqc_substitution.yaml
rm -f fastqc_substitution.yaml
