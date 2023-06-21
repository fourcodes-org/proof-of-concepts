FROM ubuntu:latest
RUN apt update && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY reverse-proxy.conf /etc/nginx/sites-enabled/januo.io.conf
RUN mkdir -p /etc/nginx/janui.io.certificates
COPY certificate/ /etc/nginx/janui.io.certificates
RUN ln -sf /dev/stdout /var/log/nginx/janu.io.access.log \
        && ln -sf /var/log/nginx/janu.io.error.log 
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
