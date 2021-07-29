#!/usr/bin/env bash

# Authenticate kubectl with EKS cluster
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
aws eks update-kubeconfig --name bioinformatics-tasks

# Replace variables in FastQC job and launch job
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
AWSID=$(aws sts get-caller-identity --output text --query 'Account')

INPUT_FILEPATH="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FILEPATH="s3://your-report-bucket/sample_name/"

cp fastqc.yaml fastqc_substitution.yaml
sed -i -e "s|\\\${AWSID}|${AWSID}|g" -e "s|\\\${REGION}|${REGION}|g" -e "s|\\\${INPUT_FILEPATH}|${INPUT_FILEPATH}|g" -e "s|\\\${OUTPUT_FILEPATH}|${OUTPUT_FILEPATH}|g" fastqc_substitution.yaml
cat fastqc_substitution.yaml
kubectl apply -f fastqc_substitution.yaml
rm -f fastqc_substitution.yaml
