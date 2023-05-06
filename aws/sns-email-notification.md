_sns-email-notification_

```py
import boto3
import sys

nameOfScript = sys.argv[0]

ENV = sys.argv[1]
URL = sys.argv[2]

def getAccountId():
    sts = boto3.client("sts")
    return sts.get_caller_identity()["Account"]

def SendAnEmailNotification(URL, ENV):
    SNS_ARN = "arn:aws:sns:{region}:{account}:{snsName}".format(region="us-east-1", account=getAccountId(), snsName="smtp-notification")
    Subject = "{ENV} ENVIRONMANT APPROVAL NOTIFICATION".format(ENV=ENV)
    client = boto3.client('sns')
    message = """Hello Team,

    Can anyone you please approve this message from SHIP-HATS console

    APPROVAL URL

        -   {URL}

    Kind Regards
    SH Approval Notification
    """.format(URL=URL)

    return client.publish(TopicArn=SNS_ARN, Message=message, Subject=Subject)


SendAnEmailNotification(URL, ENV)
```
_command execution_

```bash
python.exe C:\bca-automation-process\main.py "UAT" "https://google.com"
```
