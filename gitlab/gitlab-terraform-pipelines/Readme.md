# sh-bca-cis-infrastructure

This pipeline is `sh-bca-cis-infrastructure`, utilized for deploying the cis infra aws resources on aws console. The tool employed for deployment is Terraform. The resources will be deployed to the internet app tier and intranet app tier of cis. You can access the release notes from the provided [link](./RELEASE_NOTES.txt).

# how to trigger the pipeline?
 
When the [pipeline](https://sgts.gitlab-dedicated.com/wog/bca/cnx-portal/bca-cnx-amc/bca-cx-amc-mcm/sh-bca-cis-infrastructure/-/pipelines) is triggered, it awaits approval for the manual process to proceed to the stage below. This stage requires both the variable name and values. If you forget to pass these values, the pipeline will either throw an error or skip the conditions. Therefore, we need to be mindful of the variable process. If you want to trigger the pipeline manually along with a specific branch, you can do so.

# stages

|  STAGE      | JOB NAME          |    TRIGGER TYPE  |INPUT REQUIRE|KEY NAME|KEY VALUE| EXPLAINATION |
|-------------|--------------|--------------|----------------| -------------|-----------|-----------|
| sit-proceed-prompt | sit-proceed-prompt| manual-trigger | True | DEPLOYMENT_CONFIRMATION | YES or NO | If "YES," the pipeline will start deploying the SIT environment. If "NO," it will stop the pipeline. |
| uat-proceed-prompt | uat-proceed-prompt | manual-trigger | True       | DEPLOYMENT_CONFIRMATION | YES or NO |If "YES," the pipeline will start deploying the UAT environment. If "NO," it will stop the pipeline. |
| uat-rollout-maintenance-prompt | uat-rollout-maintenance-prompt | manual-trigger |True| MAINTENANCE_REQUIRED | YES or NO | If you select 'YES,' the pipeline will initiate the maintenance window for the UAT environment. If you choose 'NO,' it will skip the maintenance window. |
| uat-rollout-bca-validation-prompt | uat-bca-validation-prompt| manual-trigger | True| BCA_VALIDATION_STATUS | SUCCESS or FAILURE | If you select 'SUCCESS,' the pipeline will continue the UAT environment. If you choose 'FAILURE,' it will skip it. |
| uat-rollback-decision | uat-rollback-decision | manual-trigger | False | VERSION_TO_ROLLBACK | - |This input is not mandatory. By default, it will use the previous version tag. However, when you want to customize your input before deployment, you need to ensure that the [tag](https://sgts.gitlab-dedicated.com/wog/bca/cnx-portal/bca-cnx-amc/bca-cx-amc-mcm/sh-bca-cis-infrastructure/-/tags) version to deploy is properly tagged for rollback. If you provide the wrong version, it will not work.|
| uat-rollback-maintenance-prompt |uat-rollback-maintenance-prompt| auto-trigger | True  | MAINTENANCE_REQUIRED | YES or NO | If you select 'YES,' the pipeline will initiate the maintenance window for the UAT environment. If you choose 'NO,' it will skip the maintenance window. |
| uat-rollback-bca-validation-prompt | uat-bca-validation-prompt| manual-trigger |True| BCA_VALIDATION_STATUS | SUCCESS or FAILURE | If you select 'SUCCESS,' the pipeline will continue the UAT environment. If you choose 'FAILURE,' it will skip it. |
| prd-proceed-prompt | prd-proceed-prompt| manual-trigger |True | DEPLOYMENT_CONFIRMATION | YES or NO |If "YES," the pipeline will start deploying the PRD environment. If "NO," it will stop the pipeline. |
| prd-rollout-maintenance-prompt | prd-rollout-maintenance-prompt| manual-trigger |True| MAINTENANCE_REQUIRED | YES or NO | If you select 'YES,' the pipeline will initiate the maintenance window for the PRD environment. If you choose 'NO,' it will skip the maintenance window. |
| prd-rollout-bca-validation-prompt | prd-bca-validation-prompt| manual-trigger |True| BCA_VALIDATION_STATUS | SUCCESS or FAILURE | If you select 'SUCCESS,' the pipeline will continue the PRD environment. If you choose 'FAILURE,' it will skip it. |
| prd-rollback-decision | prd-rollback-decision | manual-trigger | False | VERSION_TO_ROLLBACK | - |This input is not mandatory. By default, it will use the previous version tag. However, when you want to customize your input before deployment, you need to ensure that the [tag](https://sgts.gitlab-dedicated.com/wog/bca/cnx-portal/bca-cnx-amc/bca-cx-amc-mcm/sh-bca-cis-infrastructure/-/tags) version to deploy is properly tagged for rollback. If you provide the wrong version, it will not work.|
| prd-rollback-maintenance-prompt | prd-rollback-maintenance-prompt | auto-trigger | True | MAINTENANCE_REQUIRED | YES or NO | If you select 'YES,' the pipeline will initiate the maintenance window for the PRD environment. If you choose 'NO,' it will skip the maintenance window. |
| prd-rollback-bca-validation-prompt | prd-bca-validation-prompt| manual-trigger |True| BCA_VALIDATION_STATUS | SUCCESS or FAILURE | If you select 'SUCCESS,' the pipeline will continue the PRD environment. If you choose 'FAILURE,' it will skip it. |

# scan checklist

When the pipeline is activated, it runs the checklist below, which you must complete before deployment. Consequently, you must understand the scan tools we've integrated, along with their specialized goals, to examine the scan findings and identify vulnerabilities.

| TOOL NAME | TOOL TYPE | QUALITY GATE | PURPOSE OF TOOL | FILE NAME |
|----|----|----|----|----|
| gitlab secret scan| gitlab native | Automatic-Blocking | To uncover any secrets inadvertently committed by developers, the system will automatically return an error message if any are found, halting the pipeline's progression to the next stage.|gl-secret-detection-report.json|
| gitlab iac scan| gitlab native | Automatic-Blocking | GitLab itself provides infrastructure definition files to identify known vulnerabilities. This allows you to detect vulnerabilities before they are committed to the any branch, enabling proactive risk management for your application. The system will automatically halt the pipeline's progression to the next stage and return an error message if any vulnerabilities are found.| gl-sast-report.json|
| checkov | ship-hats | Automatic-Blocking | Ship-Hats itself provides infrastructure definition files for known vulnerabilities based on CloudScap expectations. It identifies vulnerabilities before they are committed to any branch, proactively addressing risks to your application. The system automatically returns an error message if any vulnerabilities are found, halting the pipeline's progression to the next stage. |checkov_results.xml|

# how can download the scan artifacts?

 They are stored under the S3 DevOps artifacts account, specifically within the S3 directory named `sst-s3-bca-cnxcp-devops-artifacts`." By navigating to the `cnxcp-scan-reports` folder, one can access these [files](https://sst-s3-bca-cnxcp-devops-artifacts.s3.ap-southeast-1.amazonaws.com/cnxcp-scan-reports/) based on the pipelines established.

# how can download the email scan artifacts??

Once the scan is performed by the pipeline before proceeding, you will receive an `email notification` containing the appropriate pipeline along with `scan result attachments`. You may need to manually download the report and review it. By default, the pipeline itself identifies such vulnerabilities to ensure that the approver reviews them twice before approval.

# compare revisions

To compare branches in a repository

1. On the left sidebar, select Search or go to and find your `project`.
2. Select `Code` > `Compare revisions`.
3. Select the Source branch to search for your desired branch. Exact matches are shown first. You can refine your search with operators:
    - `^` matches the beginning of the branch name: `^feat` matches `feat/user-authentication`.
    - `$` matches the end of the branch name: `widget$` matches `feat/search-box-widget`.
    - `*` matches using a wildcard: `branch*cache* matches `fix/branch-search-cache-expiration`.
    - You can combine operators: `^chore/*migration$` matches `chore/user-data-migration`.
4. Select the `Target` repository and `branch`. Exact matches are shown first.
5. Below Show changes, select the method to compare branches:
6. Select Compare to show the list of commits, and changed files.
7. Optional. To reverse the Source and Target, select Swap revisions.

# approval process

The approval process involves the following steps:

1. _**Receive Email Notification**_ approvers will receive an email notification regarding the approval process.
2. _**Perform Scan Report Check**_ approvers must review the scan findings to ensure there are no vulnerabilities. Refer to the [scan checklist](#scan-checklist) for details.
3. _**Review Scan Findings**_ carefully review the scan findings from GitLab Secret Scan, GitLab IAC Scan, and Checkov. Take note of any vulnerabilities or issues flagged by the scan tools.
4. _**Take Action on Vulnerabilities**_ if any vulnerabilities are found, take appropriate action to address them. This may involve consulting with the development team to resolve issues or mitigate risks.
5. _**Approve Pipeline**_ once it's confirmed that there are no vulnerabilities or necessary actions have been taken to address them, proceed to approve the pipeline. Follow the approval mechanism specific to the environment, which may involve clicking on an approval button or responding to the email notification with an approval message.
6. _**Document Approval**_ ensure that the approval process is properly documented, including any actions taken to address vulnerabilities. This documentation may be needed for compliance purposes or future reference.

# how to approve the pipelines?

We have five approval environments, each with its approval mechanism. When an approver receives a notification via email, they must follow the outlined process below.

1. Once you receive the email notification regarding the [approval process](#approval-process), you must follow above approval process [step](#scan-checklist) to ensure there are no vulnerabilities.

![pipeline](.gitlab/docs/7.png)

2. find an `APPROVE` or `REJECT` button. Depending on your decision, it will automatically redirect to the pipeline. Before proceeding, ensure that you are logged into the GitLab console. If you are not logged in, it will prompt you to log in before redirecting you to the specific pipeline page as illustrated below.

![pipeline](.gitlab/docs/3.png)

3. Navigate to the designated stage and locate the corresponding job title, which can be found in the email notification. Subsequently, click on the settings icon adjacent to the job name. This action will redirect you as indicated above.

![pipeline](.gitlab/docs/1.png)

4. Hold down the `Ctrl` key on your keyboard and simultaneously click on the blue `View Environment Details Page` link. This action will open a new browser tab for you, as depicted below. 

![pipeline](.gitlab/docs/4.png)

5. Navigate through your email notifications promptly to locate the request that necessitates your approval and retrieve the `Environment Approval ID` mentioned therein.

![pipeline](.gitlab/docs/4.png)

6. Choose the appropriate ID that corresponds to your email notification item currently in the `waiting` status. On the right-hand side, you will find a `thumbs-up` icon. Click on it, and a pop-up will appear. From there, you can decide whether to approve or reject the item. If you have any questions, please refer to the screenshot above.

![pipeline](.gitlab/docs/5.png)

7. Once the pipeline is approved, you can navigate back to the previous page where you executed step 4. The modified page should look like the following.

![pipeline](.gitlab/docs/6.png)

8. Click `Run Job`. The process will automatically proceed, and the remaining deployment team will handle the rest of the process.