

```yml
image: ubuntu
pipelines:
  default:
    - step:
        services:
          - docker
        script:
          - apt update -qq && apt install sshpass -y -qq
          - echo "$dockerpassword" | docker login -u "$dockerusername" --password-stdin        
          - docker build -t $dockerusername/node-server:latest -f source/backend/Dockerfile source/backend/
          - docker push $dockerusername/node-server:latest
          - docker build -t $dockerusername/web-server:latest -f source/frontend/Dockerfile source/frontend/
          - docker push $dockerusername/web-server:latest
          - docker logout
          - sshpass -p $sshpassword ssh -o StrictHostKeyChecking=no $username@$ipaddress 'bash custom.sh'
definitions:
  services:
    docker:
      memory: 2048
```
