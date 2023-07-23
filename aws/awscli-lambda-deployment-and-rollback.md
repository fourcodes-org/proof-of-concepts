_awscli-lambda-deployment-and-rollback_

```bash
#!/bin/bash

RELEASE_VERSION="1.0.0" 
sed -i "1s/^/# Release Version: $RELEASE_VERSION\n/" your_python_file.py

AWS_REGION="ap-south-1"
LAMBDA_FUNCTION_NAME="januo"
LAMBDA_ALIAS_NAME="uat"
LAMBDA_CODE_PATH="lambda_function.zip"
RELEASE_VERSION="version-9.0.0"
PREVIOUS_VERSION="version-8.0.0"

aws lambda update-function-code --function-name "${LAMBDA_FUNCTION_NAME}" --zip-file "fileb://$LAMBDA_CODE_PATH"
wait_duration=30
while [ $wait_duration -gt 0 ]; do
    sleep 5
    echo "Still waiting for function  update... $wait_duration seconds remaining."
    wait_duration=$((wait_duration - 5))
done

aws lambda publish-version --function-name "${LAMBDA_FUNCTION_NAME}" --description "${RELEASE_VERSION}"
alias_info=$(aws lambda get-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" 2>/dev/null)

if [ -z "$alias_info" ]; then
    # The alias does not exist, create a new one with the latest version
    latest_version=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
    aws lambda create-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "$latest_version"
    echo "Alias '${LAMBDA_ALIAS_NAME}' created and linked to the latest version ('${latest_version}')."
else
    # The alias already exists, update it to the specified version
    latest_version=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-1].[Version]' --output text)
    aws lambda update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${latest_version}"
    # function_version=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query "Versions[?Description=='${RELEASE_VERSION}'].Version" --output text)
    # aws lambda update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${function_version}"
    echo "Alias '${LAMBDA_ALIAS_NAME}' updated and linked to latest version"
fi

# Rollback version

PREVIOUS_VERSION=$(aws lambda list-versions-by-function --function-name "${LAMBDA_FUNCTION_NAME}" --query 'Versions[-2].Version' | tr -d '"')
aws lambda update-alias --function-name "${LAMBDA_FUNCTION_NAME}" --name "${LAMBDA_ALIAS_NAME}" --function-version "${PREVIOUS_VERSION}"
```
