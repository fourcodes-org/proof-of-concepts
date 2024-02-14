# How to to access the aws resources from azure windows machine

```ps1

$RESPONSE = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com' -Headers @{Metadata="true"}
$CONTENT = $RESPONSE.Content | ConvertFrom-Json
$IDENTITY_OIDC_TOKEN = $CONTENT.access_token

# Print the output
Write-Output $IDENTITY_OIDC_TOKEN

# AWS Arn details
$ROLE_ARN = "arn:aws:iam::xxx:role/demo-access-s3"

# Export AWS credentials using assumed role with web identity
$AWSCREDENTIALS = aws sts assume-role-with-web-identity `
                    --role-arn $ROLE_ARN `
                    --role-session-name "S3" `
                    --web-identity-token $IDENTITY_OIDC_TOKEN `
                    --duration-seconds 3600 `
                    --output json  | ConvertFrom-Json

# Print the Credentials
Write-Output $AWSCREDENTIALS.Credentials

# Set AWS credentials as environment variables
$env:AWS_ACCESS_KEY_ID = $AWSCREDENTIALS.Credentials.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $AWSCREDENTIALS.Credentials.SecretAccessKey
$env:AWS_SESSION_TOKEN = $AWSCREDENTIALS.Credentials.SessionToken

# Verify the assumed role
aws sts get-caller-identity


# Implement the logic 

aws s3 ls 

# Remove the tmp environment variables
Remove-Item -Path Env:\AWS_ACCESS_KEY_ID
Remove-Item -Path Env:\AWS_SECRET_ACCESS_KEY
Remove-Item -Path Env:\AWS_SESSION_TOKEN


```
