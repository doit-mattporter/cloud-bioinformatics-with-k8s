#!/usr/bin/env bash

# Define input and output filepaths
INPUT_FILEPATH="s3://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FILEPATH="s3://your-report-bucket/sample_name/"

# Install jq
# sudo apt-get install jq

# Authenticate kubectl with EKS cluster
# Region and project determination works on GCE, Cloud Shell, and local dev env
GCP_ZONE=`curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -f4 -d'/'`
GCP_REGION=${GCP_ZONE::-2}
if [ -z "$GCP_REGION" ]
then
  GCP_REGION=`gcloud config get-value compute/region`
fi
GCP_PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
gcloud container clusters get-credentials bioinformatics-tasks --region $GCP_REGION

# Replace variables in FastQC job and launch job

rm -f fastqc_substitution.yaml*
cp fastqc.yaml fastqc_substitution.yaml
sed -i.bak -e "s|\\\${GCP_PROJECT_ID}|${GCP_PROJECT_ID}|g" \
           -e "s|\\\${INPUT_FILEPATH}|${INPUT_FILEPATH}|g" \
           -e "s|\\\${OUTPUT_FILEPATH}|${OUTPUT_FILEPATH}|g" \
           fastqc_substitution.yaml
kubectl create -f fastqc_substitution.yaml
rm -f fastqc_substitution.yaml*
