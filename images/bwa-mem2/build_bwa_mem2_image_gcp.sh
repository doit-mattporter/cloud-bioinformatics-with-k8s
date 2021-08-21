#!/usr/bin/env bash

# Build BWA Docker image on CentOS 8

# Install pre-requisites
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce docker-ce-cli containerd.io
sudo service docker start
sudo usermod -a -G docker $USER
sudo newgrp docker
sudo yum -y install jq

# Region determination works on GCE, Cloud Shell, and local dev env
GCP_ZONE=`curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -f4 -d'/'`
GCP_REGION=${GCP_ZONE::-2}
if [ -z "$GCP_REGION" ]
then
  GCP_REGION=`gcloud config get-value compute/region`
fi
GCP_PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`

# Build and push image to ECR
# Manually authenticate and configure Docker to use GCR
gcloud auth login
gcloud auth configure-docker

docker build \
    --build-arg gcp_region=$GCP_REGION \
    -t us.gcr.io/$GCP_PROJECT_ID/bwa-mem2:2.2.1_x86 \
    -t us.gcr.io/$GCP_PROJECT_ID/bwa-mem2:latest \
    .
docker push us.gcr.io/$GCP_PROJECT_ID/bwa-mem2 --all-tags
# Note: 2.80X faster on c5.24xlarge with a large WGS dataset when bwa-mem2 is used vs. bwa. 11h33m50s bwa-mem2 vs. 32h19m13s bwa-mem runtime

# Run with:
# AWSID=$(aws sts get-caller-identity --output text --query 'Account')
# GCP_REGION=your-region-2
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
#     $AWSID.dkr.ecr.$GCP_REGION.amazonaws.com/bwa-mem2:latest