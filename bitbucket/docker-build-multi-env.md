


```yml
image: node
pipelines:
  branches:
    main:
      - step:
          name: "dev deployment"
          script:
          - echo "dev image pre steps"
      - step:
          name: "docker build and push"
          trigger: manual
          script:
          - ENVIRONMENT="dev"
          - IMAGE_NAME="jjino/wdc:node-$ENVIRONMENT-$BITBUCKET_BUILD_NUMBER"
          - echo "${IMAGE_NAME}"
          - docker build -t $IMAGE_NAME .
          - echo $DOCKER_TOKEN | docker login --username $DOCKER_USERNAME --password-stdin
          - docker push $IMAGE_NAME
          services:
            - docker
      - step:
          name: "dev deployment"
          trigger: manual
          script:
            - apt update && apt install openssh-client -y
            - mkdir -p ~/.ssh
            - (umask  077 ; echo $SSH_KEY | base64 --decode > ~/.ssh/id_rsa)
            - ssh -o "StrictHostKeyChecking=no" ubuntu@35.172.236.123 "bash /home/ubuntu/scripts/backend-node.sh"
```
