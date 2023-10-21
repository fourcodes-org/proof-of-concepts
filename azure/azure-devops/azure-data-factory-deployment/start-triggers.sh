#!/usr/bin/env bash

accessTokenResponse=$(curl -s -X POST -d "grant_type=client_credentials&client_id=${APP_ID}&client_secret=${APP_SECRET}&resource=https://management.azure.com/" https://login.microsoftonline.com/${TENANT_ID}/oauth2/token | jq -r .access_token)

apiURL="https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${ADF_RESOURCE_GROUP_NAME}/providers/Microsoft.DataFactory/factories/${ADF_NAME}/triggers?api-version=2018-06-01"

triggersListResponse=$(curl -s -X GET -H "Authorization: Bearer ${accessTokenResponse}" -H "Content-Type: application/json" "${apiURL}")
triggersNameList=$(echo "${triggersListResponse}" | jq -r '.value[].name')

for triggersName in ${triggersNameList}
do
    if [ $triggersName == "FND_House_Keeping" ]; then
        echo "Ignore the ${triggersName}."
    else 
        apiURL="https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${ADF_RESOURCE_GROUP_NAME}/providers/Microsoft.DataFactory/factories/${ADF_NAME}/triggers/${triggersName}/start?api-version=2018-06-01"
        REQUEST_DATA='{}'
        CONTENT_LENGTH=$(echo -n "$REQUEST_DATA" | wc -c)
        http_status=$(curl -s -X POST -H "Authorization: Bearer ${accessTokenResponse}" -H "Content-Type: application/json" -H "Content-Length: $CONTENT_LENGTH" -d "$REQUEST_DATA" -w "%{http_code}" -o /dev/null "${apiURL}")
        echo "TRIGGER ${triggersName} is stared and Status Code is ${http_status}"
    fi
done
