


```yml
ship-uat-deploymet:
  stage: build
  tags:
  - cp-runner
  script:
    - export AWS_DEFAULT_REGION="ap-southeast-1"
    - |
        ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
        AWS_ECR_REPO_NAME="nginx"
        REPOSITORY_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${AWS_ECR_REPO_NAME}"
        IMAGE_TAG="nginx-v5"
        AWS_DEFAULT_REGION="ap-southeast-1"
        TASK_DEFINITION_NAME="tskd-cnxcp-uatmzna-nginx"
        AWS_ECS_SERVICE="nginx_cicd"
        CLUSTER_NAME="ecs-cnxcp-uatmzna-nginx"
        DOCKER_IMAGE=$REPOSITORY_URL:$IMAGE_TAG
        DESIRE_COUNT=2

        OLD_TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION_NAME --output json)
        OLD_TASK_DEF_REVISION=$(echo $OLD_TASK_DEF | jq ".taskDefinition|.revision")
        NEW_TASK_DEF=$(echo $OLD_TASK_DEF | jq --arg NDI $DOCKER_IMAGE '.taskDefinition.containerDefinitions[0].image=$NDI')

        # echo "Create a new task template with all the required information to bring over"
        FINAL_TASK=$(echo $NEW_TASK_DEF | jq '.taskDefinition|{networkMode: .networkMode, family: .family, volumes: .volumes, taskRoleArn: .taskRoleArn, executionRoleArn: .executionRoleArn, containerDefinitions: .containerDefinitions, memory: .memory, cpu: .cpu}')

        # SET variables for re-use

        echo "Upload the task information and register the new task definition along with optional information"
        UPDATED_TASK=$(aws ecs register-task-definition --cli-input-json "$(echo $FINAL_TASK)")

        echo "Storing the Revision"
        UPDATED_TASK_DEF_REVISION=$(echo $UPDATED_TASK | jq ".taskDefinition|.taskDefinitionArn")
        echo "Updated task def revision: $UPDATED_TASK_DEF_REVISION"

        echo "switch over to the new task definition by selecting the newest revision"
        SUCCESS_UPDATE=$(aws ecs update-service --region $AWS_DEFAULT_REGION --desired-count $DESIRE_COUNT --service $AWS_ECS_SERVICE --task-definition $TASK_DEFINITION_NAME --cluster $CLUSTER_NAME --force-new-deployment)


        echo "Verify the new task definition attached and the old task definitions de-register aka cleanup"
        for attempt in {1..8}; do
            echo "Process ${attempt}"
            IS_ECS_READY=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $AWS_ECS_SERVICE | jq '.services[0] .deployments | .[] | select(.taskDefinition == '${UPDATED_TASK_DEF_REVISION}') | (.desiredCount == .runningCount and .status == "PRIMARY")')

            if [[ $IS_ECS_READY = false ]]; then
                echo "Waiting for $UPDATED_TASK_DEF_REVISION"

                sleep 20

                ACTIVE_TASK_DEFS=$(aws ecs list-task-definitions --family-prefix $TASK_DEFINITION_NAME | jq '.taskDefinitionArns')

                IS_MULTIPLE_ACTIVE_TASK_DEFS=$(echo $ACTIVE_TASK_DEFS | jq 'map(select(. != '${UPDATED_TASK_DEF_REVISION}')) | length > 1')

                IS_ALL_TASKS_DRAINED=false

                continue
            elif [[ $IS_ALL_TASKS_DRAINED = true ]]; then

                echo "Successfully cleaned up old tasks and running the new task."

                PRIMARY_TASK=$(aws ecs list-task-definitions --family-prefix $TASK_DEFINITION_NAME | jq '.taskDefinitionArns[]')

                echo "$PRIMARY_TASK is the only running task"

                break
            else

                echo $ACTIVE_TASK_DEFS | jq -r '.[] | select(. != '${UPDATED_TASK_DEF_REVISION}')' | \
                while read arn; do
                    deregistered_status=$(aws ecs deregister-task-definition --task-definition $arn | jq '.taskDefinition .status');
                    echo "Setting $arn task definition to " + $(echo $deregistered_status)
                done

                ACTIVE_TASK_DEFS=$(aws ecs list-task-definitions --family-prefix $TASK_DEFINITION_NAME | jq '.taskDefinitionArns')

                sleep 30

                IS_ALL_TASKS_DRAINED=$(aws ecs describe-services --cluster $CLUSTER_NAME --services $AWS_ECS_SERVICE | jq '.services[0] .deployments | length == 1')
                
                echo "Are all obsolete tasks drained/stopped: $IS_ALL_TASKS_DRAINED"
            fi
        done
    - unset AWS_DEFAULT_REGION
```
