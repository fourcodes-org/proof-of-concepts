_aws-s3-file-size-calculation_

```py

import boto3
s3 = boto3.resource("s3")
bucket = s3.Bucket(AWS_S3_BUCKET)
obj=bucket.objects.filter(Prefix='prefix')
for key in obj:
    file_size=round(key.size*1.0/1024, 2)
    print(file_size)
```
