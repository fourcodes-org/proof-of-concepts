FROM ubuntu:latest
RUN apt update && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY reverse-proxy-configuration.conf /etc/nginx/sites-enabled/januo.io.conf
CMD ["nginx", "-g", "daemon off;"]
