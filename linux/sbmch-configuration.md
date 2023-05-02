
_installation apache2_


```bash
sudo apt install apache2 -y
sudo mkdir /var/www/sbmch.org.in
sudo chmod -R 775 /var/www/sbmch.org.in
echo "sbmch.org.in" | sudo tee  /var/www/sbmch.org.in/index.html
sudo a2dissite 000-default.conf
```
_ssl enable process_

```bash
sudo a2enmod ssl
sudo a2enmod rewrite
```
_apache ssl vhost configuration_

`sudo vim /etc/apache2/sites-available/sbmch.org.in`

```conf
<VirtualHost *:80>

        ServerAdmin webmaster@sbmch.in
        Servername sbmch.org.in
        DocumentRoot /var/www/sbmch.org.in
        
	Redirect permanent / https://sbmch.org.in/

        ErrorLog ${APACHE_LOG_DIR}/sbmch.org.in.error.log
        CustomLog ${APACHE_LOG_DIR}/sbmch.org.in.access.log combined
        
</VirtualHost>

<VirtualHost *:443>

        ServerAdmin  webmaster@sbmch.in
        Servername   sbmch.org.in
        DocumentRoot /var/www/sbmch.org.in
        
        # HTTP TO HTTPS REDIRECTION
        SSLEngine                on
        SSLCertificateFile       /etc/certs/sbmch_org_in.crt
        SSLCertificateKeyFile    /etc/certs/server.key
        SSLCertificateChainFile  /etc/certs/sbmch_org_in.ca-bundle

  	Protocols h2 http/1.1

  	<If "%{HTTP_HOST} == 'www.example.com'">
    	    Redirect permanent / https://example.com/
  	</If>
        
        # APACHE2 LOGS
        ErrorLog  ${APACHE_LOG_DIR}/sbmch.org.in.error.log
        CustomLog ${APACHE_LOG_DIR}/sbmch.org.in.access.log combined
        
</VirtualHost>


```

_custom vhost enable_

```bash
sudo a2ensite sbmch.org.in.conf
sudo systemctl reload apache2
```

_vsftpd installation_

```service
sudo mkdir -p /etc/vsftpd/users
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.original
```

`sudo vim /etc/vsftpd.conf`

```service
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
ftpd_banner=Welcome to sbmch.org.in FTP service.
chroot_local_user=NO
chroot_list_enable=YES
user_config_dir=/etc/vsftpd/users
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
ssl_enable=NO
chroot_list_file=/etc/vsftpd.chroot_list
userlist_enable=YES
userlist_file=/etc/vsftpd.chroot_list
userlist_deny=NO
```

_commands_

```bash
sudo chown -R upload-user:upload-user /var/www/sbmch.org.in
echo "local_root=/var/www/sbmch.org.in" | sudo tee  /etc/vsftpd/users/upload-user
echo "upload-user" | tee  /etc/vsftpd.chroot_list
systemctl restart vsftpd
systemctl status vsftpd
```

_MySQL installation_

```bash
sudo apt install mysql-server -y
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password by 'SmFudW8uaW9AbXlzcWw=';
create database ris_db;
```

_SQL Backup_

```bash
#!/usr/bin/env bash
TIMESTAMP=$(date +%Y%b%d)
BACKUP_DIR="/pacs-storage/backup/$TIMESTAMP"
MYSQL_USER=root
MYSQL_PASSWORD="SmFudW8uaW9AbXlzcWw="
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
mkdir -p $BACKUP_DIR
databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|mysql|performance_schema)"`
for db in $databases; do
  echo $db
  $MYSQLDUMP --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables --quick --single-transaction --databases $db | gzip > "$BACKUP_DIR/$db.gz"
done
```

_sql cron_

Cron job every night at midnight is a commonly used cron schedule.

```bash
0 0 * * * bash /var/scripts/mysql-backup.sh
```


_phpadmin configuration_

`sudo vim /etc/dbconfig-common/phpmyadmin.conf`

```conf
#dbc_dbuser='phpmyadmin'
#dbc_dbpass=''
#dbc_dbname='phpmyadmin'
```

```service
sudo dpkg-reconfigure phpmyadmin
sudo systemctl restart apache2
```

_php installation_

```bash
sudo apt install php php-mbstring php-zip php-gd php-json php-curl -y
```

_auto sync file movement_

```bash
sudo apt install inotify-tools
```

_script file for file movement process_

`vim /var/scripts/auto-file-process.sh`

```bash
#!/usr/bin/env bash

inotifywait -m -r -e create /pacs-storage |
while read file; do
    cp /pacs-storage/* /nas-storage
done
```

`vim /etc/systemd/system/file-movement.service`

```service
[Unit]
Description=auto-file-process shell script
[Service]
ExecStart=/var/scripts/auto-file-process.sh
[Install]
WantedBy=multi-user.target
```

_start the script_

```bash
sudo systemctl daemon-reload 
sudo systemctl enable file-movement.service
sudo systemctl start  file-movement.service
sudo systemctl status file-movement.service
```

_secondary storage installation_

```bash
pvcreate /dev/sdb /dev/sdc /dev/sdd
vgcreate pacs-vg /dev/sdb /dev/sdc /dev/sdd
lvcreate -l 100%FREE -n pacs-vg-pacs-lv pacs-vg
sudo mkfs.ext4 /dev/pacs-vg/pacs-vg-pacs-lv
sudo mount /dev/pacs-vg/pacs-vg-pacs-lv /pacs-storage/
```

_docker installation_

```service
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

_docker compose_

```service
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o docker-compose
sudo chmod +x docker-compose
mv docker-compose /usr/local/bin/
sudo mv docker-compose /usr/local/bin/
sudo docker-compose 
sudo usermod -a -G docker sbmch

```


_ssl cert creation_

```
openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr
```

_convert p7b to crt_

```bash
openssl pkcs7 -print_certs -in sbmch_org_in.p7b -out server.crt
```

After execution, it will return the `server.csr` and `server.key` files.
