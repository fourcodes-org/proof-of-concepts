#!/usr/bin/env bash

CLIENT_ID="xxxxx"
CLIENT_SECRET="xxxxxxx"
TENANT_ID="xxxxx"
WORKSPACE_ID="xxxxxxxx"
PBIX_DATASET_DISPLAY_NAME="demo"
FILE_NAME="pbix/Audit.pbix"

# Function for authenticating and importing a Power BI dataset
import_powerbi_dataset() {
  local TOKEN_ENDPOINT="https://login.microsoftonline.com/${TENANT_ID}/oauth2/token"
  local SCOPE_RESOURCE_URL="https://analysis.windows.net/powerbi/api"
  local REQUEST_BODY="grant_type=client_credentials"
  REQUEST_BODY+="&CLIENT_ID=${CLIENT_ID}"
  REQUEST_BODY+="&CLIENT_SECRET=${CLIENT_SECRET}"
  REQUEST_BODY+="&resource=${SCOPE_RESOURCE_URL}"

  local TOKEN_RESPONSE=$(curl -s -X POST -d "${REQUEST_BODY}" "${TOKEN_ENDPOINT}")
  local ACCESS_TOKEN=$(echo "${TOKEN_RESPONSE}" | jq -r '.access_token')

  local DATASET_URL="https://api.powerbi.com/v1.0/myorg/groups/${WORKSPACE_ID}/imports"
  local HTTP_STATUS_CODE

  # Check if the dataset already exists, if yes, delete it
  local DATASET_ID=$(get_dataset_id "${PBIX_DATASET_DISPLAY_NAME}" "${ACCESS_TOKEN}")
  if [ -n "${DATASET_ID}" ]; then
    delete_dataset "${DATASET_ID}" "${ACCESS_TOKEN}"
    echo "${DATASET_ID} is deleted"
  fi

  # Import the dataset
  HTTP_STATUS_CODE=$(upload_dataset "${PBIX_DATASET_DISPLAY_NAME}" "${ACCESS_TOKEN}")
  if [ "${HTTP_STATUS_CODE}" -eq 202 ]; then
    echo "updated and status code 202"
  else
    echo "Exiting the script due to status code ${HTTP_STATUS_CODE}"
    exit 1
  fi
}

# Function to get the ID of an existing dataset
get_dataset_id() {
  local dataset_name="$1"
  local access_token="$2"
  local response=$(curl -s -X GET "$DATASET_URL" -H "Authorization: Bearer ${access_token}")
  echo "$response" | jq -r ".value[] | select(.name == \"$dataset_name\").id"
}

# Function to delete a dataset by ID
delete_dataset() {
  local dataset_id="$1"
  local access_token="$2"
  local HTTP_STATUS_CODE
  HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${DATASET_URL}/${dataset_id}" -H "Authorization: Bearer ${access_token}")
}

# Function to upload a dataset
upload_dataset() {
  local dataset_name="$1"
  local access_token="$2"
  local HTTP_STATUS_CODE
  HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${DATASET_URL}?datasetDisplayName=${dataset_name}&nameConflict=Overwrite" -H "Authorization: Bearer ${access_token}" -H "Content-Type: multipart/form-data" -F "file=@${FILE_NAME}")
  echo "$HTTP_STATUS_CODE"
}

# Call the main function
import_powerbi_dataset
