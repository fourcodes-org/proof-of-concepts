_.gitlab-ci.yml_

```yml
variables:
  CURRENT_RELEASE_VERSION: "version-1.0.0"
  PREVIOUS_RELEASE_VERSION: "version-1.0.0"
  DS_EXCLUDED_ANALYZERS: "gemnasium-maven, gemnasium"

.uat_rules:
  rules:
    - if: ( $CI_COMMIT_BRANCH =~ /^Release/ )

.prd_rules:
  rules:
    - if: ( $CI_COMMIT_BRANCH == "main" || $CI_COMMIT_BRANCH =~ /^Hotfix/)

.lambda-product-vars: &lambda-product-vars
  parallel:
    matrix:
      - APP_NAME: januo-client
        SOURCE_DIR: januop-client
        UAT_LAMBDA_NAME: "demo"
        PRD_LAMBDA_NAME: "demo"
        SONAR_PROJECT_NAME: januo-client
        SONAR_TOKEN: ${SONAR_TOKEN_JANUO_CLIENT}
        UAT_ENVIRONMENT_NAME: "uat"
        PRD_ENVIRONMENT_NAME: "prod"

```

_deployment pipeline_

```yml
ship-lambda-build-package:
  stage: build
  rules:
    - !reference [.uat_and_prd_rules, rules] 
  image:
    name: alpine
    entrypoint: [""]
  variables:
    RELEASE_VERSION: ${CURRENT_RELEASE_VERSION}
  tags:
    - ship_docker  
  before_script:
    - apk add zip
  script:
    - |
      sed -i "1s/^/# Release Version: $RELEASE_VERSION\n/" ${SOURCE_DIR}/lambda_function.py
    - zip -r -j ${APP_NAME}.zip ${SOURCE_DIR}/lambda_function.py
  artifacts:
    paths:
      - ${APP_NAME}.zip
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]

ship-lambda-uat-deploy:
  stage: deploy-to-uat-env
  rules:
    - !reference [.uat_rules, rules]
  tags:
  - uat-redhat-gitlab-remote-runner
  variables:
    LAMBDA_FUNCTION_NAME: ${UAT_LAMBDA_NAME}
    LAMBDA_ALIAS_NAME: ${UAT_ENVIRONMENT_NAME}
    RELEASE_VERSION: ${CURRENT_RELEASE_VERSION}
    PREVIOUS_VERSION: ${PREVIOUS_RELEASE_VERSION}
  script:
  - export AWS_DEFAULT_REGION=$AWS_REGION
  - |
    aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com update-function-code --function-name "${LAMBDA_FUNCTION_NAME}" --zip-file fileb://${APP_NAME}.zip
    wait_duration=30
    while [ $wait_duration -gt 0 ]; do
        sleep 5
        echo "Still waiting for function  update... $wait_duration seconds remaining."
        wait_duration=$((wait_duration - 5))
    done
    aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com publish-version --function-name "${LAMBDA_FUNCTION_NAME}" --description "${RELEASE_VERSION}"
    alias_info=$(aws lambda get-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" 2>/dev/null)

    if [ -z "$alias_info" ]; then
        # The alias does not exist, create a new one with the latest version
        latest_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
        aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com create-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "$latest_version"
        echo "Alias '${LAMBDA_ALIAS_NAME}' created and linked to the latest version ('${latest_version}')."
    else
        # The alias already exists, update it to the specified version
        # latest_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
        # aws lambda update-alias --endpoint-url https://lambda.ap-southeast-1.amazonaws.com --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${latest_version}"
        function_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query "Versions[?Description=='${RELEASE_VERSION}'].Version" --output text)
        aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${function_version}"
        echo "Alias '${LAMBDA_ALIAS_NAME}' updated and linked to latest version"
    fi
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]

ship-lambda-prd-deploy:
  stage: deploy-to-prod-env
  rules:
  - !reference [.prd_rules, rules]
  tags:
  - prod-redhat-gitlab-remote-runner
  variables:
    LAMBDA_FUNCTION_NAME: ${PRD_LAMBDA_NAME}
    LAMBDA_ALIAS_NAME: ${PRD_ENVIRONMENT_NAME}
    RELEASE_VERSION: ${CURRENT_RELEASE_VERSION}
    PREVIOUS_VERSION: ${PREVIOUS_RELEASE_VERSION}
  script:
  - export AWS_DEFAULT_REGION=$AWS_REGION
  - |
    aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com update-function-code --function-name "${LAMBDA_FUNCTION_NAME}" --zip-file fileb://${APP_NAME}.zip
    wait_duration=30
    while [ $wait_duration -gt 0 ]; do
        sleep 5
        echo "Still waiting for function  update... $wait_duration seconds remaining."
        wait_duration=$((wait_duration - 5))
    done
    aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com publish-version --function-name "${LAMBDA_FUNCTION_NAME}" --description "${RELEASE_VERSION}"
    alias_info=$(aws lambda get-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" 2>/dev/null)

    if [ -z "$alias_info" ]; then
        # The alias does not exist, create a new one with the latest version
        latest_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
        aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com create-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "$latest_version"
        echo "Alias '${LAMBDA_ALIAS_NAME}' created and linked to the latest version ('${latest_version}')."
    else
        # The alias already exists, update it to the specified version
        # latest_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
        # aws lambda update-alias --endpoint-url https://lambda.ap-southeast-1.amazonaws.com --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${latest_version}"
        function_version=$(aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query "Versions[?Description=='${RELEASE_VERSION}'].Version" --output text)
        aws lambda --endpoint-url https://lambda.ap-southeast-1.amazonaws.com update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${function_version}"
        echo "Alias '${LAMBDA_ALIAS_NAME}' updated and linked to latest version"
    fi
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]

ship-lambda-prd-deploy-rollback:
  stage: rollback
  rules:
    - !reference [.uat_rules, rules]
  tags:
  - uat-redhat-gitlab-remote-runner
  variables:
    LAMBDA_FUNCTION_NAME: ${UAT_LAMBDA_NAME}
    LAMBDA_ALIAS_NAME: ${UAT_ENVIRONMENT_NAME}
    RELEASE_VERSION: ${CURRENT_RELEASE_VERSION}
    PREVIOUS_VERSION: ${PREVIOUS_RELEASE_VERSION}
  script:
  - export AWS_DEFAULT_REGION=$AWS_REGION
  - |
    function_version=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query "Versions[?Description=='${RELEASE_VERSION}'].Version" --output text)
    aws lambda update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${function_version}"
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]
  when: manual
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]
  when: manual

ship-lambda-prd-deploy-rollback:
  stage: rollback
  rules:
  - !reference [.prd_rules, rules]
  tags:
  - prod-redhat-gitlab-remote-runner
  variables:
    LAMBDA_FUNCTION_NAME: ${PRD_LAMBDA_NAME}
    LAMBDA_ALIAS_NAME: ${PRD_ENVIRONMENT_NAME}
    RELEASE_VERSION: ${CURRENT_RELEASE_VERSION}
    PREVIOUS_VERSION: ${PREVIOUS_RELEASE_VERSION}
  script:
  - export AWS_DEFAULT_REGION=$AWS_REGION
  - |
    function_version=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query "Versions[?Description=='${RELEASE_VERSION}'].Version" --output text)
    aws lambda update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${function_version}"
  parallel:
    matrix:
      !reference [.lambda-product-vars, parallel, matrix]
  when: manual

```
