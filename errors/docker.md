ERROR 1
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/8bda759d-370e-4a9e-b74a-7a12f43ec0b1)
**Solution**
```bash
sudo chmod 664 /var/run/docker.sock
```
ERROR 2
-------
When try to launch mysql docker container. it says some error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/2c4e7ffe-b290-4e76-b4e1-3d491d6451a2)
**solution**
```bash
ss -tulpn | grep 3306
sudo systemctl stop mysql
```
