

```py
import paramiko
import io
import base64
import logging
import warnings

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
    def __init__(self, host, port, username, encoded_ssh_private_key, debug=False):
        self.host = host
        self.port = port
        self.username = username
        self.encoded_ssh_private_key = encoded_ssh_private_key
        self.debug = debug

        # Configure logging
        self.logger = CustomLogger(__name__, debug).get_logger()

    def connect(self):
        try:
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            decoded_private_key = base64.b64decode(self.encoded_ssh_private_key).decode("utf-8")
            private_key = paramiko.RSAKey.from_private_key(file_obj=io.StringIO(decoded_private_key))
            try:
                ssh_client.connect(self.host, port=self.port, username=self.username, pkey=private_key)
            except:
                ssh_client.connect(self.host, port=self.port, username=self.username, pkey=private_key, disabled_algorithms={'pubkeys': ['rsa-sha2-256', 'rsa-sha2-512']})
            if self.debug:
                self.logger.debug("Connected to %s", self.host)
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
                    self.logger.debug("Downloaded %s -> %s", remote_file_path, local_file_path)
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
                    self.logger.debug("Uploaded %s -> %s", local_path, remote_path)
            except Exception as e:
                self.logger.error("An error occurred: %s", str(e))
            finally:
                sftp_client.close()
                ssh_client.close()
```
