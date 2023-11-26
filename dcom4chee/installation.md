
```bash
172.31.42.132 dcom4chee-server

sudo apt update
sudo apt upgrade -y
sudo apt install default-jdk -y
sudo apt install mysql-server -y

mysql -u root
CREATE USER 'dcom4chee'@'%' IDENTIFIED BY 'dcom4chee@123';
GRANT ALL PRIVILEGES ON *.* TO 'dcom4chee'@'%';
FLUSH PRIVILEGES;

```
