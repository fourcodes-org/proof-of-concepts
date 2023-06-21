_nginx reverse proxy with ssl offloading_

This folder contains two files. One is called `Dockerfile`, while the other is `reverse-proxy.conf`.

By default, it is pointed to `api.github.com`. If you want to modify the backend service, you can replace the configuration, build the Docker image, and run it. 

![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/84d1ea3e-7116-47d8-a97f-39da8cc0eca5)

_docker commands_

```bash
docker build -t nginx-reverse-proxy-with-ssl .
docker run -d -p 80:80 -p 443:443 --name nginx-reverse-proxy-with-ssl nginx-reverse-proxy-with-ssl
docker logs nginx-reverse-proxy
```
