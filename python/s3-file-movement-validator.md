
```py
import boto3
import time
import sys
import logging

class S3FileMonitor:
    def __init__(self, buckets_and_files):
        self.s3 = boto3.client('s3')
        self.buckets_and_files = buckets_and_files
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.INFO)
        logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)

    def check_file(self, bucket_name, file_key):
        try:
            self.s3.head_object(Bucket=bucket_name, Key=file_key)
            self.logger.info('\033[92m' + f'SUCCESS - File {file_key} detected in the bucket {bucket_name}' + '\033[0m')
            return True
        except Exception:
            self.logger.info('\033[93m' + f'WAITING - File {file_key} not detected in the bucket {bucket_name}' + '\033[0m')
            return False

    def monitor(self, bucket_name, file_key):
        start_time = time.time()
        while True:
            if self.check_file(bucket_name, file_key):
                break
            elapsed_time = time.time() - start_time
            if elapsed_time > 300:
                self.logger.error('\033[91m' + f'FAILURE - File {file_key} monitoring exceeded {elapsed_time} seconds. Exiting...' + '\033[0m')
                sys.exit(1)
            time.sleep(1)

    def run_monitor(self):
        for bucket, file in self.buckets_and_files:
            self.monitor(bucket, file)
```
