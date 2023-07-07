This is a program for NODE + MySQL development code.

After installing the Docker packages, we need to use the following command to create the image and container.

_Run as Db container_

Create the db container

```bash
docker run --name db -e MYSQL_ROOT_PASSWORD=Password -e MYSQL_DBNAME=januo -e MYSQL_USER=januo -e MYSQL_PASSWORD=januo -d mysql
```

To establish connectivity from Node.js, we need to pass certain parameters as environment variables, as shown below.

Based on the DB container, I set the variable as follows.

```bash
export MYSQL_HOSTNAME="db"
export MYSQL_DBNAME="januo"
export MYSQL_USERNAME="januo"
export MYSQL_PASSWORD="januo"
export NODE_PORT=3000
```

_Run a node container_

After installing the Docker packages, we need to use the following command to create the image and container.

```bash
docker build -t node-mysql-app .
docker run -it -d  -e MYSQL_HOSTNAME=db -e MYSQL_DBNAME=januo -e MYSQL_USERNAME=januo -e MYSQL_PASSWORD=januo -e ODE_PORT=3000 -p 3000:3000 --name node-app node-mysql-app
```

_URL Access_

```bash
curl http://node-address:3000
```