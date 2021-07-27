FROM amazonlinux:2 as awscli
RUN yum update -y && \
    yum install -y unzip && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /aws-cli-bin/

FROM alpine:latest AS fastqc
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip -O /tmp/fastqc.zip && \
    unzip /tmp/fastqc.zip -d /FastQC-bin/ && \
    chmod 777 /FastQC-bin/FastQC/fastqc

FROM amazonlinux:2
# Install AWS CLI v2 and FastQC binaries
#COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=awscli /aws-cli-bin/ /usr/local/bin/
COPY --from=fastqc /FastQC-bin/ /opt/

# Install FastQC dependencies
RUN yum update -y && \
    yum install -y java-1.8.0-openjdk perl dejavu-sans-fonts zip

ENV DISPLAY :0.0

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

ENV PATH="/opt/FastQC/:${PATH}"

# Run with:
# AWSID=$(aws sts get-caller-identity --output text --query 'Account')
# FASTQ=s3://fastq-bucket/file.fastq
# OUTPUT_S3=s3://output-report-bucket/
# docker run -e FASTQ -e OUTPUT_S3 -v /root/:/data/ $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest /bin/bash -c "mkdir -p /data/tmp/ && aws s3 cp $FASTQ /data/tmp/ && fastqc /data/tmp/$(basename $FASTQ) && rm -f /data/tmp/$(basename $FASTQ) && zip -9 /data/$(basename ${FASTQ%.fastq.gz}).zip /data/tmp/$(basename ${FASTQ%.fastq.gz})* && aws s3 cp /data/$(basename ${FASTQ%.fastq.gz}).zip $OUTPUT_S3/"

CMD ["/bin/bash"]