ARG aws_region

# Download the AWS CLI
# FROM amazonlinux:2 as awscli
# RUN yum update && \
#     yum install -y unzip && \
#     curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
#     unzip awscliv2.zip && \
#     ./aws/install

# Download s5cmd
FROM alpine:latest as s5cmd
RUN wget https://github.com/peak/s5cmd/releases/download/v1.3.0/s5cmd_1.3.0_Linux-64bit.tar.gz -O /tmp/s5cmd.tar.gz && \
    tar -zxvf /tmp/s5cmd.tar.gz -C /bin/

# Download FastQC
FROM alpine:latest AS fastqc
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip -O /tmp/fastqc.zip && \
    unzip /tmp/fastqc.zip -d / && \
    chmod +x /FastQC/fastqc

# Create FastQC image
FROM amazonlinux:2
# COPY --from=awscli /usr/local/aws-cli/v2/2.2.25/dist/ /usr/local/aws-cli/
ENV aws_region_var=${aws_region}
COPY --from=s5cmd /bin/s5cmd /usr/local/bin/
COPY --from=fastqc /FastQC/ /usr/local/FastQC/

# Set us-west-2 as the default for s5cmd
RUN mkdir -p ~/.aws
RUN echo "[default]" >> ~/.aws/config
RUN echo "region = ${aws_region_var}" >> ~/.aws/config

# Install FastQC dependencies
RUN yum update -y && \
    yum install -y java-1.8.0-openjdk perl dejavu-sans-fonts zip

# Run FastQC command
RUN echo $'#!/bin/sh\n\
    echo "FASTQ=${FASTQ}"\n\
    echo "OUTPUT_PATH=${OUTPUT_PATH}"\n\
    mkdir -p /data/tmp/\n\
    s5cmd cp "$FASTQ" /data/tmp/\n\
    fastqc /data/tmp/$(basename $FASTQ)\n\
    rm -f /data/tmp/$(basename $FASTQ)\n\
    zip -9 /data/$(basename ${FASTQ%.fastq.gz}).zip /data/tmp/$(basename ${FASTQ%.fastq.gz})*\n\
    s5cmd cp "/data/$(basename ${FASTQ%.fastq.gz}).zip" ${OUTPUT_PATH%/}/\n' \
    > /usr/bin/create_fastqc_report.sh && \
    chmod +x /usr/bin/create_fastqc_report.sh

ENV DISPLAY :0.0

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV PATH="/usr/local/FastQC/:${PATH}"
# ENV PATH="/usr/local/aws-cli/:${PATH}"

CMD ["/usr/bin/create_fastqc_report.sh"]

# Run with:
# AWSID=$(aws sts get-caller-identity --output text --query 'Account')
# FASTQ=s3://fastq-bucket/file.fastq
# OUTPUT_PATH=s3://output-report-bucket/
# docker run -e FASTQ -e OUTPUT_PATH -v /root/:/data/ $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest