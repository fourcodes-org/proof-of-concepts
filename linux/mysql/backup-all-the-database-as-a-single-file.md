## How to backup all the database as a single file
- [ ] _Open a terminal_
- [ ] _Use the below command to perform the all db backup:_
```sh
mysqldump -u (your_username) -p --all-databases > (backup.sql)

# example
mysqldump -u root -p --all-databases > all-db-backup.sql
```
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/9e8120cb-2b92-4e52-9927-eca822632a36)
