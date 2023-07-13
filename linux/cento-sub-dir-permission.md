**VSFTPD-CONF**

* In this configuration, we've added the "user_config_dir" option, which specifies the directory where user-specific configuration files will be stored. Create the directory `/etc/vsftpd/user_conf` and create separate configuration files for each user inside it.

* if you want to restrict user qrtest to the "qr" and "scan" folders, create a file named /etc/vsftpd/user_conf/john with the following content:


- [ ] sudo vim /etc/vsftpd/vsftpd.conf

```cnf
user_config_dir=/etc/vsftpd/user_conf
```
- [ ] sudo vim /etc/vsftpd/user_conf/qrtest

```cmd
sudo mkdir -p /etc/vsftpd/user_conf
```
- [ ] create file as `username` under user_conf dir

```cmd
sudo vim /etc/vsftpd/user_conf/kenny
```

_add this line_ 
```cnf
local_root=/webdata/qr
```

```cmd
sudo systemctl restart vsftpd
```

**USER**

```cmd
useradd qrtest
```
```cmd
passwd qrtest
```
_add user to existing main-group_
```cmd
sudo usermod -g kenny qrtest
```
_user group check_
```cmd
groups username
```

_add user to vsftps_user_list_

```cmd
vim /etc/vsftpd.userlist 
```
add in the vsftpd_userlist

```bash
qrtest
```
_file permission_

main user
```cmd
chown -R kenny:kenny /webdata
chmod -R 777 /webdata/
```

```cmd
chown user:group -R /webdata/test-qr
chmod 757 -R /webdata/test-qr
```

ftp dir permisson

```cmd
setsebool -P allow_ftpd_full_access on
```




