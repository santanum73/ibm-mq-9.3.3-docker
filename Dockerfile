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
COPY image/9.3.3.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz /tmp/mq/.
# COPY IBM-MQ.repo /tmp/mq/.
	# && curl -LO $MQ_URL \
RUN export DIR_EXTRACT=/tmp/mq \
    && cd ${DIR_EXTRACT} \
	&& tar -zxvf ./*.tar.gz \
	&& yum autoremove -y \
	# Recommended: Create the mqm user ID with a fixed UID and group, so that the file permissions work between different images
	&& groupadd --system --gid 990 mqm \
	&& useradd --system --uid 990 --gid mqm mqm \
	&& usermod -G mqm root \
	# Find directory containing .rpm files
	&& export DIR_RPM=$(find ${DIR_EXTRACT} -name "*.rpm" -printf "%h\n" | sort -u | head -1) \
    && export DIR_REPO=$(find ${DIR_RPM} -name "IBM-MQ.repo" -printf "%h\n" | sort -u | head -1) \
	# Find location of mqlicense.sh
	&& export MQLICENSE=$(find ${DIR_EXTRACT} -name "mqlicense.sh") \
	# Accept the MQ license
	&& ${MQLICENSE} -text_only -accept \
	&& sed -i 's|var/tmp/MQServer.*|tmp/mq/MQServer|g' $DIR_REPO/IBM-MQ.repo \
	&& cat $DIR_REPO/IBM-MQ.repo \
	&& cp $DIR_REPO/IBM-MQ.repo /etc/yum.repos.d/IBM-MQ.repo \
	&& ls -l /etc/yum.repos.d/IBM-MQ.repo \
	&& pwd \
	&& yum -y update \
	&& yum -y install MQSeries* \
	&& /opt/mqm/bin/setmqinst -i -p /opt/mqm \
    # Remove 32-bit libraries from 64-bit container
    && find /opt/mqm /var/mqm -type f -exec file {} \; \
        | awk -F: '/ELF 32-bit/{print $1}' | xargs --no-run-if-empty rm -f \
    # Remove tar.gz files unpacked by RPM postinst scripts
	&& find /opt/mqm -name '*.tar.gz' -delete \
    # Clean up all the downloaded files
	&& rm -rf ${DIR_EXTRACT} \
    # Optional: Update the command prompt with the MQ version
	&& echo "mq:$(dspmqver -b -f 2)" > /etc/debian_chroot \
    && rm -rf /var/mqm
	
COPY scripts/*.sh /usr/local/bin/
COPY scripts/*.mqsc /etc/mqm/
COPY scripts/mq-dev-config /etc/mqm/mq-dev-config

RUN chmod +x /usr/local/bin/*.sh

EXPOSE 1414 9443 9157

ENV LANG=en_US.UTF-8

ENTRYPOINT ["mq.sh"]