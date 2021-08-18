#!/usr/bin/env bash

# Build FastQC Docker image on CentOS 8

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
    -t us.gcr.io/$GCP_PROJECT_ID/fastqc:0.11.9_x86 \
    -t us.gcr.io/$GCP_PROJECT_ID/fastqc:latest \
    .
docker push us.gcr.io/$GCP_PROJECT_ID/fastqc --all-tags
