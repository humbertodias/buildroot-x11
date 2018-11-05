FROM debian:stretch

RUN	DEBIAN_FRONTEND=noninteractive \
    apt update -y && \
	apt install -y git build-essential wget unzip time file cpio python bc rsync

RUN echo "alias ll='ls -lha --color' > /etc/profile"
