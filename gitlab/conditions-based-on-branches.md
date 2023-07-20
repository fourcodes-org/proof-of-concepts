
```yml
---
stages:
  - build
  - test
  - deploy

image: 
  name: alpine


build_a:
  stage: build
  rules:
    - if: ($CI_PIPELINE_SOURCE == "merge_request_event" || $CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH == "develop" || $CI_COMMIT_REF_NAME =~ /^feature/ )
  script:
    - echo "This development env access."

build_b:
  stage: build
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if:  $CI_PIPELINE_SOURCE != "push"
  script:
    - echo "This production env access."

```
