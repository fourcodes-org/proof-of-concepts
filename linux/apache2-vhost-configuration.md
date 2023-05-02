#### apache2 configuration
---

**What is apache2**

Apache is the most commonly used Web server on Linux systems. Web servers are used to serve Web pages requested by client computers. Clients typically request and view Web pages using Web browser applications such as Firefox, Opera, Chromium, or Internet Explorer.

**_Requirements_**

|SERVER|IPADDRESS|
|---|---|
|Ubuntu| 192.168.0.10|

**_apache2 Installation_**

If the package cannot be found, run the commands below to install apache2.

```bash
sudo apt update
sudo apt install apache2 -y
```

**_apache2 installtion verification_**

Use this command to check the apache2 packages after they've been installed.

```bash
sudo apt list apache2 -a
```
**_service handling process_**

This command can be used to start the service and check its status.

```bash

sudo systemctl start apache2
sudo systemctl status apache2

```

**_apache2 listen ports_**

```bash

sudo ss -tulpn

```

**_apache file structure details_**

We can utilise the domain `dodo-found.tk` in this part.

|LOCATION| PURPOSE |
|---|---|
| /etc/apache2 | configuration files |
| /var/log/apache2 | logs files |
|/var/www/dodo-found.tk|Document Root |
|80|HTTP|
|443|HTTPs|


**HTTP vhost Configuration**
---

We can create a directory in the default path and modify the ownership and permissions.

```bash

sudo mkdir /var/www/dodo-found.tk
sudo chmod -R 755 /var/www/dodo-found.tk

```
Then create html file for website index page

```bash

echo "dodo-found.tk domain" | sudo tee  /var/www/dodo-found.tk/index.html

```

 _sample index file_
 
```bash

<html>
    <head>
        <title>Welcome to DoDo Foundation!</title>
    </head>
    <body>
        <h1>Success!  The DoDo found virtual host is working!</h1>
    </body>
</html>

```

disable the default configuration file

```bash

sudo a2dissite 000-default.conf

```
create the domain in the name of domain 

```bash

sudo vim /etc/apache2/sites-available/dodo-found.tk.conf

```

use this conf file

```bash

<VirtualHost *:80>

        ServerAdmin webmaster@dodo-found.tk
        Servername dodo-found.tk
        DocumentRoot /var/www/dodo-found.tk

        ErrorLog ${APACHE_LOG_DIR}/dodo-found.tk.error.log
        CustomLog ${APACHE_LOG_DIR}/dodo-found.tk.access.log combined
        
</VirtualHost>

```

Then enable your site, disable the old one, and restart the Apache2 server.

```bash
sudo a2ensite dodo-found.tk.conf
sudo systemctl reload apache2
```

**configuration of HTTP and HTTPS in apache2**
---

**What is SSL**

SSL stands for Secure Sockets Layer and, in short, it's the standard technology for keeping an internet connection secure and safeguarding any sensitive data that is being sent between two systems

First, enable SSL and refresh the server in this section.

```bash

# enable SSL
sudo a2enmod ssl
sudo a2enmod rewrite
sudo mkdir -p /etc/apache2/ssl
```

**Create SSL key for Below command line**

```bash

# optinal
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \ 
    -out /etc/ssl/certs/apache-selfsigned.crt

```

In this case im use `https://zerossl.com/` to create the ssl certificate


```bash

sudo vim /etc/apache2/sites-available/dodo-found.tk.conf

```

copy and past the below configuration in this file

```bash

# HTTP SECTION

<VirtualHost *:80>

        ServerAdmin webmaster@dodo-found.tk
        Servername dodo-found.tk
        DocumentRoot /var/www/dodo-found.tk
        Redirect permanent / https://dodo-found.tk/

        ErrorLog ${APACHE_LOG_DIR}/dodo-found.tk.error.log
        CustomLog ${APACHE_LOG_DIR}/dodo-found.tk.access.log combined
        
</VirtualHost>                 

# HTTPS SECTION

<VirtualHost *:443>

        ServerAdmin  webmaster@dodo-found.tk
        Servername   dodo-found.tk
        DocumentRoot /var/www/dodo-found.tk
        
        # HTTP TO HTTPS REDIRECTION
        SSLEngine                on
        SSLCertificateFile       /etc/apache2/ssl/certificate.crt
        SSLCertificateKeyFile    /etc/apache2/ssl/private.key
        SSLCertificateChainFile  /etc/apache2/ssl/ca_bundle.crt
        
        Protocols h2 http/1.1

        <If "%{HTTP_HOST} == 'www.example.com'">
              Redirect permanent / https://example.com/
        </If>
   
        # APACHE2 LOGS
        ErrorLog  ${APACHE_LOG_DIR}/dodo-found.tk.error.log
        CustomLog ${APACHE_LOG_DIR}/dodo-found.tk.access.log combined
        
</VirtualHost>
```

then reload Apache2 server

```bash

sudo systemctl reload apache2

```

Using your web browser, examine the output result



