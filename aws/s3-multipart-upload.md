_lambda code for multipart_

```py
import json
import boto3

SOURCE_BUCKET_NAME = "demo-sit-cp"

class MultipartUpload():
    def __init__(self, bucket, key, expires_in=60, verbose=False):
        self.bucket = bucket
        self.key = key
        self.expires_in = expires_in
        self.s3 = boto3.client("s3", config=boto3.session.Config(signature_version='s3v4'))
        if verbose:
            boto3.set_stream_logger(name="botocore")

    def download_object_s3_with_help_of_presigned_url(self):
        return self.s3.generate_presigned_url('get_object',Params={'Bucket': self.bucket, 'Key': self.key}, ExpiresIn=self.expires_in)

    def upload_id_creation(self):
        response = self.s3.create_multipart_upload(Bucket=self.bucket, Key=self.key, Expires=self.expires_in)
        return response['UploadId']

    def generate_presigned_urls_for_each_part(self, upload_id, part_count):
        presigned_urls_for_each_part = []
        for i in range(part_count):
            presigned_url = self.s3.generate_presigned_url(
                'upload_part',
                Params={
                    'Bucket': self.bucket,
                    'Key': self.key,
                    'UploadId': upload_id,
                    'PartNumber': i + 1
                }
            )
            presigned_urls_for_each_part.append(presigned_url)
        return presigned_urls_for_each_part


    def complete_multipart_upload(self, upload_id, parts):
        return self.s3.complete_multipart_upload(Bucket=self.bucket, Key=self.key, UploadId=upload_id, MultipartUpload={'Parts': parts})

    def abort_multipart_upload(self, upload_id):
        return self.s3.abort_multipart_upload(Bucket=self.bucket,Key=self.key, UploadId=upload_id)

    def single_part_upload_url(self):
        return self.s3.generate_presigned_url('put_object', Params={'Bucket': self.bucket, 'Key': self.key}, ExpiresIn=self.expires_in)


def handle_get_request(event):
    data = event.get('queryStringParameters')
    expire = data.get('expire')
    key = data.get('key')
    
    if expire and key:
        multi_part_upload_process = MultipartUpload(SOURCE_BUCKET_NAME, key, expire)
        download_url = multi_part_upload_process.download_object_s3_with_help_of_presigned_url()
        return {'statusCode': 200, 'body': download_url}
    else:
        return {'statusCode': 400, 'body': "bad request"}

def handle_post_request(event):
    data = json.loads(event['body'])
    key = data.get('key')
    expire = data.get('expire')
    method = data.get('method')
    no_of_parts = data.get('no_of_parts')
    upload_id = data.get('upload_id')
    parts = data.get('parts')

    if key and expire:
        multi_part_upload_process = MultipartUpload(SOURCE_BUCKET_NAME, key, expire)

        if method == "single":
            single_part_upload_url = multi_part_upload_process.single_part_upload_url()
            return {'statusCode': 200, 'body': json.dumps({'status': 'OK', 'description': 'The response for the single part upload url has been successfully returned.', 'presigned_urls': single_part_upload_url})}
        
        elif method == "upload_id":
            create_upload_id = multi_part_upload_process.upload_id_creation()
            return {'statusCode': 200, 'body': json.dumps({'status': 'OK', 'description': 'The response for the upload id has been successfully returned.', 'upload_id': create_upload_id})}
            
        elif method == "parts_creation":
            if upload_id and no_of_parts:
                upload_part = multi_part_upload_process.generate_presigned_urls_for_each_part(upload_id, no_of_parts)
                return {'statusCode': 200, 'body': json.dumps({'status': 'OK', 'description': 'The response for the upload part has been successfully returned.', 'upload_part': upload_part})}
            else:
                return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'The upload part has encountered an error'})}

        elif method == "complete_multipart_upload":
            try:
                if upload_id and parts:
                    multi_part_upload_url = multi_part_upload_process.complete_multipart_upload(upload_id, parts)
                    return {'statusCode': 200, 'body': json.dumps({'status': 'OK', 'description': 'The comtplete multi part process has been successfully returned.', 'presigned_urls': multi_part_upload_url})}
                else:
                    return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'The comtplete multi part process has encountered an error.'})}
            except:
                return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'NoSuchUpload.'})}

        elif method == "abort_multipart_upload":
            try:
                if upload_id:
                    abort_multipart_upload_status = multi_part_upload_process.abort_multipart_upload(upload_id)
                    return {'statusCode': 200, 'body': json.dumps({'status': 'OK', 'description': 'The abort multi part process has been successfully returned.', 'abort_multipart_upload_status': abort_multipart_upload_status})}
                else:
                    return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'The abort multi part process has encountered an error.'})}
            except:
                return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'NoSuchUpload'})}

        else:
            return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'Bad Request'})}
    else:
        return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'Bad Request'})}

def lambda_handler(event, context):
    if event['httpMethod'] == "GET":
        return handle_get_request(event)
    elif event['httpMethod'] == "POST":
        return handle_post_request(event)
    else:
        return {'statusCode': 400, 'body': json.dumps({'status': 'FAILED', 'description': 'Bad Request'})}

```

_test plan_

```py
import requests
import json
import os
import math

expire = 100
key = "demo.exe"
file_size = os.path.getsize('demo.exe')
part_size = 5 * 1024 * 1024
part_count = math.ceil(file_size / part_size)

URL = "https://z8pgyzdh8l.execute-api.ap-southeast-1.amazonaws.com/api/url"
HEADERS = {
    'Content-Type': 'application/json',
    'x-apigw-id': 'z8pgyzdh8l'
}

def send_request(method, payload):
    response = requests.request(method, URL, headers=HEADERS, data=json.dumps(payload))
    return json.loads(response.text)

def get_upload_id():
    payload = {
        "method": "upload_id",
        "key": key,
        "expire": expire
    }
    data = send_request("POST", payload)
    return data['upload_id']

def parts_creation(upload_id, part_count):
    payload = {
        "method": "parts_creation",
        "key": key,
        "expire": expire,
        "upload_id": upload_id,
        "no_of_parts": part_count
    }
    data = send_request("POST", payload)
    return data['upload_part']

def upload_part(url, part_number):
    with open('demo.exe', 'rb') as file:
        file.seek(part_number * part_size)
        data = file.read(part_size)

    response = requests.put(url, data=data)
    return response.headers['ETag']

def complete_multipart_upload(upload_id, parts):
    payload = {
        "method": "complete_multipart_upload",
        "key": key,
        "expire": expire,
        "upload_id": upload_id,
        "parts": parts
    }
    data = send_request("POST", payload)
    return data

upload_id = get_upload_id()
print(upload_id)

parts_creation_response = parts_creation(upload_id, part_count)
etags = [upload_part(parts_creation_response[i], i) for i in range(part_count)]

parts = [{'ETag': etags[i], 'PartNumber': i + 1} for i in range(part_count)]

complete_multipart_upload_response = complete_multipart_upload(upload_id, parts)
print(complete_multipart_upload_response)

```









_python use case_

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
