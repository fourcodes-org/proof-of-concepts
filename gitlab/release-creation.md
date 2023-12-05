```yml
stages:
  - release

variables:
  GITLAB_PAT_TOKEN: "glpat-xxx"
  SOURCE_BRANCH: main

release:
  stage: release
  before_script:
    - apt update
    - apt install jq -y
  script:
    - set -xe
    - env
    - >
      LAST_RELEASE_BRANCH_NAME=$(curl -ks --request GET --header "PRIVATE-TOKEN: ${GITLAB_PAT_TOKEN}" "https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/repository/branches" | jq -r '[.[] | select(.name | startswith("release/"))] | if length > 0 then last.name | split("/") | last else "1.0.0" end')
    - |
      increment_version() {
        local VERSION="$1"
        local SEGMENT="$2"
        
        IFS='.' read -r -a parts <<< "$VERSION"

        if [ "$SEGMENT" == "middle" ]; then
            ((parts[1]++))
        elif [ "$SEGMENT" == "last" ]; then
            ((parts[2]++))
        else
            echo "Invalid SEGMENT. Please use 'middle' or 'last'."
            exit 1
        fi

        new_version="${parts[0]}.${parts[1]}.${parts[2]}"
        echo "$new_version"
      }

      if [[ "${CI_COMMIT_BRANCH}" == "develop" ]]; then
          VERSION_INCREMENT="middle"
      else
          VERSION_INCREMENT="last"
      fi

      RELEASE_VERSION=$(increment_version "${LAST_RELEASE_BRANCH_NAME}" "${VERSION_INCREMENT}")
    - > 
      BRANCH_CREATION_STATUS=$(curl -ks --request POST --header "PRIVATE-TOKEN: ${GITLAB_PAT_TOKEN}" --data "branch=release/${RELEASE_VERSION}&ref=${SOURCE_BRANCH}" --output /dev/null --write-out "%{http_code}" "https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/repository/branches")
    - >
      if [ "${BRANCH_CREATION_STATUS}" -eq 201 ]; then
          echo -e "\e[32mRelease branch created in the name of release/${RELEASE_VERSION}\e[0m"
          echo -e "\e[32mYour last release branch name: release/${LAST_RELEASE_BRANCH_NAME}\e[0m"
      else
          echo -e "\e[31mUnable to create the release branch.\e[0m"
          echo -e "\e[31mYour last release branch name: release/${RELEASE_VERSION}\e[0m"
          exit 1
      fi
```
