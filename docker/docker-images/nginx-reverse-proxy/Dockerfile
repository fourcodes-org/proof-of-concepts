FROM ubuntu:latest
RUN apt update && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY reverse-proxy.conf /etc/nginx/sites-enabled/januo.io.conf

RUN ln -sf /dev/stdout /var/log/nginx/janu.io.access.log \
        && ln -sf /var/log/nginx/janu.io.error.log 
        
CMD ["nginx", "-g", "daemon off;"]
