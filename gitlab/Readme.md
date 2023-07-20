

_conditions_

```yml
test:
  tags:
    - dev
  script:
  - echo "It works!"
  - for i in $(seq 1 30); do echo "."; sleep 1; done
```


```yml
dev:
  variables:
    CLUSTER_NAME: damo.k8s.local
    STATE_STORE: s3://awsjinojino
    NODE_COUNT: 2
    NODE_SIZE: t2.large
    MASTER_SIZE: t2.medium
    ZONE_NAME: us-east-1a
  before_script:
    - echo $CLUSTER_NAME
  script:
    - echo $STATE_STORE
  after_script:
    - echo $NODE_COUNT
uat:
  variables:
    CLUSTER_NAME: damo.k8s.local
    STATE_STORE: s3://awsjinojino
    NODE_COUNT: 2
    NODE_SIZE: t2.large
    MASTER_SIZE: t2.medium
    ZONE_NAME: us-east-1a
  before_script:
    - echo $CLUSTER_NAME
  script:
    - echo $STATE_STORE
  after_script:
    - echo $NODE_COUNT
prod:
  variables:
    CLUSTER_NAME: damo.k8s.local
    STATE_STORE: s3://awsjinojino
    NODE_COUNT: 2
    NODE_SIZE: t2.large
    MASTER_SIZE: t2.medium
    ZONE_NAME: us-east-1a
  before_script:
    - echo $CLUSTER_NAME
  script:
    - echo $STATE_STORE
  after_script:
    - echo $NODE_COUNT
```



```yml
stages:
  - build
  - test
  - deploy

image: alpine

build_a:
  stage: build
  script:
    - echo "This job builds something."

build_b:
  stage: build
  script:
    - echo "This job builds something else."

test_a:
  stage: test
  script:
    - echo "This job tests something. It will only run when all jobs in the"
    - echo "build stage are complete."

test_b:
  stage: test
  script:
    - echo "This job tests something else. It will only run when all jobs in the"
    - echo "build stage are complete too. It will start at about the same time as test_a."

deploy_a:
  stage: deploy
  script:
    - echo "This job deploys something. It will only run when all jobs in the"
    - echo "test stage complete."
  environment: production

deploy_b:
  stage: deploy
  script:
    - echo "This job deploys something else. It will only run when all jobs in the"
    - echo "test stage complete. It will start at about the same time as deploy_a."
  environment: production
```

needs


```yml
stages:
  - build
  - test
  - deploy

image: alpine

build_a:
  stage: build
  script:
    - echo "This job builds something quickly."

build_b:
  stage: build
  script:
    - echo "This job builds something else slowly."

test_a:
  stage: test
  needs: [build_a]
  script:
    - echo "This test job will start as soon as build_a finishes."
    - echo "It will not wait for build_b, or other jobs in the build stage, to finish."

test_b:
  stage: test
  needs: [build_b]
  script:
    - echo "This test job will start as soon as build_b finishes."
    - echo "It will not wait for other jobs in the build stage to finish."

deploy_a:
  stage: deploy
  needs: [test_a]
  script:
    - echo "Since build_a and test_a run quickly, this deploy job can run much earlier."
    - echo "It does not need to wait for build_b or test_b."
  environment: production

deploy_b:
  stage: deploy
  needs: [test_b]
  script:
    - echo "Since build_b and test_b run slowly, this deploy job will run much later."
  environment: production
```
_Parent-child pipelines_

```yml
stages:
  - triggers

trigger_a:
  stage: triggers
  trigger:
    include: a/.gitlab-ci.yml
  rules:
    - changes:
        - a/*

trigger_b:
  stage: triggers
  trigger:
    include: b/.gitlab-ci.yml
  rules:
    - changes:
        - b/*
```

```yml
build:
    stage: build
    script: echo Build

test:
    stage: test
    script: echo Test

deploy:
    stage: deploy
    when: manual
    script:
        - echo Check Deploy
        - echo $CODE
        - if [ "$(echo -n $CODE | sha256sum)" == "2bb80d537b1da3e38bd30361aa855686bde0eacd7162fef6a25fe97bf527a25b  -" ]; then echo ok; else exit 1; fi
        - echo Deploy
```
