_gitlab-security-template-reference.md_

```yml
---
include:
  - template:  Security/Secret-Detection.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml 
  - template:  Jobs/Code-Quality.gitlab-ci.yml 

stages:
- secret-scan
- sast-scan
- code-quality
- build
- test

secret_detection:
  stage: secret-scan

semgrep-sast:
  stage: sast-scan

nodejs-scan-sast:
  stage: sast-scan

code_quality:
  stage: sast-scan
  

docker-build:
  stage: build
  image: docker:19.03.12
  services:
  - docker:19.03.12-dind
  before_script:
    - echo -n $DOCKER_PASSWORD | docker login -u "$DOCKER_USERNAME" --password-stdin 
  script:
    - docker build -t $DOCKER_USERNAME/api-development:$CI_COMMIT_SHA .
    - docker push $DOCKER_USERNAME/api-development:$CI_COMMIT_SHA
  after_script:
    - docker logout


```
