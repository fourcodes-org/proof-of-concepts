#!/usr/bin/env bash

# set -xe

# CLIENT_ID=""
# CLIENT_SECRET=""
# TENANT_ID=""
# WORKSPACE_ID=""
# PBIX_DATASET_DISPLAY_NAME=""
# FILE_NAME=""

# Function for authenticating and importing a Power BI dataset
import_powerbi_report() {
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

  get_report_name=$(get_report_name "${PBIX_DATASET_DISPLAY_NAME}" "${ACCESS_TOKEN}" | grep -i "${PBIX_DATASET_DISPLAY_NAME}" | wc -l)

  if [ "${get_report_name}" -eq 1 ]; then
    echo "Overwrite"
    NAME_CONFLICT="Overwrite"
  elif [ "${get_report_name}" -gt 1 ]; then
    echo "Please remove the report with the duplicate name and rerun the job."
    exit 1
  else
    echo "NewReports"
    NAME_CONFLICT="Ignore"
  fi
  
  # # Import the dataset
  HTTP_STATUS_CODE=$(upload_report "${PBIX_DATASET_DISPLAY_NAME}" "${ACCESS_TOKEN}")
  if [ "${HTTP_STATUS_CODE}" -eq 202 ]; then
    echo "updated and status code 202"
  else
    echo "Exiting the script due to status code ${HTTP_STATUS_CODE}"
    exit 1
  fi
}

# Function to get the ID of an existing reports

get_report_name() {
  local dataset_name="$1"
  local access_token="$2"
  local response=$(curl -s -X GET "$DATASET_URL" -H "Authorization: Bearer ${access_token}")
  echo "$response" | jq -r '.value[].reports[] | .name' 
}

# Function to upload a reports
upload_report() {
  local dataset_name="$1"
  local access_token="$2"
  local HTTP_STATUS_CODE
  HTTP_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${DATASET_URL}?datasetDisplayName=${dataset_name}&nameConflict=${NAME_CONFLICT}" -H "Authorization: Bearer ${access_token}" -H "Content-Type: multipart/form-data" -F "file=@${FILE_NAME}")
  echo "$HTTP_STATUS_CODE"
}

# Call the main function
import_powerbi_report
