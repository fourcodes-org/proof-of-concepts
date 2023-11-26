
```bash
172.31.42.132 dcom4chee-server

sudo apt update
sudo apt upgrade -y
sudo apt install default-jdk -y
sudo apt install mysql-server -y
sudo apt install unzip -y
mysql -u root
CREATE USER 'dcom4chee'@'%' IDENTIFIED BY 'dcom4chee@123';
GRANT ALL PRIVILEGES ON *.* TO 'dcom4chee'@'%';
FLUSH PRIVILEGES;

cd /opt
wget https://sourceforge.net/projects/dcm4che/files/dcm4chee/2.18.3/dcm4chee-2.18.3-mysql.zip
unzip dcm4chee-2.18.3-mysql.zip
mv dcm4chee-2.18.3-mysql dcm4chee
```
