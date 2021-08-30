#!/usr/bin/env bash

# Define input and output filepaths
fastq_r1_path="gs://your-fastq-bucket/your_fastq_R1.fastq.gz"
fastq_r2_path="gs://your-fastq-bucket/your_fastq_R2.fastq.gz"
reference_path="gs://your-reference-bucket/bwa_reference_prefix" # For example, gs://bucket/hg38
bam_fn="your_fastq.bam"
output_path="gs://your-alignment-bucket/BAMs/"
cores=32

# Authenticate kubectl with EKS cluster
aws eks update-kubeconfig --name bioinformatics-tasks

# Replace variables in BWA-MEM2 job and launch job
# Region and project determination works on GCE, Cloud Shell, and local dev env
GCP_ZONE=`curl http://metadata.google.internal/computeMetadata/v1/instance/zone -H Metadata-Flavor:Google | cut -f4 -d'/'`
GCP_REGION=${GCP_ZONE::-2}
if [ -z "$GCP_REGION" ]
then
  GCP_REGION=`gcloud config get-value compute/region`
fi
GCP_PROJECT_ID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
gcloud container clusters get-credentials bioinformatics-tasks --region $GCP_REGION

# To generate hg38 BWA-MEM2 reference, run the following:
# docker run -it --entrypoint=/bin/sh us.gcr.io/$GCP_PROJECT_ID/bwa-mem2
# s5cmd cp s3://broad-references/hg38/v0/Homo_sapiens_assembly38.fasta /tmp/reference/
# cd /tmp/reference/
# bwa-mem2 index -p hg38 /tmp/reference/Homo_sapiens_assembly38.fasta
# s5cmd cp "/tmp/reference/hg38*" gs://your-reference-bucket/hg38/

rm -f bwa-mem2_substitution.yaml*
cp bwa-mem2.yaml bwa-mem2_substitution.yaml
sed -i.bak -e "s|\\\${GCP_PROJECT_ID}|${GCP_PROJECT_ID}|g" \
           -e "s|\\\${fastq_r1_path}|${fastq_r1_path}|g" \
           -e "s|\\\${fastq_r2_path}|${fastq_r2_path}|g" \
           -e "s|\\\${reference_path}|${reference_path}|g" \
           -e "s|\\\${bam_fn}|${bam_fn}|g" \
           -e "s|\\\${output_path}|${output_path}|g" \
           -e "s|\\\${cores}|${cores}|g" \
           bwa-mem2_substitution.yaml
kubectl create -f bwa-mem2_substitution.yaml
rm -f bwa-mem2_substitution.yaml*
