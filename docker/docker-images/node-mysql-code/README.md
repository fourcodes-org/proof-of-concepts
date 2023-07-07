DB name should be created as per mentioned below,
```bash
# Database Name
testing

note:
------
table name don't need to create. it will create automatically. already we configured to the code.
```

After creating the DB, we have to follow the below steps,
```sh
# install the packages
npm i

# establish the connectivity
node index.js
```

Docker commands - after installing the docker packages we have to use the below command for creating the image and container
```sh
# Build image
docker build -t (imageName) .

# container creation
docker run -it -d -p 3000:3000 --name (containerName) (imageName)

# run the container
docker exec -it (containerNAme) /bin/bash
```
After establish the connectivity , we have to refer details in the  url - https://github.com/januo-org/proof-of-concepts/blob/main/aws/docs/application-deployment-demo.md
