FROM jjino/ez-gut-squid:latest
RUN apt update
RUN apt-get install curl wget net-tools iputils-ping -y
COPY squid.conf /etc/squid/squid.conf
