

```bash
ROLLOUT_VERSION="1.3.0"
ROLLBACK_VERSION="1.2.0"
TARGET_BRANCH="release/${ROLLOUT_VERSION}"

LAST_RELEASE_BRANCH_NAME=$(curl -ks --request GET --header "PRIVATE-TOKEN: ${GITLAB_PAT_TOKEN}" "https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/repository/branches" |  jq -r '[.[] | select(.name | startswith("release/"))] | if length > 0 then last.name else "release/000" end')
BRANCH_CREATION_STATUS=$(curl -ks --request POST --header "PRIVATE-TOKEN: ${GITLAB_PAT_TOKEN}" --data "branch=${TARGET_BRANCH}&ref=${SOURCE_BRANCH}" --output /dev/null --write-out "%{http_code}" "https://${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/repository/branches")

if [ "${BRANCH_CREATION_STATUS}" -eq 201 ]; then
    echo -e "\e[32mRelease branch created in the name of ${TARGET_BRANCH}\e[0m"
    echo -e "\e[32mYour last release branch name: ${LAST_RELEASE_BRANCH_NAME}\e[0m"
else
    echo -e "\e[31mRelease already exists. Please change the version and modify it in release-manifest.yml file.\e[0m"
    echo -e "\e[31mYour last release branch name: ${LAST_RELEASE_BRANCH_NAME}\e[0m"
    exit 1
fi

```
