_aws s3 storage integration_

Create the s3 bucket

```conf
januo-io
```

_create the s3 IAM Policy `policy.json`_

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:DeleteObjectVersion"
            ],
            "Resource": "arn:aws:s3:::januo-io/*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::januo-io"
        }
    ]
}
```

_create the trust releationship `trust_relationship.json`_

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "<STORAGE_AWS_IAM_USER_ARN>"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<STORAGE_AWS_EXTERNAL_ID>"
        }
      }
    }
  ]
}
```

_create test stage_

```sql
USER ROLE ACCOUNTADMIN;

GRANT USAGE ON INTEGRATION S3_INTEGRATION TO ROLE SYSADMIN;

USE ROLE SYSADMIN;
CREATE STAGE S3_RESTRICTED_STAGE STORAGE_INTEGRATION = S3_INTEGRATION   URL = 's3://januo-io';

LIST @S3_RESTRICTED_STAGE;
```
