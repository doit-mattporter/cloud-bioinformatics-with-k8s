# cloud-bioinformatics-with-k8s

## A Complete Demo of Global-Scale Scientific Computing in the Cloud with Kubernetes and Terraform

Provided within this repo is a full working demo of a scientific computing (bioinformatics) workflow (FastQC to BWA-MEM2) executed on a fully-managed, auto-scaling Kubernetes cluster spun up by Terraform-created infrastructure. The demo is intended to showcase global-scale scientific computing infrastructure and development best practices. It can be run on both AWS and GCP; ideally you should use a new AWS account or GCP project to avoid the potential for interfering with existing resources.

Linked below is the blog post accompanying this code base. The article first guides you along as you learn various modern DevOps principles and the tools that enable those principles which are used in this demo. It then showcases how various components of the code base make use of these tools and how to execute them.

https://blog.doit-intl.com/bioinformatics-in-the-cloud-with-kubernetes-and-terraform-6ac743b48eb6