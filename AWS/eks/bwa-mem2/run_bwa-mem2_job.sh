#!/usr/bin/env bash

# Define input and output filepaths
fastq_r1_path="s3://your-fastq-bucket/your_fastq_R1.fastq.gz"
fastq_r2_path="s3://your-fastq-bucket/your_fastq_R2.fastq.gz"
reference_path="s3://your-reference-bucket/bwa_reference_prefix" # For example, s3://bucket/hg38
bam_fn="your_fastq.bam"
output_path="s3://your-alignment-bucket/BAMs/"
cores=32

# Install jq
# sudo apt-get install jq

# Authenticate kubectl with EKS cluster
aws eks update-kubeconfig --name bioinformatics-tasks

# Replace variables in BWA-MEM2 job and launch job
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

# To generate hg38 BWA-MEM2 reference, run the following:
# docker run -it --entrypoint=/bin/sh $AWSID.dkr.ecr.$REGION.amazonaws.com/bwa-mem2:latest
# s5cmd cp s3://broad-references/hg38/v0/Homo_sapiens_assembly38.fasta /tmp/reference/
# cd /tmp/reference/
# bwa-mem2 index -p hg38 /tmp/reference/Homo_sapiens_assembly38.fasta
# s5cmd cp "/tmp/reference/hg38*" s3://your-reference-bucket/hg38/

rm -f bwa-mem2_substitution.yaml*
cp bwa-mem2.yaml bwa-mem2_substitution.yaml
sed -i.bak -e "s|\\\${AWSID}|${AWSID}|g" \
           -e "s|\\\${REGION}|${REGION}|g" \
           -e "s|\\\${fastq_r1_path}|${fastq_r1_path}|g" \
           -e "s|\\\${fastq_r2_path}|${fastq_r2_path}|g" \
           -e "s|\\\${reference_path}|${reference_path}|g" \
           -e "s|\\\${bam_fn}|${bam_fn}|g" \
           -e "s|\\\${output_path}|${output_path}|g" \
           -e "s|\\\${cores}|${cores}|g" \
           bwa-mem2_substitution.yaml
kubectl create -f bwa-mem2_substitution.yaml
rm -f bwa-mem2_substitution.yaml*
