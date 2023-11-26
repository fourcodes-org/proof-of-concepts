
```bash
172.31.42.132 dcom4chee-server

sudo apt update
sudo apt upgrade -y
sudo apt install default-jdk -y
sudo apt install mysql-server -y
sudo apt install unzip -y
mysql -u root
CREATE USER 'dcom4chee'@'%' IDENTIFIED BY 'dcom4chee@123';
CREATE DATABASE dcomdb;
GRANT ALL PRIVILEGES ON *.* TO 'dcom4chee'@'%';
FLUSH PRIVILEGES;

cd /opt
wget https://sourceforge.net/projects/dcm4che/files/dcm4chee-arc-light5/5.31.1/dcm4chee-arc-5.31.1-mysql.zip
unzip dcm4chee-arc-5.31.1-mysql.zip
mv dcm4chee-arc-5.31.1-mysql dcm4chee
rm -rf dcm4chee-arc-5.31.1-mysql.zip

mysql -u dcom4chee -pdcom4chee@123 dcomdb < /opt/dcm4chee/sql/mysql/create-mysql.sql

sudo apt install slapd ldap-utils -y

cp -r /opt/dcm4chee/ldap/schema/* /etc/ldap/schema/

vim /etc/ldap/ldap.conf

include         /etc/ldap/schema/core.schema
include         /etc/ldap/schema/dicom.schema
include         /etc/ldap/schema/dcm4che.schema
include         /etc/ldap/schema/dcm4chee-archive.schema
include         /etc/ldap/schema/dcm4chee-archive-ui.schema


wget https://sourceforge.net/projects/jboss/files/JBoss/JBoss-6.0.0.Final/jboss-as-distribution-6.0.0.Final.zip
unzip jboss-as-distribution-6.0.0.Final.zip
mv jboss-6.0.0.Final jboss
rm -rf jboss-as-distribution-6.0.0.Final.zip

wget https://github.com/wildfly/wildfly/releases/download/29.0.1.Final/wildfly-29.0.1.Final.zip
mv wildfly-29.0.1.Final wildfly

```
