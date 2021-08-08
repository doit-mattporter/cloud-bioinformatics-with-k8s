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

# Create BWA-MEM2 image
FROM alpine:latest
# COPY --from=awscli /usr/local/aws-cli/v2/2.2.25/dist/ /usr/local/aws-cli/
ENV aws_region_var=${aws_region}
COPY --from=s5cmd /bin/s5cmd /usr/local/bin/

# Set us-west-2 as the default for s5cmd
RUN mkdir -p ~/.aws
RUN echo "[default]" >> ~/.aws/config
RUN echo "region = ${aws_region_var}" >> ~/.aws/config

# Install depenedencies for BWA and samtools
RUN apk --no-cache add bzip2 bzip2-dev curl-dev git gcc g++ libbz2 make ncurses-dev wget xz-dev zlib-dev

# Install bwa-mem2
RUN cd /tmp/ && \
    wget https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/Source_code_including_submodules.tar.gz -O /tmp/bwa-mem2.tar.gz && \
    tar -xf bwa-mem2.tar.gz && \
    cd bwa-mem2-2.2.1 && \
    make && \
    mv bwa-mem2* /usr/bin/

# Install samtools
RUN cd /tmp/ && \
    wget https://github.com/samtools/samtools/releases/download/1.13/samtools-1.13.tar.bz2 -O /tmp/samtools.tar.bz2 && \
    tar -xf samtools.tar.bz2 && \
    cd samtools-1.13 && \
    ./configure && \
    make && \
    make install && \
    make clean

# Run alignment command
RUN echo $'#!/bin/sh\n\
    echo "fastq_r1_path=${fastq_r1_path}"\n\
    echo "fastq_r2_path=${fastq_r2_path}"\n\
    echo "reference_path=${reference_path}"\n\
    echo "bam_fn=${bam_fn}"\n\
    echo "output_path=${output_path}"\n\
    echo "cores=${cores}"\n\
    mkdir -p /data/tmp/fastq/\n\
    mkdir -p /data/tmp/reference/\n\
    mkdir -p /data/tmp/bam/\n\
    s5cmd cp -c ${cores} "${fastq_r1_path}" /data/tmp/fastq/\n\
    s5cmd cp -c ${cores} "${fastq_r2_path}" /data/tmp/fastq/\n\
    s5cmd cp -c ${cores} "${reference_path%\*}*" /data/tmp/reference/\n\
    echo "bwa-mem2 mem -t ${cores} -K 100000000 -Y /data/tmp/reference/$(basename ${reference_path%\*}) /data/tmp/fastq/$(basename ${fastq_r1_path}) /data/tmp/fastq/$(basename ${fastq_r2_path}) | samtools sort -l9 -m1G -@${cores} -O bam -o /data/tmp/bam/${bam_fn} && s5cmd cp -c ${cores} \"/data/tmp/bam/${bam_fn}\" ${output_path}"\n\
    bwa-mem2 mem -t ${cores} -K 100000000 -Y /data/tmp/reference/$(basename ${reference_path%\*}) /data/tmp/fastq/$(basename ${fastq_r1_path}) /data/tmp/fastq/$(basename ${fastq_r2_path}) | samtools sort -l9 -m1G -@${cores} -O bam -o /data/tmp/bam/${bam_fn} && s5cmd cp -c ${cores} \"/data/tmp/bam/${bam_fn}\" ${output_path}\n' \
    > /usr/bin/align_fastq.sh && \
    chmod +x /usr/bin/align_fastq.sh

RUN apk --purge del git g++ make wget

RUN rm -rf /var/cache/apk/*

RUN rm -rf /tmp/*

CMD ["/usr/bin/align_fastq.sh"]

# Run with:
# AWSID=$(aws sts get-caller-identity --output text --query 'Account')
# FASTQ=s3://fastq-bucket/file.fastq
# OUTPUT_S3=s3://output-alignment-bucket/
# docker run -e FASTQ -e OUTPUT_S3 -v /root/:/data/ $AWSID.dkr.ecr.$REGION.amazonaws.com/fastqc:latest /bin/bash -c "mkdir -p /data/tmp/; aws s3 cp $FASTQ /data/tmp/; fastqc /data/tmp/$(basename $FASTQ); rm -f /data/tmp/$(basename $FASTQ); zip -9 /data/$(basename ${FASTQ%.fastq.gz}).zip /data/tmp/$(basename ${FASTQ%.fastq.gz})*; aws s3 cp /data/$(basename ${FASTQ%.fastq.gz}).zip ${OUTPUT_S3%/}/"
