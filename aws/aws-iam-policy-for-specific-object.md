_aws-iam-policy-for-specific-object_

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToSpecificBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "AllowReadAccessToSpecificTag",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::sasi-lambda-backup/*",
            "Condition": {
                "StringEquals": {
                    "s3:ExistingObjectTag/team": "jino"
                }
            }
        }
    ]
}
```
