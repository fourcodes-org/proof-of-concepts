
Hello everyone,

Quick update for AWS VPC endpoints: When you want to route AWS REST API traffic using VPC endpoints, you have to modify the traffic with the help of environment variables, as shown below.

```bash

export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ENDPOINT_URL_S3=https://s3.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SNS=https://sns.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SQS=https://sqs.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_LAMBDA=https://lambda.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EC2=https://ec2.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_RDS=https://rds.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_RDS_DATA=https://rds-data.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EXECUTE_API=https://execute-api.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ECR_API=https://ecr.api.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ECR_DKR=https://ecr.dkr.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SECRETS_MANAGER=https://secretsmanager.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ELASTIC_FILE_SYSTEM=https://elasticfilesystem.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ECS=https://ecs.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EVENTS=https://events.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ECS_AGENT=https://ecs-agent.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ECS_TELEMETRY=https://ecs-telemetry.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EMAIL_SMTP=https://email-smtp.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EC2_MESSAGES=https://ec2messages.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SSM=https://ssm.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_MONITORING=https://monitoring.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_BACKUP=https://backup.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_BACKUP_GATEWAY=https://backup-gateway.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_CLOUDTRAIL=https://cloudtrail.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EBS=https://ebs.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ELASTICACHE=https://elasticache.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_ELASTICLOADBALANCING=https://elasticloadbalancing.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_KMS=https://kms.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_TRANSFER=https://transfer.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_TRANSFER_SERVER=https://transfer.server.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_STS=https://sts.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_DYNAMODB=https://dynamodb.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_CLOUDFORMATION=https://cloudformation.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_STATES=https://states.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SSM_MESSAGES=https://ssmmessages.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_SYNC_STATES=https://sync-states.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_EXECUTE_API=https://execute-api.ap-southeast-1.vpce.amazonaws.com
export AWS_ENDPOINT_URL_AUTOSCALING=https://autoscaling.ap-southeast-1.vpce.amazonaws.com

```



By default, AWS REST API traffic always goes to the global AWS REST API. This environment variable overrides the traffic route, directing it through the VPC Endpoint for the REST API instead of the global endpoints.

