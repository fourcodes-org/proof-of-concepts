#### docker-run-command.md
---

To pull images to dockerhub use this command

```bash
docker pull imagename
```

To check install images use this
```bash
docker images
```
lists all the docker containers
```bash
docker ps 
docker ps -a
```

to check version
```bash
docker --version
```

To run the container
```bash
docker run -it -d imagename
```

To enter inside the containes use this
```bash
docker exec -it containerID bash
```
how to find container down reason using command 

```bash
docker logs containerID
```
To remove container 
```bash
docker rm -f containerID or Name
```

To remove Images
```bash 
docker rmi imageame
```
Docker running commands
```bash 
docker Start container name
docker restart container name
docker Stop Container name
docker kill container name
```

To login
```bash
docker login
```

To create volume
```bash
docker volume create volume name
```
```bash
Docker volume ls
```

To inspect 
```bash
docker  inspect (contaier or volume)name
```

To find nerwork
```bash
docker network ls
docker network
```
