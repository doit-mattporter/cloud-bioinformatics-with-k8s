#!/usr/bin/env bash

# FastQC: Define input and output filepaths
INPUT_FASTQ_R1="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
INPUT_FASTQ_R2="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FASTQC_PATH="s3://your-report-bucket/sample_name/"

# BWA-MEM2: Define input and output filepaths
REFERENCE_PATH="s3://your-reference-bucket/bwa_reference_prefix" # For example, s3://bucket/hg38
BAM_FN="your_fastq.bam"
OUTPUT_BAM_PATH="s3://your-alignment-bucket/BAMs/"
CORES="94"

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
sed -i.bak -e "s|\\\${AWSID}|${AWSID}|g" \
            -e "s|\\\${REGION}|${REGION}|g" \
            -e "s|\\\${INPUT_FASTQ_R1}|${INPUT_FASTQ_R1}|g" \
            -e "s|\\\${INPUT_FASTQ_R2}|${INPUT_FASTQ_R2}|g" \
            -e "s|\\\${OUTPUT_FASTQC_PATH}|${OUTPUT_FASTQC_PATH}|g" \
            -e "s|\\\${REFERENCE_PATH}|${REFERENCE_PATH}|g" \
            -e "s|\\\${BAM_FN}|${BAM_FN}|g" \
            -e "s|\\\${OUTPUT_BAM_PATH}|${OUTPUT_BAM_PATH}|g" \
            -e "s|\\\${CORES}|${CORES}|g" \
            fastqc_to_bwa_substitution.yaml
cat fastqc_to_bwa_substitution.yaml
kubectl create -f fastqc_to_bwa_substitution.yaml
rm -f fastqc_to_bwa_substitution.yaml*

# VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-darwin-amd64