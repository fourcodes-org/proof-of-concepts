### We can use the below command for disk mounting.
```sh
lsblk
sudo file -s /dev/xvdf
sudo mkdir -p /mnt/data
cd / & ls -ltrh
sudo mkfs -t xfs /dev/xvdf
sudo mount /dev/xvdf /mnt/data
sudo mount -a
lsblk & df -h
```
