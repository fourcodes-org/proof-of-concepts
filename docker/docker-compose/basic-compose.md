```yml
---
version: "3.8"
services:
  webserver:
    image: nginx
    container_name: web-server
    ports:
    - 80:80
  db:
    image: mysql:5.7
    container_name: db-server
    environment:
      MYSQL_ROOT_PASSWORD: "demo"
    ports:
    - 3306:3306

```
