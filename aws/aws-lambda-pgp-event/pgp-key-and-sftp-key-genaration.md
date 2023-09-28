# README

This README file provides instructions on generating SFTP and PGP keys and converting them into base64-encoded format for storage in a secret manager. Follow the steps outlined below to ensure the security and proper handling of keys.

## SFTP Private Key Generation and Conversion

1. Create the SFTP private key on a Linux machine using the following command:
   ```
   ssh-keygen -f sftp-server-key
   ```

2. Copy the contents of the generated public key (`sftp-server-key.pub`) and paste it into the server's authorized keys location.

3. Convert the private key file to RSA format using the following command:
   ```
   ssh-keygen -p -m PEM -f sftp-server-key
   ```

   Note: Skip this step if the key is already in RSA format.

4. Convert the private key into a base64-encoded format:
   ```
   base64 -w 0 < sftp-server-key > sftp-server-key-base64
   ```

   Save the `sftp-server-key-base64` file and provide it to the person responsible for handling the secret manager.

5. Provide the following information to the concerned party:
   - SFTP Server Hostname: [insert hostname here]
   - Username Details: [insert username details here]

## PGP Encryption and Decryption Key Generation

1. Generate a private key for encryption and decryption using GPG (GNU Privacy Guard):
   ```
   gpg --gen-key
   ```

   Provide necessary information such as the username and email address.

2. List the secret and public keys:
   ```
   gpg --list-secret-keys --keyid-format=long
   gpg --list-keys
   ```

3. Export the private key for safekeeping:
   ```
   gpg --export-secret-keys -a "bca" > bca-private-key.asc
   ```

   Note: Import the private key on other systems if needed using `gpg --import bca-private-key.asc`.

4. For encryption, use the public key associated with an email address:
   ```
   gpg --recipient "bca@pm.me" --encrypt demo.txt
   ```

5. Create a public key for encryption:
   ```
   gpg --list-keys
   gpg --armor --export 9A35AFFC9C70CB43D160343C37A89C98857A7D57 > bca-public-key.asc
   ```

6. Convert the public and private keys into base64-encoded format:
   ```
   base64 -w 0 < bca-public-key.asc > bca-public-key-base64
   base64 -w 0 < bca-private-key.asc > bca-private-key-base64
   ```

   Save the base64-encoded key files and provide them to the person responsible for handling the secret manager.

7. Provide the following information to the concerned party:
   - Agent name: [insert agent name here]
   - Agent receipt email address: [insert receipt email address here]

Ensure to follow security best practices, maintain backups of private keys, and handle keys securely to maintain data confidentiality and integrity throughout the process.
