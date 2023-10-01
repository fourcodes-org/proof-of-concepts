```bash
docker-compose --env-file env/env.dynamic up -d
```

nano /etc/sysctl.conf

```bash
net.nf_conntrack_max = 131072
net.core.somaxconn = 131072
kernel.msgmnb = 131072
kernel.msgmax = 131072
fs.file-max = 131072
```

_default php-fpm module_

```bash
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
ftp
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xml
xmlreader
xmlwriter
zlib
[Zend Modules]
```
