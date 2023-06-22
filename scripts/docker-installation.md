## Installing docker with shell script 

```bash
#!/usr/bin/env bash
# docker-installation.sh
PACKAGE=docker-ce
PACKAGE_STATUS=$(dpkg --get-selections ${PACKAGE} 2>&1 | grep 'install' | awk '{ print $2 }')

if [ install != "${PACKAGE_STATUS}" ]; then
    echo -e "\e[1;31m${PACKAGE} is not installed."
    sudo apt-get update
    sudo apt install curl -y
    sudo apt-get install ca-certificates curl gnupg lsb-release -y
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt update -y
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
else
    echo -e "\e[1;31m${PACKAGE} is already installed "
fi
```

**_bash run command_**

```bash
bash docker-installation.sh
```
