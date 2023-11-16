ERROR 1
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/8bda759d-370e-4a9e-b74a-7a12f43ec0b1)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/30ae65e1-d72b-4f44-9d7a-e968d3e9a0ce)
**Solution**
- We need to verify that the Docker packages properly installed. if it is **properly not installed** we need to follow the below steps.. if it is **installed properly**. we can go ahead the below after [or] steps

```bash
# update the OS
sudo apt-get update
# install the package

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# public key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# docker-compose 
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# docker permission
sudo groupadd docker
sudo usermod -aG docker $USER

# docker-compose permission
sudo chmod 666 /var/run/docker.sock

# versions
docker -v
docker-compose -v
```
[or]

```sh
- sudo chmod 664 /var/run/docker.sock
```
---
ERROR 2
-------
When try to launch mysql docker container. it says some error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/2c4e7ffe-b290-4e76-b4e1-3d491d6451a2)
**Solution**
```bash
ss -tulpn | grep 3306
sudo systemctl stop mysql
```
---
ERROR 3
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/753e85cd-3644-4880-9995-562eeaa5fd28)
**Solution**
```bash
1. Check the network connectivity for local
2. In case if we are using instance, check the igw connection and outbound rules too.
```
---
ERROR 4
-------
When we try to get a reponse in nodejs from webserver. we will get this error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e3582edd-19f4-4022-9720-ce21d4f30bd6)
**Solution**
```bash
1. We have to check the nodejs code running or not. In case not running, we need to run that code. after that we have to use `curl -l (app-server-ip-address):(nodeport)` command from the webserver.

example:
in app(node) server,
`node index.js` or 'nodemon index.js`
```
---
ERROR 5
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/097b7d0a-c83b-43b1-bab8-97d422b12e0f)





