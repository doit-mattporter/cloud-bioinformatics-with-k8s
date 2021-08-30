#!/usr/bin/env bash

# FastQC: Define input and output filepaths
INPUT_FASTQ_R1="gs://your-fastq-bucket/fastq_filepath.fastq.gz"
INPUT_FASTQ_R2="gs://your-fastq-bucket/fastq_filepath.fastq.gz"
OUTPUT_FASTQC_PATH="gs://your-report-bucket/sample_name/"

# BWA-MEM2: Define input and output filepaths
REFERENCE_PATH="gs://your-reference-bucket/bwa_reference_prefix" # For example, gs://bucket/hg38
BAM_FN="your_fastq.bam"
OUTPUT_BAM_PATH="gs://your-alignment-bucket/BAMs/"
CORES="94"

# Replace variables in FastQC job and launch job
# Region and project determination works on GCE, Cloud Shell, and local dev env
GCP_ZONE=`curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -f4 -d'/'`
GCP_REGION=${GCP_ZONE::-2}
if [ -z "$GCP_REGION" ]
then
  GCP_REGION=`gcloud config get-value compute/region`
fi
GCP_PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
gcloud container clusters get-credentials bioinformatics-tasks --region $GCP_REGION


rm -f fastqc_to_bwa_substitution.yaml*
cp fastqc_to_bwa.yaml fastqc_to_bwa_substitution.yaml
sed -i.bak -e "s|\\\${GCP_PROJECT_ID}|${GCP_PROJECT_ID}|g" \
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