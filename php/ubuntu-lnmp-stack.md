## ubuntu-lnmp-stack.md

| USERNAME | IP ADDRESS | PASSWORD | OPERATING SYSTEM | DOMAIN | SSL CERTIFICATE |
|---|---|---|---|---|---|
|ubuntu|20.222.90.150|Password@123| ubuntu | fourtimes.ml | |

_Configure the nginx_

```bash
sudo apt update && sudo apt upgrade
sudo apt install nginx

```
**NGINX installation verification**

after instaling the nginx package, use this commmand to verification the nginx package
```bash
nginx -v

```
**Configuration of Nginx**

we consider as a domain fourtims.ml

create the document root for this vhost configuration

```bash
sudo mkdir -p /var/www/fourtimes.ml
sudo vim /var/www/fourtimes.ml/index.html

```
**remove the default domain**

Take a backup before deleting the default package.

```bash

rm -rf etc/nginx/sites-enabled/default
rm -rf etc/nginx/sites-available/default
```

**vhost configuration**

```bash

/etc/nginx/sites-enabled/fourtimes.ml.conf
```

```bash

server {
    listen       80;
    server_name  fourtimes.ml;
    
    access_log           /var/log/nginx/fourtimes.ml.access.log;
    error_log            /var/log/nginx/fourtimes.ml.error.log;
    
    
    location / {
        root   /var/www/fourtimes.ml;
        index  index.html index.htm;
    }
}

```


**validation the nginx**

```bash

nginx -t
```

**restart the service**

```bash

systemctl stop nginx
systemctl start nginx 
```

It will give your domain insecure access. We can get to http://fourtimes.ml using a browser.


_Configure the MySQL_

**install mysql-service**

```bash

sudo apt update
sudo apt-get install mysql-server -y

```

check running status on the server using

```bash

sudo systemctl status mysql.service
```


_Configure the PhpMyAdmin_

```bash
sudo apt install phpmyadmin

```

_Configure the Php_

 **PHP**


PHP is the language that is mostly used for server-side programming. It is executed, run, and must be installed on the webserver. Since it is an interpreted language, it doesn’t need any compiler. PHP handles the interaction between the front-end of the web pages and the back-end servers or databases.

**Installation of PHP on Ubuntu 20.04 LTS**

Before getting started with the installation of PHP, first, always update Ubuntu’s package repository.

```bash
sudo apt update
```

Next, install software-properties-common, which adds management for additional software

```bash
sudo apt -y install software-properties-common
```
Next, install the repository ppa:ondrej/php, which will give you all your versions of PHP:

```bash
sudo add-apt-repository ppa:ondrej/php
```

You have Nginx installed to serve your content and MySQL installed to store and manage your data. Now you can install PHP to process code and generate dynamic content for the web server.

While Apache embeds the PHP interpreter in each request, Nginx requires an external program to handle PHP processing and act as a bridge between the PHP interpreter itself and the web server. This allows for a better overall performance in most PHP-based websites, but it requires additional configuration. You’ll need to install php-fpm, which stands for “PHP fastCGI process manager”, and tell Nginx to pass PHP requests to this software for processing. Additionally, you’ll need php-mysql, a PHP module that allows PHP to communicate with MySQL-based databases. Core PHP packages will automatically be installed as dependencies.

To install the php-fpm and php-mysql packages, run:

```bash
sudo apt install php-fpm php-mysql

```

**Check the version installed:**

```bash
php -v
```


_Configure the Vsftpd_

**package installation**

```bash

sudo apt update
sudo apt install vsftpd -y
```

```bash
sudo vim /eyc/vsftpd.conf
```

```bash
# sudo vim /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=NO
idle_session_timeout=600
data_connection_timeout=120
ascii_upload_enable=YES
ascii_download_enable=YES
ftpd_banner=Welcome to fourtimes.ml FTP service.
chroot_local_user=NO
chroot_list_enable=YES
user_config_dir=/etc/vsftpd/fourusers
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
chroot_list_file=/etc/vsftpd.chroot_list
userlist_enable=YES
userlist_file=/etc/vsftpd.chroot_list
userlist_deny=NO


```
**create vsftpd userlist**

```bash
sudo mkdir -p /etc/vsftpd/fourusers

sudo mkdir -p /var/www/fourtimes.ml
sudo chown -R ubuntu:ubuntu /var/www/fourtimes.ml
echo "local_root=/var/www/fourtimes.ml" | sudo tee  /etc/vsftpd/fourusers/user
```
