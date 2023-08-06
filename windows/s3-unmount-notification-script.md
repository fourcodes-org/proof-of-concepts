_s3 unmount notification script_

```ps1
# AWS S3 Bucket and SNS Topic information
$S3BucketName = "your-s3-bucket-name"
$SNSTopicArn = "arn:aws:sns:us-east-1:123456789012:YourSNSTopic"

# Function to check if the S3 bucket is mounted
function Test-S3Mounted {
    $result = Get-WmiObject Win32_MappedLogicalDisk | Where-Object {$_.ProviderName -eq "s3.amazonaws.com/$S3BucketName"}
    return [bool]($result -ne $null)
}

# Function to send a notification to SNS
function Send-SNSNotification {
    param (
        [string]$topicArn,
        [string]$subject,
        [string]$message
    )

    Write-Host "Sending SNS notification..."
    $awsRegion = "us-east-1" # Change to your desired AWS region
    $cmdOutput = aws sns publish --topic-arn $topicArn --message $message --subject $subject --region $awsRegion
    Write-Host "SNS notification sent!"
}

# Main script
$intervalMinutes = 30 # Change this to your desired interval in minutes

while ($true) {
    if (-Not (Test-S3Mounted)) {
        $subject = "S3 Bucket Unmounted on Windows Instance"
        $message = "The S3 bucket $S3BucketName has been unmounted from the Windows instance."
        Send-SNSNotification -topicArn $SNSTopicArn -subject $subject -message $message
    }

    # Sleep for the specified interval
    Start-Sleep -Seconds ($intervalMinutes * 60)
}


```
