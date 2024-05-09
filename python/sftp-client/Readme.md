

```py
import paramiko
import io
import base64
import logging
import os

class CustomLogger:
    def __init__(self, name, debug=False):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG if debug else logging.INFO)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        self.logger.addHandler(console_handler)
        self.debug = debug

    def get_logger(self):
        return self.logger

class SFTPManager:
    def __init__(self, host, port, username, encoded_ssh_private_key, timeout=1, debug=False):
        self.host = host
        self.port = port
        self.username = username
        self.encoded_ssh_private_key = encoded_ssh_private_key
        self.timeout = timeout
        self.debug = debug

        # Configure logging
        self.logger = CustomLogger(__name__, debug).get_logger()

    def connect(self):
        try:
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            decoded_private_key = base64.b64decode(self.encoded_ssh_private_key).decode("utf-8")
            private_key = paramiko.RSAKey.from_private_key(file_obj=io.StringIO(decoded_private_key))
            ssh_client.connect(self.host, port=self.port, username=self.username, pkey=private_key, timeout=self.timeout)
            try:
                ssh_client.connect(self.host, port=self.port, username=self.username, pkey=private_key, timeout=self.timeout)
            except:
                ssh_client.connect(self.host, port=self.port, username=self.username, pkey=private_key, timeout=self.timeout, disabled_algorithms={'pubkeys': ['rsa-sha2-256', 'rsa-sha2-512']})
            self.logger.debug("%s - Authentication (publickey) successful!", self.host) if self.debug else None
            return ssh_client
        except paramiko.AuthenticationException as auth_err:
            self.logger.error("Authentication failed: %s", str(auth_err))
            return None
        except paramiko.SSHException as ssh_err:
            self.logger.error("SSH connection failed: %s", str(ssh_err))
            return None
        except Exception as e:
            self.logger.error("An error occurred: %s", str(e))
            return None

    def download_file(self, remote_file_path, local_file_path):
        ssh_client = self.connect()
        if ssh_client:
            try:
                sftp_client = ssh_client.open_sftp()
                sftp_client.get(remote_file_path, local_file_path)
                sftp_client.remove(remote_file_path)
                if self.debug:
                    self.logger.debug("%s - Downloaded %s -> %s", self.host, remote_file_path, local_file_path)
            except Exception as e:
                self.logger.error("An error occurred: %s", str(e))
            finally:
                sftp_client.close()
                ssh_client.close()

    def upload_file(self, remote_path, local_path):
        ssh_client = self.connect()
        if ssh_client:
            try:
                sftp_client = ssh_client.open_sftp()
                sftp_client.put(local_path, remote_path)
                if self.debug:
                    self.logger.debug("%s - Uploaded %s -> %s", self.host, local_path, remote_path)
            except Exception as e:
                self.logger.error("An error occurred: %s", str(e))
            finally:
                sftp_client.close()
                ssh_client.close()
```

How to debug the code

```py
# Get global_debug_vars from environment
global_debug_vars = os.environ.get('global_debug_vars')

# Check if global_debug_vars is set to 'True' (as a string)
if global_debug_vars and global_debug_vars.lower() == 'true':
    logging.basicConfig(level=logging.DEBUG)

sftp_manager = SFTPManager(host=host, port=port, username=username, encoded_ssh_private_key=encoded_ssh_private_key, debug=True)
# Uploading a file
sftp_manager.upload_file(remote_path="main.txt", local_path="main.txt") 
# Downloading a file
sftp_manager.download_file(remote_file_path="main.txt", local_file_path="fourcodes.txt")
```
