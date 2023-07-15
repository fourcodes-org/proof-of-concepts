**Docker build and push to ECR**

__Requirements__

* awscli

Configure the AWS credentials by running the following command:

```bash
aws configure
```

To retrieve an authentication token and authenticate your Docker client to your registry, use the AWS CLI:

```bash
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 676487226531.dkr.ecr.ap-southeast-1.amazonaws.com
```

Note: If you encounter an error while using the AWS CLI, ensure that you have the latest versions of both the AWS CLI and Docker installed.

Build your Docker image using the following command. If your image is already built, you can skip this step:

```bash
docker build -t operation-unknown .
```

After the build is complete, tag your image so that you can push it to the repository:

```bash
docker tag operation-unknown:latest 676487226531.dkr.ecr.ap-southeast-1.amazonaws.com/operation-unknown:latest
```

To push the image to your newly created AWS repository, run the following command:

```bash
docker push 676487226531.dkr.ecr.ap-southeast-1.amazonaws.com/operation-unknown:latest
```
