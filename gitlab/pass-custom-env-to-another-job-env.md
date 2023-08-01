_pass-custom-env-to-another-job-env_

```yml
stages:
- build
- deploy

build:
  stage: build
  script:
    - hello=123
    - echo "BUILD_VERSION=$hello" >> build.env
  artifacts:
    reports:
      dotenv: build.env

deploy:
  stage: deploy
  script:
    - echo "$BUILD_VERSION"  # Output is: 'hello'
  needs:
    - job: build
      artifacts: true
```
