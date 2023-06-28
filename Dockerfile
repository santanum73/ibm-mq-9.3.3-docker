ARG BASE_IMAGE=registry.redhat.io/ubi9/ubi-minimal
ARG BASE_TAG=latest

ARG MQ_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev932_linux_x86-64.tar.gz"

ARG MQ_PACKAGES="ibmmq-server ibmmq-java ibmmq-jre ibmmq-gskit ibmmq-web ibmmq-msg-.*"

FROM ${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer "Santanu Mitra <santanum73@gmail.com>"
LABEL "ProductName"="IBM MQ Advanced for Developers" \
	  "ProductVersion"="9.3.2"

RUN microdnf install yum -y \
	# && yum install dnf -y \
	&& yum update -y \
	&& yum install -y --skip-broken --best \
			bash \ 
			bc \
			ca-certificates \
			coreutils \
			curl \
			file \
			findutils \
			gawk \ 
			grep \
			glibc \
			redhat-lsb-core \
			mount \
			passwd \
			procps \
			sed \
			tar \
			util-linux \
	&& export DIR_EXTRACT=/tmp/mq \
	&& mkdir -p ${DIR_EXTRACT} \
	&& cd ${DIR_EXTRACT} 

ENV LANG=en_US.UTF-8

CMD ["ls -l"]