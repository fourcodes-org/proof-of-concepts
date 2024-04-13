## docs

[meeting](https://teams.microsoft.com/l/meetup-join/19:meeting_MzhmYTBkMWUtNDlkYS00ZDcwLTg2YWItMjQ5MDQzZmZhNmJj@thread.v2/0?context=%7B%22Tid%22:%221d04408b-5753-4b63-9dfd-9d4c8a26e0c9%22,%22Oid%22:%22fb698c1d-6481-446b-87ef-2a3ee3654c4b%22%7D)

## git Release flow

```bash
git add index.json
git commit -m "added"
git tag -a v1.0 HEAD -m "v1.0 tag created"
git push origin v1.0
git checkout -b develop
git push --set-upstream origin develop
git checkout -b feature/v2.0
# Modify index.json file
git commit -am "v2.0 added"
git push --set-upstream origin feature/v2.0
# Create a pull request from feature/v2.0 into develop ( develop <= feature/v2.0 )
git checkout develop
git pull
git checkout -b Release/v2.0
git push --set-upstream origin Release/v2.0
git pull
# Create a pull request from Release/v2.0 into main
git checkout main
git pull 
git tag -a v2.0 HEAD -m "v2.0 tag created"
git push origin v2.0
git checkout -b Hotfix/v4.1
git commit -am "hotfix applied"
git push --set-upstream origin Hotfix/v4.1
git checkout main 
git pull
git checkout develop 
git pull
```

![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/84d30e91-e74a-4b0a-ae4c-4df93f955ed9)

# Workflow with Existing Branch Setup

**1. Feature Development:**

- Developers create feature branches from the `develop` branch for their tasks.
- They commit code changes to their respective feature branches.

**2. Merge to `develop`:**

- Developers create merge requests from their feature branches to the `develop` branch for review and approval.
- Eric will be the approver for all development merges.
- Once approved, the changes are merged into the `develop` branch.
- The Azure build pipeline will be triggered to create artifacts for development deployment.

**3. Deployment to Development Environment:**

- Access the Release deployment pipelines in the navigation pane under "pipelines."
- Navigate to the Release section and select the specific pipeline.
- Create a release with the latest artifacts.
- Conduct comprehensive testing on the `develop` environment.

**4. Merge to `main`:**

- Create a merge request from the `develop` branch to the `main` branch when you are confident that the `develop` branch is ready for production.
- Developers create merge requests from their `develop` branches to the `main` branch for review and approval.
- Hui Leng will be the approver for all main merges.
- Once approved, the changes are merged into the `main` branch.
- The Azure build pipeline will be triggered to create artifacts for UAT and production deployment.

**5. Deployment to UAT and Production Environments:**

- Access the Release deployment pipelines in the navigation pane under "pipelines."
- Navigate to the Release section and select the specific pipeline.
- Create a release with the latest artifacts.
- Conduct comprehensive testing on the `UAT` environment and approve the production deployment.
