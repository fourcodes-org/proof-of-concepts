## docker-compose file for lamp stack

```yml
version: '3.8'


services:


 php-apache-environment:
container_name: php-apache
image: php:7.4-apache
volumes:
  - ./php/src:/var/www/html/
ports:
  - 8080:80
  db:
image: mysql
command: --default-authentication-plugin=mysql_native_password
container_name: mysql
environment:
  MYSQL_ROOT_PASSWORD: admin
  MYSQL_DATABASE: ezapi
  MYSQL_USER: root
  MYSQL_PASSWORD: password
ports:
  - "6033:3306"
volumes:
  - dbdata:/var/lib/mysql


phpmyadmin:
image: phpmyadmin/phpmyadmin
container_name: phpmyadmin
links:
  - mysql
environment:
  PMA_HOST: mysql
  PMA_PORT: 3306
  PMA_ARBITRARY: 1
restart: always
ports:
  - 8081:80
volumes:


 dbdata:
 ```
 
 ```docker
sudo docker-compose up
 ```
