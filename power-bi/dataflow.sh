#!/usr/bin/env bash

CLIENT_ID="xxxxxxxxx"
CLIENT_SECRET="xxxxxxxx"
TENANT_ID="xxxxxx"
WORKSPACE_ID="xxxxxxx"
DATAFLOW_ID="xxxxxxxxxx"
FILE_NAME="dataflows/demo.json"

# Function for authenticating and importing a Power BI dataset

powerbi_dataset_update() {
  local TOKEN_ENDPOINT="https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
  local SCOPE_RESOURCE_URL="https://analysis.windows.net/powerbi/api"
  local REQUEST_BODY="grant_type=client_credentials"
  REQUEST_BODY+="&CLIENT_ID=${CLIENT_ID}"
  REQUEST_BODY+="&CLIENT_SECRET=${CLIENT_SECRET}"
  REQUEST_BODY+="&resource=${SCOPE_RESOURCE_URL}"

  local TOKEN_RESPONSE=$(curl -s -X POST -d "${REQUEST_BODY}" "${TOKEN_ENDPOINT}")
  local ACCESS_TOKEN=$(echo "${TOKEN_RESPONSE}" | jq -r '.access_token')

  local DATASET_URL="https://api.powerbi.com/v1.0/myorg/groups/${WORKSPACE_ID}"
  local HTTP_STATUS_CODE

  # update the dataflow
  HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "${DATASET_URL}/dataflows/${DATAFLOW_ID}" -H "Authorization: Bearer ${ACCESS_TOKEN}" -d @${FILE_NAME}  -H "Content-Type: Application/json")

  if [ "${HTTP_STATUS_CODE}" -eq 200 ]; then
    echo "updated and status code 200"
  else
    echo "Exiting the script due to status code ${HTTP_STATUS_CODE}"
    exit 1
  fi
}

powerbi_dataset_update
