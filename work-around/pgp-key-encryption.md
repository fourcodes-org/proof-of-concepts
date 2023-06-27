
_Installtion process_

Open terminal and run the following command to install gnupg tool.

```bash
sudo apt update
sudo apt install gnupg -y
```

_Generate Key_

Finally, you will see a screen like the following.

```bash
sudo gpg --gen-key
```

![image](https://user-images.githubusercontent.com/57703276/205430216-9cdc5bda-b47c-44de-aa13-678bafa2b74c.png)

Please note your pub id 1024D/D8EC56D2 2005-09-08 above. You will need it to export PGP key.

export key

You need to upload your PGP public key to Ubuntu’s key server so that it can be downloaded by anyone. Run the following command for it. Replace 1024D/D8EC56D2 2005-09-08 with the pub id of your key pair.

```bash
gpg --keyserver keyserver.ubuntu.com --send-keys 1024D/D8EC56D2 2005-09-08
```

If you want to simply export the key to another person run the following command. Replace admin@example.com with the email address you have used in step 2. 

```bash
gpg --armor --export admin@example.com > public_key.asc
```

Now you may send public_key.asc file to others. If you want to export the key to a readable text file, you may also run the following command.

```bash
gpg --armor --output key.txt --export admin@example.com
```

Now you may send the key.txt to others.

```bash
gpg --encrypt --recipient jinojoe main.py
```


decrypt

```py
import gnupg

Efile = "/home/dodo/Desktop/pgpg/sue.txt"
Dfile = "/home/dodo/Desktop/pgpg/sue.txt.gpg"

gpg = gnupg.GPG(gnupghome='/tmp', gpgbinary='/usr/bin/gpg',
                options=['--trust-model', 'always'])
priv_key = gpg.import_keys("/home/dodo/Desktop/pgpg/private.key")
with open(Dfile, 'rb') as a_file:
    status = gpg.decrypt_file(a_file, passphrase=None,
                              output=Efile, always_trust=True)

    print(status.ok)
    print(status.status)
    print(status.stderr)

gpg = gnupg.GPG(gnupghome='')
priv_key = gpg.import_keys("/home/dodo/Desktop/pgpg/private.key")
with open('Efile', 'rb') as f:
    status = gpg.encrypt_file(
        f, recipients=['jinojoe@gmail.com'],
        output='Dfile'
    )
    print(status.ok)
    print(status.status)
    print(status.stderr)

# gpg --list-secret-keys user@some.com
# gpg --export-secret-keys YOUR_ID_HERE > private.key
# aws s3 mv private.key s3://your_s3_bucket/

```

_encryption key creation_

```py

import gnupg
import re
class pgp_encrypt_and_decrypt():
    tempdir = "/tmp/"

    def __init__(self, name_of_email):
        self.name_of_email = name_of_email
        self.gpg = gnupg.GPG()

    def generate_gpg_key(self):
        input_data = self.gpg.gen_key_input(name_email=self.name_of_email)
        key = self.gpg.gen_key(input_data)
        ascii_armored_private_keys = self.gpg.export_keys(keyids=key.fingerprint)
        name_of_export_file = self.tempdir + re.split(r'@', self.name_of_email)[0] + ".asc"

        with open(name_of_export_file, 'w') as f:
            f.write(ascii_armored_private_keys)

        return name_of_export_file

key = pgp_encrypt_and_decrypt("agency02@bca.gov.sg")
print(key.generate_gpg_key())
```
