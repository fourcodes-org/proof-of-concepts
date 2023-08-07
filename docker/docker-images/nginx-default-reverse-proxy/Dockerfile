FROM ubuntu:latest
RUN apt update 
RUN apt upgrade -y
RUN apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY default etc/nginx/sites-enabled/default
EXPOSE 80
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /var/log/nginx/error.log 
CMD ["nginx", "-g", "daemon off;"]
