## How to take a multi database with seperated file
- [ ]  _Open a terminal._
- [ ]  _Use the below script to perform the multiple db with separate file. The file name is - `sudo vim db.sh`_ 
```sh
#!/bin/bash

# MySQL credentials
username="enter_user_name"
password="enter_password_here"

# List all databases
databases=$(mysql -u "$username" -p"$password" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

# Loop through each database and take separate backups
for db in $databases; do
    mysqldump -u "$username" -p"$password" "$db" > "$db.sql"
done
```
- [ ]  After added the script in the file. we have to run the file using the command
```sh
bash db.sh
```

OUTPUT:
------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/460dca47-bd87-4f63-91d8-7e3fa672223a)
