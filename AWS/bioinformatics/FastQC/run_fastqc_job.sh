#!/usr/bin/env bash
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
AWSID=$(aws sts get-caller-identity --output text --query 'Account')

INPUT_FILEPATH="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FILEPATH="s3://your-report-bucket/sample_name/"

template=`cat "fastqc.yaml" | sed -e "s/\${AWSID}/$AWSID/g" -e "s/\${REGION}/$REGION/g" -e "s/\${INPUT_FILEPATH}/$INPUT_FILEPATH/g" -e "s/\${OUTPUT_FILEPATH}/$OUTPUT_FILEPATH/g"`
echo "$template" | kubectl apply -f -
