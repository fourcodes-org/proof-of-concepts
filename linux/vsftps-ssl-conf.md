_Generate SSL/TLS Certificates For vsftpd_

To enable FTP over TLS, you'll need an SSL/TLS certificate. You can either obtain a certificate from a trusted Certificate Authority (CA) or create a self-signed certificate for testing purposes.

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/vsftpd/ssl/private/vsftpd.pem -out /etc/vsftpd/ssl/private/vsftpd.pem
```

_Verify Certificate and Key Files_

```bash
openssl x509 -in /etc/vsftpd/ssl/private/vsftpd.pem -text -noout
openssl rsa -in /etc/vsftpd/ssl/private/vsftpd.pem -check
```
_configuration changes_

`sudo vim /etc/vsftpd.conf`

```cnf
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
xferlog_std_format=YES
log_ftp_protocol=YES
idle_session_timeout=600
data_connection_timeout=120
ascii_upload_enable=YES
ascii_download_enable=YES
ftpd_banner=Welcome to RVL-LIVE ftp service.
chroot_local_user=YES
chroot_list_enable=NO
user_config_dir=/etc/vsftpd/users
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
#rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
#rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
chroot_list_file=/etc/vsftpd.chroot_list
userlist_enable=YES
userlist_file=/etc/vsftpd.chroot_list
userlist_deny=NO
pasv_enable=YES
pasv_min_port=64000
pasv_max_port=64321
#port_enable=YES
pasv_address= # public-ipadd
pasv_addr_resolve=NO
##
#ssl
# Enable TLS
ssl_enable=YES
# Path to the SSL certificate and private key
rsa_cert_file=/etc/vsftpd/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/vsftpd/ssl/private/vsftpd.pem
# Allow only secure TLS connections
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
# Force TLS for data connections
#require_ssl_reuse=NO
#require_ssl_cert=NO
# Enable passive mode
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=40100
```

_privilegs assign_
```cmd
chown user:user /etc/vsftpd/ssl/private/vsftpd.pem 
chmod 600 /etc/vsftpd/ssl/private/vsftpd.pem
```
```cmd
sudo systemctl restart vsftpd.service
```

_To check Error and log_

```cmd
sudo tail /var/log/vsftpd.log
sudo journalctl -xe | grep vsftpd
nc -vz localhost 21
```
