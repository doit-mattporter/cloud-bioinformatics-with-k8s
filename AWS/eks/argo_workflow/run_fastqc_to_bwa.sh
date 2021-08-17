#!/usr/bin/env bash

# FastQC: Define input and output filepaths
INPUT_FILEPATH="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FILEPATH="s3://your-report-bucket/sample_name/"

# BWA-MEM2: Define input and output filepaths
FASTQ_R1_PATH="s3://your-fastq-bucket/your_fastq_R1.fastq.gz"
FASTQ_R2_PATH="s3://your-fastq-bucket/your_fastq_R2.fastq.gz"
REFERENCE_PATH="s3://your-reference-bucket/bwa_reference_prefix" # For example, s3://bucket/hg38
BAM_FN="your_fastq.bam"
OUTPUT_PATH="s3://your-alignment-bucket/BAMs/"
CORES="95"

# Install jq
# sudo apt-get install jq

# Authenticate kubectl with EKS cluster
aws eks update-kubeconfig --name bioinformatics-tasks

# Replace variables in FastQC job and launch job
# Region determination works on EC2, Cloudshell, and local dev env
TOKEN=`curl -m 3 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
REGION=`curl -m 3 -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`
if [ -z "$REGION" ]
then
  REGION=$AWS_DEFAULT_REGION
fi
if [ -z "$REGION" ]
then
  REGION=`aws configure get region`
fi
AWSID=$(aws sts get-caller-identity --output text --query 'Account')

rm -f fastqc_to_bwa_substitution.yaml*
cp fastqc_to_bwa.yaml fastqc_to_bwa_substitution.yaml
sed -i .bak -e "s|\\\${AWSID}|${AWSID}|g" \
            -e "s|\\\${REGION}|${REGION}|g" \
            -e "s|\\\${INPUT_FILEPATH}|${INPUT_FILEPATH}|g" \
            -e "s|\\\${OUTPUT_FILEPATH}|${OUTPUT_FILEPATH}|g" \
            -e "s|\\\${FASTQ_R1_PATH}|${FASTQ_R1_PATH}|g" \
            -e "s|\\\${FASTQ_R2_PATH}|${FASTQ_R2_PATH}|g" \
            -e "s|\\\${REFERENCE_PATH}|${REFERENCE_PATH}|g" \
            -e "s|\\\${BAM_FN}|${BAM_FN}|g" \
            -e "s|\\\${OUTPUT_PATH}|${OUTPUT_PATH}|g" \
            -e "s|\\\${CORES}|${CORES}|g" \
            fastqc_to_bwa_substitution.yaml
cat fastqc_to_bwa_substitution.yaml
kubectl create -f fastqc_to_bwa_substitution.yaml
rm -f fastqc_to_bwa_substitution.yaml*

# VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-darwin-amd64