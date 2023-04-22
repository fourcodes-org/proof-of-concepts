## SonarQube on Ubuntu server


SonarQube or formerly Sonar is an open-source platform for static code analysis and code security. It allows you to perform static code analysis and code quality to detect bugs and enhance application security. It also provides reports such as duplicate code, coding standards, code complexity, and security recommendation.

With sonarQube, you can automate static code analysis for 29 programming languages. You can easily integrate SonarQube with your existing CI/CD tools such as Jenkins, Azure DevOps, or IDE such as IntelliJ and Visual Code Studio.


**Prerequisites**

* An Ubuntu server 22.04 with UFW firewall enabled.
* A non-root user with sudo/administrator privileges.
* A domain name pointed to the Ubuntu server IP address.


**_Installing Java OpenJDK_**

```cmd
sudo apt update && sudo apt install default-jdk 
```
```cmd
java -version
```


**_Setting up System_**

- To install SonarQube on a Linux system, you must have a dedicated user that will be running SonarQube and some additional configurations such as ulimit and kernel parameters

_create a new user_

```cmd
sudo useradd -b /opt/sonarqube -s /bin/bash sonarqube
```

_kernel parameter values_

`Edit`

```cmd
sudo vim /etc/sysctl.conf
```

`Add`

```cnf
vm.max_map_count=524288
fs.file-max=131072
```

- To run the sysctl command below to apply new changes on the '/etc/sysctl.conf' file.

```cmd
sudo sysctl --system
```
**To set up ulimit for the SonarQube**

_ulimit configuration_

```cmd
sudo nano /etc/security/limits.d/99-sonarqube.conf
```

Add the following configuration

```cmd
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
```

**SonarQube Package installation**

```cmd
sudo apt install unzip software-properties-common wget 
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.6.1.59531.zip
unzip sonarqube-9.6.1.59531.zip
```
```cmd
mv sonarqube-9.6.1.59531 /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube
```

**_Configuring SonarQube_**

* Go to /opt/sonarqube/conf and make backup of original sonar.properties using `mv` command

```cmd
sudo mv /opt/sonarqube/conf/sonar.properties /opt/sonarqube/conf/sonar.properties.backup
```
_create conf file_

```cmd
sudo vim /opt/sonarqube/conf/sonar.properties
```

Add the following configuration 

```cnf
sonar.jdbc.username=sonarqube
sonar.jdbc.password=Password

sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError

sonar.web.host=192.168.1.100
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server

sonar.log.level=INFO
sonar.path.logs=logs

```
* Save the file and exit

**_create a new systemd service_**

```cmd
sudo vim /etc/systemd/system/sonarqube.service
```

Add the following configuration

```cnf
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonarqube
Group=sonarqube
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```

Reload the systemd manager

```cmd
sudo systemctl daemon-reload
```
Now start the sonarqube.service

```cmd
sudo systemctl start sonarqube.service
sudo systemctl enable sonarqube.service
```

```cmd
sudo systemctl status sonarqube.service
```

_Host entry to .._

```cmd
sudo vim /etc/hosts
```
```bash
cat <<EOF >> /etc/hosts
192.168.1.100
EOF
```
_Now chech browser_

http://192.168.1.100:9000



**Running SonarQube with Reverse Proxy**

_Install Nginx web server_

```cmd
sudo apt install nginx
```
_start the service_

```cmd
sudo systemctl is-enabled nginx
sudo systemctl status nginx
```

_Create a new server blocks configuration_

```cmd
sudo nano /etc/nginx/sites-available/sonarqube.conf


```cnf
server {

    listen 80;
    server_name sonarqube.in;
    access_log /var/log/nginx/sonar.access.log;
    error_log /var/log/nginx/sonar.error.log;
    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass http://192.168.1.100:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto http;
    }
}

```

* Activate the server block configuration 'sonarqube.conf' by creating a symlink of that file to the '/etc/nginx/sites-enabled' directory

```cmd
sudo ln -s /etc/nginx/sites-available/sonarqube.conf /etc/nginx/sites-enabled/
sudo nginx -t
```

_restart the nginx service_

```cmd
sudo systemctl restart nginx
```

_Host entry to .._

```cmd
sudo vim /etc/hosts
```
```bash
cat <<EOF >> /etc/hosts
192.168.1.100 sonarqube.in
EOF
```
_Now chech browser_

http://sonarqube.in/























































































