

```yml
---
stages:
  - build
  - deploy

assume:role:
  stage: build
  variables:
    JOB_VAR: "A job variable"
  image:
    name: amazon/aws-cli
    entrypoint: [""]
  script:
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role-with-web-identity
      --role-arn arn:aws:iam::676487226531:role/dev-web-console-identity
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token $CI_JOB_JWT_V2
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))
    - echo "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" >> build.env
    - echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}">> build.env
    - echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> build.env
    - cat build.env
    - aws sts get-caller-identity
  artifacts:
    reports:
      dotenv: build.env

docker:build:
  image: docker:latest
  needs: [assume:role]
  stage: build
  services:
    - docker:dind
  before_script:
    - echo "$DOCKER_PASSWORD"  | docker login --username $DOCKER_USERNAME --password-stdin
  script:
    - docker build --pull -t "$DOCKER_USERNAME/nodejs-api:${CI_COMMIT_SHORT_SHA}" .
    - docker push "$DOCKER_USERNAME/nodejs-api:${CI_COMMIT_SHORT_SHA}"
    - apk update -qy && apk add --no-cache curl unzip bash
    - apk add --no-cache python3 && python3 -m ensurepip &&  rm -r /usr/lib/python*/ensurepip && pip3 install --upgrade pip setuptools && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && rm -r /root/.cache
    - pip3 install awscli
    - $(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
  dependencies:
    - assume:role
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
  after_script:
    - docker logout

deploy-to-uat-ecs:
  stage: deploy
  variables:
    CI_AWS_ECS_TASK_DEFINITION: "A job variable"
    ECR_REGISTRY: "A job variable"
    ECR_REPOSITORY: "A job variable"
    CI_AWS_ECS_CLUSTER:
    CI_AWS_ECS_SERVICE:
    ROLE_NAME: "arn:aws:iam::676487226531:role/dev-web-console-identity"
  image:
    name: amazon/aws-cli
    entrypoint: [""]
  script:
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role-with-web-identity
      --role-arn ${ROLE_NAME}
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token $CI_JOB_JWT_V2
      --duration-seconds 600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))
    - aws ecs describe-task-definition --task-definition $CI_AWS_ECS_TASK_DEFINITION --output json --query taskDefinition > task-definition.json
    - python3 replace-container-defn-img.py task-definition.json $ECR_REGISTRY/$ECR_REPOSITORY:latest
    - aws ecs register-task-definition --cli-input-json file://task-definition.json
    - aws ecs update-service --cluster $CI_AWS_ECS_CLUSTER  --service $CI_AWS_ECS_SERVICE --task-definition $CI_AWS_ECS_TASK_DEFINITION  --force-new-deployment

deploy-to-prod-ecs:
  stage: deploy
  variables:
    CI_AWS_ECS_TASK_DEFINITION: "A job variable"
    ECR_REGISTRY: "A job variable"
    ECR_REPOSITORY: "A job variable"
    CI_AWS_ECS_CLUSTER:
    CI_AWS_ECS_SERVICE:
  image:
    name: amazon/aws-cli
    entrypoint: [""]
  script:
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role-with-web-identity
      --role-arn arn:aws:iam::676487226531:role/dev-web-console-identity
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token $CI_JOB_JWT_V2
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))
    - aws ecs describe-task-definition --task-definition $CI_AWS_ECS_TASK_DEFINITION --output json --query taskDefinition > task-definition.json
    - python scripts/replace-container-defn-img.py task-definition.json $ECR_REGISTRY/$ECR_REPOSITORY:latest
    - aws ecs register-task-definition --cli-input-json file://task-definition.json
    - aws ecs update-service --cluster $CI_AWS_ECS_CLUSTER  --service $CI_AWS_ECS_SERVICE --task-definition $CI_AWS_ECS_TASK_DEFINITION  --force-new-deployment

```
