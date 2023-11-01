![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/da7cba29-4533-49ef-8b5d-29630b860394)
Sol:
----
 Step 1: Go to the **/etc/yum.repos.d/** directory.
``` 
cd /etc/yum.repos.d/
```
Step 2: Run the below commands
``` 
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
``` 
Step 3: Now run the yum update
``` 
 yum update -y
``` 
