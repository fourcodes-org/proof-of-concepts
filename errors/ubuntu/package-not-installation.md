ERROR 1
-------
If the package is not installed on the terminal. We need to use **below command**. If that doesn't work, you need to change the **OS version**.

**_`Solution:`_**
```sh
# sudo vim /etc/apt/sources.list

deb http://archive.ubuntu.com/ubuntu focal universe
deb-src http://archive.ubuntu.com/ubuntu focal universe
```
----
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/c7c48cfe-3c51-453c-8a40-328ff978eb3e)
**_`Solution:`_**
```sh
# Inside the file remove the duplication entry.
sudo vim /etc/apt/sources.list.d/virtualbox.org.list
```
