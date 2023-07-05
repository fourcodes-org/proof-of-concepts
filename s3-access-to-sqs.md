s3-access-to-sqs-policy JSON

```json
{
  "Version": "2012-10-17",
  "Id": "s3-access-to-sqs",
  "Statement": [
    {
      "Sid": "s3-access-to-sqs",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "*"
    }
  ]
}
```
