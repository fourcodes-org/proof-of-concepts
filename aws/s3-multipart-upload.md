
```py
import boto3
import os


bucket_name = "demo-sit-cp"
file_path = "demo.exe"
s3_object_key = "destination/123.mp3"

# Create a new S3 client
s3 = boto3.client('s3')


def create_upload_id(bucket_name, file_path, Expires=100):
    response = s3.create_multipart_upload(Bucket=bucket_name, Key=file_path, Expires=Expires)
    return response['UploadId']

def create_upload_path(bucket_name, s3_object_key, PartNumber, upload_id, Body):
    return s3.upload_part(Bucket=bucket_name,Key=s3_object_key,PartNumber=PartNumber,UploadId=upload_id,Body=Body)


def complete_multipart_upload(bucket_name, s3_object_key, upload_id, parts):
    return s3.complete_multipart_upload(Bucket=bucket_name,Key=s3_object_key,UploadId=upload_id,MultipartUpload={'Parts': parts})


upload_id = create_upload_id(bucket_name, s3_object_key)

# Configure the part size and the number of parts
part_size = 5 * 1024 * 1024  # 5 MB
total_parts = -(-os.path.getsize(file_path) // part_size)  # Ceil division

# Upload parts
parts = []
with open(file_path, 'rb') as file:
    for part_number in range(total_parts):
        increment_part_number = part_number + 1
        data = file.read(part_size)
        part = create_upload_path(bucket_name, s3_object_key, increment_part_number, upload_id,data)
        parts.append({'PartNumber': part_number + 1, 'ETag': part['ETag']})


# Complete the multipart upload
complete_multipart_upload(bucket_name, s3_object_key, upload_id, parts)
print("Multipart upload completed successfully!")

```
