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






















