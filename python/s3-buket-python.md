

```py
import boto3

def aws_client_init(source='s3'):
    return boto3.client(source)

def create_bucket(bucket_name, bucket_location="us-east-1"):
    client = aws_client_init()
    response = client.create_bucket(
        Bucket=bucket_name,
        CreateBucketConfiguration={
            'LocationConstraint': bucket_location
        },
    )
    return response

def list_bucket():
    client = aws_client_init('s3')
    response = client.list_buckets()
    return [bucket["Name"] for bucket in response["Buckets"]]

print(create_bucket("bucket-e-python", "ap-south-1"))
print(list_bucket())
```
