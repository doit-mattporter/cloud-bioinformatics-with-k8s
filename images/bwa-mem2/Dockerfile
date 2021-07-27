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

# Install bwa-mem2
RUN cd /tmp/ && \
    wget -nv https://github.com/bwa-mem2/bwa-mem2/releases/download/v2.2.1/Source_code_including_submodules.tar.gz && \
    tar -zxf Source_code_including_submodules.tar.gz && \
    cd bwa-mem2-2.2.1 && \
    make && \
    mv bwa-mem2 /usr/bin/

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
echo "FASTQPair=${FASTQPair}"\n\
echo "reference=${reference}"\n\
echo "BAMFilename=${BAMFilename}"\n\
echo "OutputPath=${OutputPath}"\n\
echo "cores=${cores}"\n\
s5cmd cp -c ${cores} "${FASTQPair}" .\n\
s5cmd cp -c ${cores} "${reference}" .\n\
echo "bwa-mem2 mem -t ${cores} -K 100000000 -Y $(basename ${reference%\*}) $(basename ${FASTQPair}) | samtools sort -l9 -m1G -@${cores} -O bam -o ${BAMFilename} && s5cmd cp -c ${cores} ${BAMFilename} ${OutputPath}"\n\
bwa-mem2 mem -t ${cores} -K 100000000 -Y $(basename ${reference%\*}) $(basename ${FASTQPair}) | samtools sort -l9 -m1G -@${cores} -O bam -o ${BAMFilename} && s5cmd cp -c ${cores} ${BAMFilename} ${OutputPath}\n'\
    > /usr/bin/align_fastq.sh && \
    chmod +x /usr/bin/align_fastq.sh

RUN apk --purge del git g++ make wget

RUN rm -rf /var/cache/apk/*

RUN rm -rf /tmp/*

ENTRYPOINT ["/bin/sh"]
CMD ["/usr/bin/align_fastq.sh"]
