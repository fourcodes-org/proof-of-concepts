_source internet_

```py
import json
import pathlib
import boto3
import urllib
import re
import os
import logging

region_name = os.environ.get('REGION_NAME')
allowed_file_types_list_secret_name = os.environ.get('ALLOWED_FILE_TYPES_SECRET_NAME')
safe_intranet_bucket = os.environ.get('SAFE_INTRANET_BUCKET')
tagging_safe_internet_bucket = os.environ.get('TAGGING_SAFE_INTERNET_BUCKET')
tagging_safe_intranet_bucket = os.environ.get('TAGGING_SAFE_INTRANET_BUCKET')
safe_internet_bucket = os.environ.get('SAFE_INTERNET_BUCKET')
scan_bucket = os.environ.get('SCAN_BUCKET')
quarantine_internet_bucket = os.environ.get('QUARANTINE_INTERNET_BUCKET')
quarantine_intranet_bucket = os.environ.get('QUARANTINE_INTRANET_BUCKET')
upload_internet_bucket = os.environ.get('UPLOAD_INTERNET_BUCKET')
upload_sftp_internet_bucket = os.environ.get('UPLOAD_SFTP_INTERNET_BUCKET')
upload_sftp_intranet_bucket = os.environ.get('UPLOAD_SFTP_INTRANET_BUCKET')
sftp_intranet_bucket = os.environ.get('SFTP_INTRANET_BUCKET')

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

class S3Processor:
    TEMP_DIRECTORY = "tmp"
    CHECKSUM_ALGORITHM = 'SHA256'

    def __init__(self, bucket, key):
        self.bucket = bucket
        self.key = key
        self.s3_resource = boto3.resource('s3')
        self.s3_client = boto3.client('s3')
        self.parent_path = pathlib.PurePath(self.key).parent
        self.child_name = pathlib.PurePath(self.key).name

    def download(self):
        download_location = os.path.join("/", self.TEMP_DIRECTORY, self.child_name)
        self.s3_resource.meta.client.download_file(self.bucket, self.key, download_location)
        return download_location

    def delete(self, destination_bucket=None):
        target_bucket = destination_bucket or self.bucket
        return self.s3_client.delete_object(Bucket=target_bucket, Key=self.key)

    def upload(self, upload_key):
        return self.s3_resource.meta.client.upload_file(upload_key, self.bucket, upload_key)

    def copy(self, destination_bucket, custom_location=None):
        target_path = custom_location or self.key
        source = {'Bucket': self.bucket, 'Key': self.key}
        return self.s3_client.copy_object(CopySource=source, Bucket=destination_bucket, Key=target_path, TaggingDirective='COPY', ChecksumAlgorithm=self.CHECKSUM_ALGORITHM)

    def create_new_tag(self, tag_name, tag_value):
        tagging = {'TagSet': [{'Key': tag_name, 'Value': tag_value}]}
        return self.s3_client.put_object_tagging(Bucket=self.bucket, Key=self.key, Tagging=tagging)

    def object_state(self):
        return 'Contents' in self.s3_client.list_objects(Bucket=self.bucket, Prefix=self.key)

    def get_tags(self):
        tags = self.s3_client.get_object_tagging(Bucket=self.bucket, Key=self.key)
        return tags['TagSet']

    def get_specific_tag_value(self, tag_name):
        tags = self.s3_client.get_object_tagging(Bucket=self.bucket, Key=self.key)
        tag_set = tags['TagSet']
        for tag in tag_set:
            if tag['Key'] == tag_name:
                return tag['Value']
        return False

    def update_tags(self, destination_bucket=None, updated_tags=None):
        target_bucket = destination_bucket or self.bucket
        tags_to_update = updated_tags or self.get_tags()
        return self.s3_client.put_object_tagging(Bucket=target_bucket, Key=self.key, Tagging={'TagSet': tags_to_update})

    def log_poster(self, event, status):
        return json.dumps({'event': event, 'Bucket': self.bucket, 'fileName': self.key, 'process_state': status})

    def ignore_path_from_position(self, position):
        path_parts = self.key.split('/')
        return "/".join(path_parts[position:])

class LambdaHandler:
    def __init__(self, event, context):
        self.event = event
        self.context = context
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
        self.validation = Validation(region_name, allowed_file_types_list_secret_name)

    def handle(self):
        event_information = S3EventInformation(self.event)
        event_name = event_information.get_event_name()
        event_bucket = event_information.get_event_bucket()
        key = event_information.get_event_bucket_key()

        event_processor = S3Processor(event_bucket, key)

        if event_processor.object_state():
            if (event_name in ["PutObject", "CompleteMultipartUpload", "CopyObject"]) and (event_bucket == upload_internet_bucket):
                if self.validation.validation_of_source(key):
                    tags = event_processor.get_tags()
                    tags.append({'Key': 'zone', 'Value': 'internet'})
                    event_processor.update_tags(event_bucket, tags)
                    event_processor.copy(safe_internet_bucket)
                    event_processor.copy(scan_bucket)
                else:
                    event_processor.copy(quarantine_internet_bucket)

                event_processor.delete()

            elif (event_name in ["PutObject", "CompleteMultipartUpload", "CopyObject"]) and (event_bucket == upload_sftp_internet_bucket):
                if self.validation.validation_of_source(key):
                    tags = event_processor.get_tags()
                    event_processor.update_tags(event_bucket, tags)
                    event_processor.copy(upload_internet_bucket, event_processor.ignore_path_position(2))
                else:
                    event_processor.copy(quarantine_internet_bucket)

                event_processor.delete()

            elif (event_name == "PutObjectTagging" and event_bucket == scan_bucket):
                zone_tag = event_processor.get_specific_tag_value("zone")
                get_tag_value = event_processor.get_specific_tag_value("fss-scan-result")
                tags = event_processor.get_tags()
                if (zone_tag == "Intranet" or zone_tag == "intranet"):
                    if get_tag_value == "no issues found":
                        if "C_D" in key:
                            event_processor.copy(sftp_intranet_bucket)
                        elif "C_BA" in key:
                            event_processor.copy(upload_internet_bucket)
                            event_processor.copy(safe_internet_bucket)
                        elif "C_B" in key:
                            event_processor.copy(safe_internet_bucket)
                        elif "C" in key:
                            event_processor.copy(tagging_safe_intranet_bucket)
                        else:
                            event_processor.copy(safe_intranet_bucket)
                    else:
                        event_processor.copy(quarantine_intranet_bucket)

                    event_processor.delete()

                else:
                    if "A_C" in key or "A_BC" in key or "A_B" in key:
                        event_processor.update_tags(tagging_safe_internet_bucket)
                        event_processor.delete()
                    elif "D_B" in key:
                        if get_tag_value == "no issues found":
                            event_processor.copy(tagging_safe_internet_bucket)
                        else:
                            event_processor.copy(quarantine_internet_bucket)
                        event_processor.delete()
                    else:
                        event_processor.update_tags(tagging_safe_internet_bucket)
                        event_processor.delete()

            elif (event_name == "PutObjectTagging" and event_bucket == tagging_safe_internet_bucket):
                get_tag_value = event_processor.get_specific_tag_value("fss-scan-result")
                if get_tag_value == "no issues found":
                    if "A_C" in key or "A_BC" in key or "A_B" in key:
                        event_processor.copy(safe_intranet_bucket)
                    elif "B_D" in key or "B_CD" in key or "B_C" in key:
                        event_processor.copy(upload_sftp_intranet_bucket)
                        event_processor.copy(safe_intranet_bucket)
                else:
                    event_processor.copy(quarantine_internet_bucket)

                if "A_C" in key or "A_BC" in key or "A_B" in key or "B_D" in key or "B_CD" in key or "B_C" in key or "B" in key:
                    event_processor.delete()

            elif (event_name in ["PutObject", "CompleteMultipartUpload"]) and (event_bucket == safe_internet_bucket):
                if self.validation.validation_of_source(key):
                    if "B_D" in key or "B_CD" in key or "B_C" in key or "B" in key:
                        event_processor.copy(scan_bucket)
                    else:
                        pass
                else:
                    event_processor.copy(quarantine_internet_bucket)
                    event_processor.delete()
            else:
                self.logger.error(event_processor.log_poster(event_name, "condition mismatch for processing"))
        else:
            self.logger.error(event_processor.log_poster(event_name, "unknown events"))

def lambda_handler(event, context):
    handler = LambdaHandler(event, context)
    handler.handle()

```

_work around_

```py
import re

def find_combinations(file_path):
    pattern = 'A_B/|A_BC/|A_C/|A/|B_C/|B_CD/|B_D/|B/|C/|C_B/|C_BA/|D_B/|C/'
    matches = re.findall(pattern, file_path)
    return matches[0].replace("/", "") if matches != [] else False

file_path = 'path/A_B/your/file.txt'
combinations = find_combinations(file_path)
print(combinations)
```
