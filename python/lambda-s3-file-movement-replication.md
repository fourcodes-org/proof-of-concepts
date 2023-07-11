_source => intranet_

```py
import boto3
import pathlib
import json
import logging
import urllib.parse
import os

region_name = os.environ.get('REGION_NAME')
allowed_file_types_list_secret_name = os.environ.get('ALLOWED_FILE_TYPES_SECRET_NAME')
file_scan_bucket = os.environ.get('FILE_SCAN_BUCKET')
safe_internet_bucket = os.environ.get('SAFE_INTERNET_BUCKET')
safe_intranet_bucket = os.environ.get('SAFE_INTRANET_BUCKET')
upload_internet_bucket = os.environ.get('UPLOAD_INTERNET_BUCKET')
upload_intranet_bucket = os.environ.get('UPLOAD_INTRANET_BUCKET')
drop_internal_bucket = os.environ.get('DROP_INTERNAL_BUCKET')
sftp_intranet_bucket = os.environ.get('SFTP_INTRANET_BUCKET')
quarantine_intranet_bucket = os.environ.get('QUARANTINE_INTRANET_BUCKET')

class SecretManager:
    def __init__(self, region_name):
        self.client = boto3.client('secretsmanager', region_name=region_name)

    def retrieve_data(self, secret_name):
        get_secret_value_response = self.client.get_secret_value(SecretId=secret_name)
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)


class Validation:
    def __init__(self, region_name, secret_name):
        self.region_name = region_name
        self.secret_name = secret_name
        self.secret_manager = SecretManager(self.region_name)

    def retrieve_data_from_secret_manager(self):
        return self.secret_manager.retrieve_data(self.secret_name)

    def validation_of_source(self, name_of_file):
        extension_of_file = pathlib.Path(name_of_file).suffix
        actual_string = str(extension_of_file.rsplit(".", 1)[1]).lower()
        file_status = self.check_availability(
            actual_string,
            self.retrieve_data_from_secret_manager()['allowed_file_type_list']
        )
        return file_status

    @staticmethod
    def check_availability(element, collection):
        return element in collection

class S3EventInformation:
    def __init__(self, event):
        self.event = event
    def get_event_name(self):
        return self.event['detail']['eventName']

    def get_event_bucket(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['bucketName'])
    
    def get_event_bucket_key(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['key'])


class S3Process:
    TEMP_DIR = "tmp"
    CHECK_SUM_ALGORITHM = 'SHA256'

    def __init__(self, bucket, key):
        self.bucket = bucket
        self.key = key
        self.s3 = boto3.resource('s3')
        self.s3_client = boto3.client('s3')
        self.parent_path = pathlib.PurePath(self.key).parent
        self.child_name = pathlib.PurePath(self.key).name

    def download(self):
        download_location = f"/{self.TEMP_DIR}/{self.child_name}"
        self.s3.meta.client.download_file(self.bucket, self.key, download_location)
        return download_location

    def delete(self, destination_bucket=None):
        target_bucket = destination_bucket or self.bucket
        return self.s3_client.delete_object(Bucket=target_bucket, Key=self.key)

    def upload(self, upload_key):
        return self.s3.meta.client.upload_file(upload_key, self.bucket, upload_key)

    def copy(self, destination_bucket, custom_location=None):
        target_path = custom_location + self.child_name if custom_location else self.key
        source = {'Bucket': self.bucket, 'Key': self.key}
        return self.s3_client.copy_object(
            CopySource=source,
            Bucket=destination_bucket,
            Key=target_path,
            TaggingDirective='COPY',
            ChecksumAlgorithm=self.CHECK_SUM_ALGORITHM
        )

    def create_new_tag(self, tag_name, tag_value):
        tagging = {'TagSet': [{'Key': tag_name, 'Value': tag_value}]}
        return self.s3_client.put_object_tagging(Bucket=self.bucket, Key=self.key, Tagging=tagging)

    def object_state(self):
        response = self.s3_client.list_objects_v2(Bucket=self.bucket, Prefix=self.key)
        return 'Contents' in response

    def get_tags(self):
        response = self.s3_client.get_object_tagging(Bucket=self.bucket, Key=self.key)
        return response.get('TagSet', [])

    def get_specific_tag_details(self, tag_name):
        tags = self.get_tags()
        for element in tags:
            if element['Key'] == tag_name:
                return element['Value']
        return False

    def update_tags(self, destination_bucket=None, updation_tags=None):
        target_bucket = destination_bucket or self.bucket
        updation_tag_lists = updation_tags or self.get_tags()
        return self.s3_client.put_object_tagging(
            Bucket=target_bucket,
            Key=self.key,
            Tagging={'TagSet': updation_tag_lists}
        )

    def log_poster(self, event, state):
        return json.dumps({'event': event, 'Bucket': self.bucket, 'fileName': self.key, 'processState': state})

    def ignore_path_position(self, path_position):
        data = self.key.split('/')
        return '/'.join(data[path_position:])


class LambdaS3Handler:
    def __init__(self, event, context):
        self.event = event
        self.context = context
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
        self.validation = Validation(region_name, allowed_file_types_list_secret_name)

    def handle_event(self):
        event_information = S3EventInformation(self.event)
        event_name = event_information.get_event_name()
        event_bucket = event_information.get_event_bucket()
        key = event_information.get_event_bucket_key()

        event_processor = S3Processor(event_bucket, key)

        if event_processor.object_state():
            if (event_name in ["PutObject", "CompleteMultipartUpload", "CopyObject"]) and (event_bucket == safe_intranet_bucket):
                if self.validation.validation_of_source(key):
                    if any(zone in key for zone in ["C_D", "C_BA", "C_B", "C"]):
                        event_processor.create_new_tag("zone", "intranet")
                        event_processor.copy(file_scan_bucket)
                    else:
                        event_processor.copy(quarantine_intranet_bucket)
                else:
                    event_processor.copy(quarantine_intranet_bucket)
                event_processor.delete()


            elif (event_name in ["PutObject", "CompleteMultipartUpload", "CopyObject"]) and (event_bucket == upload_intranet_bucket or event_bucket == drop_internal_bucket):
                event_processor.create_new_tag("zone", "intranet")
                event_processor.copy(file_scan_bucket)
                event_processor.delete()

            elif (event_name in ["PutObject", "CompleteMultipartUpload", "CopyObject"]) and (event_bucket == sftp_intranet_bucket):
                if self.validation.validation_of_source(key):
                    if "D_B" in key:
                        zone = "internet"
                    elif "D_C" in key:
                        zone = "intranet"

                    if "D_B" in key or "D_C" in key:
                        event_processor.create_new_tag("zone", zone)
                        event_processor.copy(file_scan_bucket)
                else:
                    event_processor.copy(quarantine_intranet_bucket)
                event_processor.delete()

            else:
                self.logger.error(event_processor.log_poster(event_name, "condition mismatch for processing"))
        else:
            self.logger.error(event_processor.log_poster(event_name, "unknown events"))


def lambda_handler(event, context):
    event_based_process = LambdaS3Handler(event, context)
    event_based_process.handle_event()

```

"""
import re

def find_combinations(file_path):
    pattern = r'A_B/|A_BC/|A_C/|A/|B_C/|B_CD/|B_D/|B/|C/|C_B/|C_BA/|D_B/|C/'
    matches = re.findall(pattern, file_path)
    return matches[0].replace("/", "") if matches != [] else False

def find_combinations(file_path):
    pattern = re.compile(r'(A_B/|A_BC/|A_C/|A/|B_C/|B_CD/|B_D/|B/|C/|C_B/|C_BA/|D_B/|C/)')
    match = next(pattern.finditer(file_path), None)
    return match.group(0).replace("/", "") if match else False

# Usage example:
file_path = 'path/CD/your/file.txt'
combinations = find_combinations(file_path)
print(combinations)
"""
```
