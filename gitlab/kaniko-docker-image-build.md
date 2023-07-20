

```yml
image: alpine
stages:
  - build_and_push

build and push docker image:
  stage: build_and_push
  only:
    variables:
        - $CI_COMMIT_TAG =~ /^v[0-9]+\.[0-9]+\.[0-9]+$/
  variables: 
    AWS_DEFAULT_REGION: REGION_NAME
    CI_REGISTRY_IMAGE: YOUR_ID.dkr.ecr.REGION_NAME.amazonaws.com/REPO_NAME
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  script:
    -  mkdir -p /kaniko/.docker
    -  echo "{\"credsStore\":\"ecr-login\"}" > /kaniko/.docker/config.json
    -  /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}"
```
