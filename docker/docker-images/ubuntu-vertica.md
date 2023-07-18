_ubuntu-vertica_

```Dockerfile
FROM ubuntu:latest
RUN apt update && apt install apache2 python2 vim -y
RUN apt install python-pip -y
RUN pip2 install vertica-python
CMD ["apachectl","-D","FOREGROUND"]
```
