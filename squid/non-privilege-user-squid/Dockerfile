FROM ubuntu:latest

RUN apt update && apt upgrade -y && apt install -y squid

COPY squid.conf /etc/squid/squid.conf

RUN groupadd -r squid && useradd -r -g squid squid

RUN ln -sf /dev/stdout /var/log/squid/access.log

RUN chown -R squid:squid /run

USER squid

EXPOSE 3128

ENTRYPOINT ["squid", "-N", "-d", "1"]
