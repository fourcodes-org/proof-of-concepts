#  Install NFS Server and Client on Ubuntu 22.04

### Install NFS Kernel Server in Ubuntu

1. Before we do nfs kernel installing, let's first update the system packages.
```
sudo apt update
```
2. After update the packages, let's install the nfs-kernel-server
```sh
sudo apt install nfs-kernel-server
```
3. Create an NFS Export Directory
```
sudo mkdir -p /mnt/nfs_share
```
4. Give the directory owner permission for the NFS Export Directory.The Permissions means, we want all the client machines to access the shared directory, remove any restrictions in the directory permissions.

```
sudo chown -R nobody:nogroup /mnt/nfs_share/
```
5. Here we have given privillages to the  specified directory.
```sh
sudo chmod 777 /mnt/nfs_share/
```
**6. Grant NFS Share Access to Client Systems**
- You can provide access to a single client, multiple clients, or specify an entire subnet.
- In this guide, we have allowed an entire subnet to have access to the NFS share.
```sh
# sudo vim /etc/exports

/mnt/nfs_share  192.168.43.0/24(rw,sync,no_subtree_check)    # 192.168.43.0/24 - ip address depends on your system networks
```
**_Note :_**
- Suppose if we provide access to **single client** use this -  `/mnt/nfs_share  client_IP_1 (re,sync,no_subtree_check)`
-  Suppose if we provide access to **multiple client**, specify each client on a separate file
   ```
   /mnt/nfs_share  client_IP_1 (re,sync,no_subtree_check)
   /mnt/nfs_share  client_IP_2 (re,sync,no_subtree_check)
   ```

7. Export the NFS Share Directory
 ```sh
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```
8.  Allow NFS Access through the Firewall
```sh
sudo ufw allow from 192.168.43.0/24 to any port nfs
sudo ufw enable
sudo ufw status
```
_**Note:**_
- Suppose we are using EC2. The 8th step (firewall) is not mandatory. because we need to allow permission at the **security group** level.

### Install the NFS Client on the Client Systems

1. Install the NFS-Common Package
```
sudo apt update
sudo apt install nfs-common
```
2. Create an NFS Mount Point on Client
```sh
sudo mkdir -p /mnt/nfs_clientshare
```
3. Mount NFS Share on Client System
```sh
ifconfig     # identified the your system ip address
sudo mount 192.168.43.234:/mnt/nfs_share  /mnt/nfs_clientshare     # 192.168.43.234 - your system ip address
```
4. Testing the NFS Share on the Client System
```sh
cd /mnt/nfs_share/
touch file1.txt file2.txt file3.txt
```
Now head back to the NFS client system and check if the files exist.
```
ls -l /mnt/nfs_clientshare/
```
OUTPUT
---------
![image](https://github.com/fourtimes/linux/assets/91359308/6f191497-fb26-4ee8-93fb-ec7ed02ef35c)

---

Reference - https://www.tecmint.com/install-nfs-server-on-ubuntu/
