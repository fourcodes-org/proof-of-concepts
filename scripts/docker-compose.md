## Docker Compose
```bash
#!/usr/bin/env bash
VERSION=v2.9.0
echo -e "\e[1;31mUpdate the system!"
sudo apt update
sudo apt install curl -y
echo -e "\e[1;31mInstall the compose CLI plugin!"
sudo curl -SL "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
echo -e "\e[1;31mApply executable permissions"
sudo chmod +x /usr/local/bin/docker-compose
echo -e "\e[1;31mdocker version"
docker-compose version
```

[docker-compose-download-reference](https://github.com/docker/compose/releases)
