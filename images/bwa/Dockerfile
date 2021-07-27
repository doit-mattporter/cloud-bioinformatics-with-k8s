ARG aws_region

# Install s5cmd
FROM golang:alpine as s5cmdbuild
RUN apk add --no-cache git make
RUN git clone https://github.com/peak/s5cmd && \
    cd s5cmd && \
    make build

FROM alpine:latest
ENV aws_region_var=${aws_region}
COPY --from=s5cmdbuild /go/s5cmd/s5cmd /usr/bin/

# Set us-west-2 as the default for s5cmd
RUN mkdir -p ~/.aws
RUN echo "[default]" >> ~/.aws/config
RUN echo "region = ${aws_region_var}" >> ~/.aws/config

# Install depenedencies for downstream tools
RUN apk --no-cache add bzip2 bzip2-dev curl-dev git gcc g++ libbz2 make ncurses-dev wget xz-dev zlib-dev

# Install bwa
RUN cd /tmp/ && \
    git clone https://github.com/lh3/bwa.git && \
    cd bwa && \
    make && \
    mv bwa /usr/bin/ && \
    chmod +x /usr/bin/bwa

# Install samtools
RUN cd /tmp/ && \
    wget -nv https://github.com/samtools/samtools/releases/download/1.13/samtools-1.13.tar.bz2 && \
    tar -xf samtools-1.13.tar.bz2 && \
    cd samtools-1.13 && \
    ./configure && \
    make && \
    make install && \
    make clean

# Run alignment command
RUN echo $'#/bin/sh\n\
cores=$(nproc --all)\n\
echo "fastq_pair=${fastq_pair}"\n\
echo "reference=${reference}"\n\
echo "bam_filename=${bam_filename}"\n\
echo "output_path=${output_path}"\n\
echo "cores=${cores}"\n\
s5cmd cp -c ${cores} "${fastq_pair}" .\n\
s5cmd cp -c ${cores} "${reference}" .\n\
echo "bwa mem -t ${cores} -K 100000000 -Y $(basename ${reference%\*}) $(basename ${fastq_pair}) | samtools sort -l9 -m1G -@${cores} -O bam -o ${bam_filename} && s5cmd cp -c ${cores} ${bam_filename} ${output_path}"\n\
bwa mem -t ${cores} -K 100000000 -Y $(basename ${reference%\*}) $(basename ${fastq_pair}) | samtools sort -l9 -m1G -@${cores} -O bam -o ${bam_filename} && s5cmd cp -c ${cores} ${bam_filename} ${output_path}\n'\
    > /usr/bin/align_fastq.sh && \
    chmod +x /usr/bin/align_fastq.sh

RUN apk --purge del git g++ make wget

RUN rm -rf /var/cache/apk/*

RUN rm -rf /tmp/*

ENTRYPOINT ["/bin/sh"]
CMD ["/usr/bin/align_fastq.sh"]
