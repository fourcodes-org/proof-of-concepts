
Create the SFTP private key on one of the Linux machines using the following command to generate the keys:

```bash
ssh-keygen -f sftp-server-key
```

Once the key generation process is complete, the file will be generated in the specified location. Alternatively, you can search for it using the name "sftp-server-key." Copy the contents of the "sftp-server-key.pub" file and paste it into the server's authorized keys location.

Note: When creating an SSH key, refrain from setting any passwords for those keys.

Convert the private key file to RSA format before copying it. By default, the private key file is in the OpenSSH format, and it needs to be modified to PEM format. Utilize the following command to convert it:

```bash
ssh-keygen -p -m PEM -f sftp-server-key
```

This command will overwrite the file in the same location, so ensure that the keys are updated with the latest timestamp. If the key is already in the RSA format, avoid performing any conversion.

Next, convert the key into a base64-encoded format for storage in the secret manager. Execute the following command to convert the content from the private key file, giving it a different name:

```bash
base64 -w 0 < sftp-server-key > sftp-server-key-base64
```

Save the file and provide it to the person responsible for handling the secret manager. They will then be able to share the credentials.

Additionally, ensure to provide the following information to the concerned party:

1. SFTP Server Hostname: [insert hostname here]
2. Username Details: [insert username details here]


Sure, here's the paragraph with the key points and commands:

In this document, we have outlined the process of creating decryption and encryption key pairs using GPG (GNU Privacy Guard) for data security. To begin, we generate a private key for decryption by running the command: 

```bash
gpg --gen-key
```

During this step, we provide essential information such as the username and email address. Afterward, we can list the secret and public keys, if needed, with the following command:

```bash
gpg --list-secret-keys --keyid-format=long
gpg --list-keys
```

Following this, we create a 'gpg' directory to store the private key file and navigate to it using the commands:

```bash
mkdir gpg
cd gpg/
```

To export the private key for safekeeping, we execute the command:

```bash
gpg --export-secret-keys -a "januo" > januo-private-key.asc
```

Additionally, we can import the private key on other systems if required with the command:

```bash
gpg --import januo-private-key.asc
```

For encryption, we use the public key associated with an email address and apply it to the desired file, 'demo.txt', for example:

```bash
gpg --recipient "januo@pm.me" --encrypt demo.txt
```

To create a public key for encryption, we list the available keys and export the specific public key into a designated file, 'januo-public-key.asc', using the command:

```bash
gpg --list-keys
gpg --armor --export 9A35AFFC9C70CB43D160343C37A89C98857A7D57 > januo-public-key.asc
```

It is vital to maintain utmost security and regular backups of private keys to ensure data confidentiality and integrity throughout the process.





_decryption private key creation_

```bash
 gpg --gen-key
    # username januo
    # email address januo@pm.me
 gpg --list-secret-keys --keyid-format=long
 gpg --list-keys
 mkdir gpg
 cd gpg/
 gpg --export-secret-keys -a "januo" > januo-private-key.asc
 gpg --import januo-private-key.asc
 gpg --recipient "januo@pm.me" --encrypt demo.txt 
```

_encryption public key creation_

```py
gpg --list-keys
gpg --armor --export 9A35AFFC9C70CB43D160343C37A89C98857A7D57 > januo-public-key.asc

```

_lambda code_


```py
import json
import gnupg
import re
import os
import pathlib
import boto3
import urllib


s3_bucket_name = "januo-s3-bucks"
KEYS_STORE_BUKCET = "sftp-pgpkey"

class GnuPGHandler:

    TEMP_DIRECTORY = "tmp"
    def __init__(self, recipient_email):
        self.recipient_email = recipient_email
        self.gpg = gnupg.GPG(gnupghome=os.path.join("/", self.TEMP_DIRECTORY + "/"), gpgbinary='/opt/python/gpg', verbose=True)

    def generate_gpg_key(self):
        input_data = self.gpg.gen_key_input(name_email=self.recipient_email)
        key_gen_result = self.gpg.gen_key(input_data)
        private_key_data = self.gpg.export_keys(key_gen_result.fingerprint, secret=True)
        public_key_data = self.gpg.export_keys(key_gen_result.fingerprint)
        export_file_name = os.path.join("/", self.TEMP_DIRECTORY + "/") + re.split(r'@', self.recipient_email)[0] + ".asc"

        with open(export_file_name, 'w') as f:
            f.write(private_key_data)
            f.write(public_key_data)

        return export_file_name

    def encrypt_file_with_gpg_key(self, key_file, input_file):
        if self.is_valid_file_for_encryption(input_file):
            return {
                "encryption_successful": False,
                "status_message": "Filetype is invalid"
            }
        else:
            key_data = open(key_file).read()
            self.gpg.import_keys(key_data)
            output_file = input_file + ".gpg"
            status = self.gpg.encrypt_file(input_file, recipients=[self.recipient_email], output=output_file, always_trust=True)
            return {
                "encryption_successful": status.ok,
                "status_message": status.status,
                "output_file": output_file
            }

    def decrypt_file_with_gpg_key(self, key_file, encrypted_file):
        if self.is_valid_file_for_encryption(encrypted_file):
            key_data = open(key_file).read()
            self.gpg.import_keys(key_data)
            output_file = os.path.splitext(encrypted_file)[0]
            status = self.gpg.decrypt_file(encrypted_file, output=output_file)
            return {
                "decryption_successful": status.ok,
                "status_message": status.status,
                "output_file": output_file
            }
        else:
            return {
                "decryption_successful": False,
                "status_message": "Filetype is invalid"
            }

    def is_valid_file_for_encryption(self, file_path):
        file_extension = pathlib.Path(file_path).suffix
        if file_extension in ['.asc', '.gpg', '.pgp']:
            return True
        else:
            return False

class S3EventInformation:
    def __init__(self, event, context):
        self.event = event
        self.context = context

    def get_event_name(self):
        return self.event['detail']['eventName']

    def get_event_bucket(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['bucketName'])
    
    def get_event_bucket_key(self):
        return urllib.parse.unquote_plus(self.event['detail']['requestParameters']['key'])


class S3Process:
    TEMP_DIRECTORY = "tmp"
    CHECKSUM_ALGORITHM = 'SHA256'

    def __init__(self, bucket: str, key: str):
        self.bucket = bucket
        self.key = key
        self.s3 = boto3.resource('s3')
        self.s3_client = boto3.client('s3')
        self.parent_path = pathlib.PurePath(self.key).parent
        self.child_name = pathlib.PurePath(self.key).name

    def download(self) -> str:
        download_location = os.path.join("/", self.TEMP_DIRECTORY + "/") + self.child_name
        self.s3.meta.client.download_file(self.bucket, self.key, download_location)
        return download_location

    def agent_key_download(self, bucket: str, agent_name: str) -> str:
        file_name = agent_name + ".asc"
        download_location = os.path.join("/", self.TEMP_DIRECTORY + "/") + file_name
        self.s3.meta.client.download_file(bucket, file_name, download_location)
        return download_location
    
    def delete(self, destination_bucket: str = None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        return self.s3_client.delete_object(Bucket=target_bucket, Key=self.key)

    def upload(self, file_path: str, destination_bucket: str = None, destination_path: str = None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        destination_path = destination_path if destination_path is not None else file_path
        return self.s3.meta.client.upload_file(file_path, target_bucket, destination_path)

    def create_new_tag(self, t_name: str, t_value: str, t_key: str = None):
        tagging = {'TagSet': [{'Key': t_name, 'Value': t_value}]}
        t_key = t_key if t_key is not None else self.key
        return self.s3_client.put_object_tagging(Bucket=self.bucket, Key=t_key, Tagging=tagging)

    def object_state(self) -> bool:
        return 'Contents' in self.s3_client.list_objects(Bucket=self.bucket, Prefix=self.key)

    def update_tags(self, destination_bucket: str = None, updation_tags: list = None):
        target_bucket = destination_bucket if destination_bucket is not None else self.bucket
        updation_tag_lists = updation_tags if updation_tags is not None else self.get_tags()
        return self.s3_client.put_object_tagging(Bucket=target_bucket, Key=self.key, Tagging={'TagSet': updation_tag_lists})

    def log_poster(self, event: str, state: str) -> str:
        return json.dumps({'event': event, 'bucket': self.bucket, 'fileName': self.key, 'processState': state})

    def ignore_path_position(self, path_position: int) -> str:
        data = re.split(r'/', self.key)
        return ("/".join(data[path_position:]))

    def copy(self, destination_bucket: str, custom_location: str = None):
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
    event_name = event_information.get_event_name()
    event_bucket = event_information.get_event_bucket()
    key = event_information.get_event_bucket_key()

    # event_bucket = "januo-s3-bucks"
    # key = "SFTP/IN/jinojoe/A_B/test_uat.pdf.gpg"

    s3_processor = S3Process(event_bucket, key)
    pgpEmailReceipt = "jinojoe@gmail.com"


    agent_name = re.split(r'/', key)[2]
    reformation_file_name = s3_processor.ignore_path_position(3)

    pgp_encryption = GnuPGHandler(pgpEmailReceipt)


    if (s3_processor.object_state()):
        if (pgp_encryption.is_valid_file_for_encryption(key)):
            print("please do decryption")
            decryption_agent_key_download = s3_processor.agent_key_download(event_bucket, agent_name)
            decryption_source_key_download = s3_processor.download()
            decryption_status = pgp_encryption.decrypt_file_with_gpg_key(decryption_agent_key_download, decryption_source_key_download)

            if (decryption_status['decryption_successful']):
                decrypted_file_location = decryption_status['output_file']
                gpg_process_state_location = 'SFTP/PROC/' + reformation_file_name
                uploaded_file_name = os.path.splitext(gpg_process_state_location)[0]
                s3_processor.upload(decrypted_file_location, event_bucket, uploaded_file_name)
                s3_processor.delete()
                os.remove(decryption_source_key_download)
                os.remove(decrypted_file_location)
            else:
                gpg_process_state_location = 'SFTP/FAILED/' + reformation_file_name
                s3_processor.copy(event_bucket, gpg_process_state_location)
                s3_processor.delete()
                os.remove(decryption_source_key_download)

            os.remove(decryption_agent_key_download)
        else:
            gpg_process_state_location = 'SFTP/PROC/' + reformation_file_name
            s3_processor.copy(event_bucket, gpg_process_state_location)
            s3_processor.delete()
    else:
        s3_processor.logPoster(event_bucket, "unknown events")
```

_key generation_

```py
        
def key_creation():
    locatio = pgp_encryption.generate_gpg_key()
    print(locatio)
    s3_processor.upload(locatio)

    key = "A_B/test_uat.pdf"
    s3_processor = S3Process(event_bucket, key)
    input_file = s3_processor.download()

    keyfile = "/tmp/jinojoe.asc"
    s3_processor = S3Process(event_bucket, keyfile)
    key_file = s3_processor.download()
    encrypt_file_with_gpg_key = pgp_encryption.encrypt_file_with_gpg_key(key_file, input_file)
    upload_key = encrypt_file_with_gpg_key['output_file']
    s3_processor.upload(upload_key, s3_bucket_name, upload_key)


```
