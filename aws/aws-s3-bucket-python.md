
This is the python aws s3 code

```py
import boto3

def create_bucket(bucket_name, bucket_location="us-east-1"):
    client = boto3.client('s3')
    response = client.create_bucket(
        Bucket=bucket_name,
        CreateBucketConfiguration={
            'LocationConstraint': bucket_location
        },
    )
    return response

def list_bucket():
    client = boto3.client('s3')
    response = client.list_buckets()
    return [bucket["Name"] for bucket in response["Buckets"]]

print(create_bucket("bucket-e-python", "ap-south-1"))
print(list_bucket())

```
