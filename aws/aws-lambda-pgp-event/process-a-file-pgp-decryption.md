_json secret manager credentials_

```json

```


```py
import json
import gnupg
import re
import os
import pathlib
import boto3
import urllib
import base64

region_name = os.environ.get('REGION_NAME')
allowed_agency_list_secret_name = os.environ.get('ALLOWED_AGENCY_LIST_SECRET_NAME')

class SecretManager:
    def __init__(self, region_name, secret_name):
        self.client = boto3.client('secretsmanager', region_name=region_name)
        self.secret_name = secret_name

    def retrieve_data(self):
        get_secret_value_response = self.client.get_secret_value(
            SecretId=self.secret_name)
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)

    @property
    def unique_agency_info(self):
        return self.retrieve_data()
    
class GnuPGHandler:

    TEMP_DIRECTORY = "tmp"
    def __init__(self, recipient_email, verbose=False):
        self.recipient_email = recipient_email
        self.verbose = verbose
        self.gpg = gnupg.GPG(gnupghome=os.path.join("/", self.TEMP_DIRECTORY + "/"), gpgbinary='/opt/python/gpg', verbose=self.verbose)

    def encrypt_file_with_gpg(self, encoded_public_key, input_file):
        if self.check_file_extension(input_file):
            return {'encryption_successful': False, 'status_message': 'Filetype is invalid'}
        else:
            public_key_data = base64.b64decode(encoded_public_key)
            self.gpg.import_keys(public_key_data)
            output_file = input_file + ".gpg"
            status = self.gpg.encrypt_file(input_file, recipients=[self.recipient_email], output=output_file, always_trust=True)
            return {'encryption_successful': status.ok, 'status_message': status.status, 'output_file': output_file}

    def decrypt_file_with_gpg(self, encoded_private_key, encrypted_file):
        if self.check_file_extension(encrypted_file):
            private_key_data = base64.b64decode(encoded_private_key)
            self.gpg.import_keys(private_key_data)
            output_file = os.path.splitext(encrypted_file)[0]
            status = self.gpg.decrypt_file(encrypted_file, output=output_file)
            return {'decryption_successful': status.ok, 'status_message': status.status, 'output_file': output_file}
        else:
            return {'decryption_successful': False, 'status_message': 'Filetype is invalid'}

    def check_file_extension(self, file_path):
        file_extension = pathlib.Path(file_path).suffix
        status =  True if file_extension in ['.asc', '.gpg', '.pgp'] else False
        return status
    
class S3EventInformation:
    def __init__(self, event, context):
        self.event = event
        self.context = context
    @property
    def get_event_name(self):
        return self.event['detail']['eventName']
    @property
    def get_event_bucket(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['bucketName'])
    @property
    def get_event_bucket_key(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['key'])

class S3Process:
    TEMP_DIRECTORY = "tmp"
    CHECKSUM_ALGORITHM = 'SHA256'

    def __init__(self, bucket, key):
        self.bucket = bucket
        self.key = key
        self.s3 = boto3.resource('s3')
        self.s3_client = boto3.client('s3')
        self.parent_path = pathlib.PurePath(self.key).parent
        self.child_name = pathlib.PurePath(self.key).name

    def download(self):
        download_location = os.path.join("/", self.TEMP_DIRECTORY + "/") + self.child_name
        self.s3.meta.client.download_file(self.bucket, self.key, download_location)
        return download_location
  
    def delete(self, destination_bucket=None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        return self.s3_client.delete_object(Bucket=target_bucket, Key=self.key)

    def upload(self, file_path, destination_bucket=None, destination_path=None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        destination_path = destination_path if destination_path is not None else file_path
        return self.s3.meta.client.upload_file(file_path, target_bucket, destination_path)

    def create_new_tag(self, tag_name, tag_value, tag_key=None):
        tagging = {'TagSet': [{'Key': tag_name, 'Value': tag_value}]}
        tag_key = tag_key if tag_key is not None else self.key
        return self.s3_client.put_object_tagging(Bucket=self.bucket, Key=tag_key, Tagging=tagging)

    def object_state(self):
        return 'Contents' in self.s3_client.list_objects(Bucket=self.bucket, Prefix=self.key)

    def update_tags(self, destination_bucket=None, updation_tags=None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        updation_tag_lists = updation_tags if updation_tags is not None else self.get_tags()
        return self.s3_client.put_object_tagging(Bucket=target_bucket, Key=self.key, Tagging={'TagSet': updation_tag_lists})

    def log_poster(self, action, state):
        print(dict({'key': self.key, 'action': action, 'processed_state': state}))

    def ignore_path_position(self, path_position):
        data = re.split(r'/', self.key)
        return ("/".join(data[path_position:]))

    def copy(self, destination_bucket, custom_location=None):
        target_path = custom_location if custom_location is not None else self.key
        source = {'Bucket': self.bucket, 'Key': self.key}
        return self.s3_client.copy_object(
            CopySource=source,
            Bucket=destination_bucket,
            Key=target_path,
            TaggingDirective='COPY',
            ChecksumAlgorithm=self.CHECKSUM_ALGORITHM
        )


def lambda_handler(event, context):
    event_information = S3EventInformation(event, context)
    event_bucket = event_information.get_event_bucket
    key = event_information.get_event_bucket_key
    s3_processor = S3Process(event_bucket, key)
    agent_name = re.split(r'/', key)[2]
    retrieve_secret_data = SecretManager(region_name, allowed_agency_list_secret_name)
    unique_agency_info = retrieve_secret_data.unique_agency_info
    pgp_email_receipt_state = next((pgp_email_receipt[agent_name] for pgp_email_receipt in unique_agency_info['agencies'] if pgp_email_receipt.get(agent_name)), None)
    reformation_file_name = s3_processor.ignore_path_position(3)
    if (s3_processor.object_state() and pgp_email_receipt_state is not None):
        collect_specific_agent_details = unique_agency_info['agencies']
        pgp_email_receipt = collect_specific_agent_details[0][agent_name]['agent_receipt_email_address']
        agent_encoded_gpg_private_key = collect_specific_agent_details[0][agent_name]['agent_encoded_gpg_private_key']
        pgp_handle = GnuPGHandler(pgp_email_receipt)
        if (pgp_handle.check_file_extension(key)):
            decryption_source_key_download = s3_processor.download()
            decryption_status = pgp_handle.decrypt_file_with_gpg(agent_encoded_gpg_private_key, decryption_source_key_download)
            if (decryption_status['decryption_successful']):
                decrypted_file_location = decryption_status['output_file']
                gpg_process_state_location = 'SFTP/PROC/' + reformation_file_name
                uploaded_file_name = os.path.splitext(gpg_process_state_location)[0]
                s3_processor.upload(decrypted_file_location, event_bucket, uploaded_file_name)
                os.remove(decrypted_file_location)
                s3_processor.log_poster("SFTP", "The decryption process scuccess and transitioned to the 'SFTP Proc' state")
            else:
                gpg_process_state_location = 'SFTP/FAILED/' + reformation_file_name
                s3_processor.copy(event_bucket, gpg_process_state_location)
                s3_processor.log_poster("SFTP", "The decryption process failed and transitioned to the 'SFTP Failed' state")
            s3_processor.delete()
            os.remove(decryption_source_key_download)
        else:
            gpg_process_state_location = 'SFTP/PROC/' + reformation_file_name
            s3_processor.copy(event_bucket, gpg_process_state_location)
            s3_processor.delete()
            s3_processor.log_poster("SFTP", "The decryption process scuccess and transitioned to the 'SFTP Proc' state")
    else:
        s3_processor.log_poster(f"Rule mismatched or This file doesn't exists on {event_bucket}", "Process Rejected by Lambda")
```
