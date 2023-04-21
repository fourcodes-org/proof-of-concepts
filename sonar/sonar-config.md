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

`Add`

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

















