_[Configure OpenID Connect in AWS to retrieve temporary credentials](https://docs.gitlab.com/ee/ci/cloud_services/aws/)_

Create the  `Identity providers`  under the aws IAM Console

_Add the identity provider_

  Create GitLab as a IAM OIDC provider in AWS following these instructions.

_ Include the following information_

```service
1. **Provider URL**: The address of your GitLab instance, such as `https://gitlab.com` or `http://gitlab.example.com`.
2. **Audience**: The address of your GitLab instance, such as `https://gitlab.com` or `http://gitlab.example.com`.
```
Note: _The address must include https://. Do not include a trailing slash._

Once the OIDC provider is created, it will look like this.

![image](https://user-images.githubusercontent.com/57703276/218640085-c9ca31d5-357c-4a80-9122-559c29a8a17a.png)


_Configure a role and trust_


```js
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::123487226531:oidc-provider/gitlab.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "gitlab.com:sub": "project_path:jjino/common-template-reference:ref_type:branch:ref:main"
          }
        }
      }
    ]
}
```

.gitlab-ci.yml

```yml
assume role:
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
    - aws sts get-caller-identity
```

_multi stages_
```yml
assume role:
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
    - aws sts get-caller-identity

secondary_role:
  image:
    name: amazon/aws-cli
    entrypoint: [""]
  script:
    - >
      STS=($(aws sts assume-role-with-web-identity
      --role-arn arn:aws:iam::676487226531:role/dev-web-console-identity
      --role-session-name "gitlab-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token ${CI_JOB_JWT_V2}
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))      
    - export AWS_ACCESS_KEY_ID="${STS[0]}"
    - export AWS_SECRET_ACCESS_KEY="${STS[1]}"
    - export AWS_SESSION_TOKEN="${STS[2]}"
    - export AWS_DEFAULT_REGION="us-east-1"
    - aws sts get-caller-identity
```


```yml
stages:
  - dev

before_script:
    - yum install -y zip jq
publish image:
  stage: dev
  image: 
    name: amazon/aws-cli
  script: 
    - IMAGE_TAG=$CI_COMMIT_TAG-$CI_COMMIT_SHORT_SHA
    - sed -i "s/<IMAGE_TAG>/$IMAGE_TAG/g; s/<AWS_REGION>/$AWS_REGION/g; s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g;" build.json
    - zip -r image.zip buildspec.yml Dockerfile hello_docker.html
    - aws s3api put-object --bucket $CODEBUILD_BUCKET --key app/$IMAGE_TAG/image.zip --body image.zip
    - CODEBUILD_ID=$(aws codebuild start-build --project-name "build-app-docker-image" --cli-input-json file://build.json | jq -r '.build.id')
    - sleep 5
    - CODEBUILD_JOB=$(aws codebuild batch-get-builds --ids $CODEBUILD_ID)
    - LOG_GROUP_NAME=$(jq -r '.builds[0].logs.groupName' <<< "$CODEBUILD_JOB")
    - |
      if [[ ${CODEBUILD_ID} != "" ]];
      then
        while true
        do
          sleep 10
          aws logs tail $LOG_GROUP_NAME --since 10s

          CODE_BUILD_STATUS=$(aws codebuild batch-get-builds --ids "$CODEBUILD_ID" | jq '.builds[].phases[] | select (.phaseType=="BUILD") | .phaseStatus' | tr -d '"')
          if [[ ${CODE_BUILD_STATUS} = "FAILED" ]];
          then
              exit 1
          elif [[ ${CODE_BUILD_STATUS} = "SUCCEEDED" ]];
          then
              break
          fi
        done
      else
        echo "Build initialization has failed"
        exit 1
      fi
  tags:
    - k8s-dev-runner
  only:
    refs:
      - tags
```
