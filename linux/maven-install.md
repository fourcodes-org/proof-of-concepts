# Installing Maven on Linux/Ubuntu


**_the Maven Binaries_**

```cmd
wget https://mirrors.estointernet.in/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xvf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3 /opt/
```
_Setting M2_HOME and Path Variables_

Add the following lines to the user profile file (.profile).

```bash
M2_HOME='/opt/apache-maven-3.6.3'
PATH="$M2_HOME/bin:$PATH"
export PATH
```
* execute `source .profile `to apply the changes.

```cmd
source .profile
```

_Verify the Maven installation_

Execute 

```cmd
mvn -version 
```
