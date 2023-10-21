#!/usr/bin/env bash

accessTokenResponse=$(curl -s -X POST -d "grant_type=client_credentials&client_id=${APP_ID}&client_secret=${APP_SECRET}&resource=https://management.azure.com/" https://login.microsoftonline.com/${TENANT_ID}/oauth2/token | jq -r .access_token)

triggerJsonFiles=$(find "${ENVIRONMENT_NAME}/triggers" -type f)

for triggerJsonFile in ${triggerJsonFiles}
do
    echo "Execute on ${triggerJsonFile}"
    triggerName=$(basename "${triggerJsonFile}" .json)
    requestBody=$(cat ${triggerJsonFile} | jq -r .)
    apiURL="https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${ADF_RESOURCE_GROUP_NAME}/providers/Microsoft.DataFactory/factories/${ADF_NAME}/triggers/${triggerName}?api-version=2018-06-01"
    response=$(curl -s -X PUT -H "Authorization: Bearer ${accessTokenResponse}" -H "Content-Type: application/json" -d "${requestBody}" "${apiURL}")
    echo ${response} | jq -r .
    sleep 1
done