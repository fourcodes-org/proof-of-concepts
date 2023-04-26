_Docker installation on ubuntu_
---

_**Setup the repository**_

```bash
  sudo apt-get update
  sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
```
_**Add Docker’s official GPG key**_

```bash
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg \
      --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
_**set up the stable repository**_

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

_**Install Docker Engine**_

```bash
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

_**Start the Docker**_

```bash
sudo systemctl start docker
```

**Stop the Docker**

```bash
sudo systemctl stop docker
```
**Status of the Docker**

```bash
sudo systemctl status docker
```


**Restart the Docker**

```bash
sudo systemctl restart docker
```

**Enable the Docker**
```bash
sudo systemctl enable docker
```
**Add the users into Docker group**

```bash
sudo usermod -aG docker $USER

#reboot the system
```

_docker compose installation_

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod +x docker-compose 
sudo mv docker-compose /usr/local/bin/

```


