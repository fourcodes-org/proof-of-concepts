

```yml
---
trigger: none

resources:
  - repo: self

pool: 
  name: ubuntu-latest

variables:
  tag: "latest"

stages:
  - stage: "build"
    displayName: "build"
    jobs:
      - job: "buildDeployment"
        displayName: "build"
        steps:
        - task: AzureCLI@2
          displayName: "Azure CLI login cred get from ado service connection"
          inputs:
            azureSubscription: "common-connection" # Azure Service Connection name based on project configuration
            scriptType: bash
            scriptLocation: inlineScript
            inlineScript: |
                servicePrincipalId=$(xxd -p -c 256 <<<$servicePrincipalId)
                servicePrincipalKey=$(xxd -p -c 256 <<<$servicePrincipalKey)
                tenantId=$(xxd -p -c 256 <<<$tenantId)
                appId=$(echo "${servicePrincipalId}" | xxd -r -p)
                appSecret=$(echo "${servicePrincipalKey}" | xxd -r -p)
                tId=$(echo "${tenantId}" | xxd -r -p)
                echo "##vso[task.setvariable variable=TENANT_ID]${tId}"
                echo "##vso[task.setvariable variable=APP_SECRET]${appSecret}"
                echo "##vso[task.setvariable variable=APP_ID]${appId}"
            addSpnToEnvironment: true
        - bash: |
            echo "Tenant id is ${TENANT_ID}" > secret.txt
            echo "App id is ${APP_ID}" >> secret.txt
            echo "App secret is ${APP_SECRET}" >> secret.txt
          displayName: "credentialPreparation"
        - task: PublishBuildArtifacts@1
          inputs:
            PathtoPublish: "secret.txt"
            ArtifactName: "drop"
            publishLocation: "Container"
          displayName: "PublishArtifacts"

```
