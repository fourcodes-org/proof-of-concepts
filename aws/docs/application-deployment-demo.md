Infra
-----
`VPC CONCEPT`
- 1 VPC
- 3 subent
    - 1 public
    - 2 private
- 3 route table
    - 1 public-RT
    - 2 private-RT (each separate)
- 1 IGW
- 1 NAT Gateway
--------
`SECURITY GROUP`
- 3 security group (each separate)
--------------
`EC2 INSTANCE`
- web server
- app server (or) node server
- db server
-------------
WORK FLOW:
----
`VPC`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a5b55117-bdb7-4a89-8d5c-6f9927a9db4a)

`3 SUBNET`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/55112194-7997-49c5-877e-30019aabd4c2)

`INTERNET GATEWAY(IGW)`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/4a75eae7-81a5-4dbf-8692-12e5c8032053)

`NAT GATEWAY(NAT)`
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e9d25fab-db26-4359-ad3f-d3c5ec9468e9)

`ROUTE TABLE(RT)`

**Public-RT**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/41ed22bc-a752-48d3-8a0d-31ab9b6430ca)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/f84e6599-bb58-40d0-a666-8bf87f1d646b)

**Private-RT-01**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/678ac1ce-7c5f-49b2-8117-889184408a88)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/ad95f83f-4dab-4b6d-9a02-64e8274d3bfa)

**Private-RT-02** - WITHOUT NETWORK
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/67779d97-4173-40a9-b6a4-350a000caa68)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/ad6a6582-b028-469d-98e7-8e8812778da1)
```bash
1. In this infra, Private-RT-02 does not require network.
2. in case if we need a network, we need to associate the private2(subnet3) ip in Private-RT-01 route table. after 
we used the network we need remove the private2(subnet3) ip from Private-RT-01 and associate thePrivate-RT-02 RT.
```
`EC2 INSTANCE`
---
**3. db-server**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/5a612442-d642-44f0-89e9-ba0244cd1660)

Install the packages for the below,

**Manual Method in db server**
```sh
# Install the mysql package
sudo apt install mysql-server -y

# Check the Status of MySql (Active or Inactive)
sudo systemctl status mysql

# Login to MySql as a root
sudo mysql

# when you are try to connect from other host you must create a user like this
CREATE USER 'joe'@'%' IDENTIFIED WITH mysql_native_password BY 'Password@123';

#  grant all privileges to the user
GRANT ALL PRIVILEGES ON *.* TO 'joe'@'%';

# grant the privileges
FLUSH PRIVILEGES;

# create the database
CREATE DATABASE testing;
```
**Enable MySQL Server Remote Connection in Ubuntu**

`sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf`

![Image](https://github.com/januo-org/proof-of-concepts/assets/91359308/c6863fef-e614-4358-95f1-3ad60d4a4e51)

```sh
sudo systemctl restart mysql

# we should check the binded mysql remote connection
sudo netstat -tulpn | grep mysql
```

**Note:**
https://www.configserverfirewall.com/ubuntu-linux/enable-mysql-remote-access-ubuntu/#:~:text=To%20enable%20remote%20connections%20to%20the%20MySQL%20Server%2C,the%20%5Bmysqld%5D%20Locate%20the%20Line%2C%20bind-address%20%3D%20127.0.0.1

**db-server-SG**
Inbound rule
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/4c98997c-2aa7-4e55-90fd-f11df51779f8)
Outbound rule
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/71ff554e-9ed1-471e-adbe-f168e001e180)

Mathod 2 - Docker method
-------
```bash
# create the container
docker run --name db -e MYSQL_ROOT_PASSWORD=. -e MYSQL_DATABASE=testing -e MYSQL_USER=joe -e MYSQL_PASSWORD=Password@123 --network=host -d  mysql:5.7

# login to the joe use
sudo mysql -u joe -p

#  grant all privileges to the user
GRANT ALL PRIVILEGES ON *.* TO 'joe'@'%';

# grant the privileges
FLUSH PRIVILEGES;

# create the database
CREATE DATABASE testing;
```

**2. app-server(nodeserver)**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/10a0bd39-389f-44e1-adbd-e0d68351c37b)

Method 1 - Manual Method
---------

`sudo vim node.sh`
```sh
#!/usr/bin/env bash
sudo su -
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node

# check the node versions
node -v
npm -v

# Install Git 
sudo apt update -y
sudo apt install git -y
git --version

# clone repository from GitHub
git clone https://github.com/dodonotdo/demo_testing.git
cd demo_testing
npm install
```
**run the above script**
`bash node.sh`
```bash
# in app server, we should check the connection between db server
telnet (dbserver Private instance ip address) 3306
```
**app-server-SG**

Inbound Rule
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/28678069-1d9d-4034-8a8c-f58fc99e2654)
Outbound Rule
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/cbc596b3-6480-4637-a92c-bf4c92834018)

**web-server**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e2813c20-6ab5-4c49-b55b-f3aa030ae629)

Method 2 - Docker method in node server
---------------
```bash

# vim Dockerfile
FROM node:alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
CMD ["node", "index.js"]

# build a docker image
docker build -t (imageNAme) .

# run a docker container using docker image
docker run -d -it -p 3000:3000 --name (continerName) (imageNAme)
```

```sh
# create the dir
mkdir nginx-reverse

# switch over the dir
cd nginx-reverse
```

Create the configuration file -  **`vim reverse.conf`**

```sh
server {
listen 80;
server_name (public instance public ip);
location / {
proxy_pass http://(node instance private ip):(nodePort);
}
    access_log           /var/log/nginx/fourtimes.ml.access.log;
    error_log            /var/log/nginx/fourtimes.ml.error.log;
}

```
Create the dockerfile - **`vim Dockerfile`**
```sh
FROM ubuntu:latest
RUN apt update && apt install nginx -y
RUN rm -rf etc/nginx/sites-enabled/default
COPY reverse.conf  /etc/nginx/sites-enabled/januo.io.conf
CMD ["nginx", "-g", "daemon off;"]

```
After creating the docker file, we use the below command

```sh
# build a image
docker build -t reverseproxy-img .

# create a container using the image
docker run -d -it -p 80:80 --name reverse-proxy-con  reverseproxy-img

# check the logs
docker logs (container_name)

# delete all the containers
docker rm -f $(docker ps -a -q)

# delete all the images
docker rmi -f $(docker images -aq)
```
**web-server-SG**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/36a080c8-092e-4ee5-b772-170e558e9ce4)

![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/4211c054-b416-451d-8757-d8479eeb1a96)


**Test the nodejs application from webserver**
`curl -l (app-ip-address:port)`

**After getting the reponse, we need to go for the browser and past it the `public ip`**
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/a9f5ab21-68dc-4bda-b477-55597d24fd39)




