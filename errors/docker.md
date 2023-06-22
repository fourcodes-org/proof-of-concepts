ERROR 1
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/8bda759d-370e-4a9e-b74a-7a12f43ec0b1)
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/30ae65e1-d72b-4f44-9d7a-e968d3e9a0ce)
**Solution**
```bash
sudo chmod 664 /var/run/docker.sock
```
ERROR 2
-------
When try to launch mysql docker container. it says some error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/2c4e7ffe-b290-4e76-b4e1-3d491d6451a2)
**Solution**
```bash
ss -tulpn | grep 3306
sudo systemctl stop mysql
```
ERROR 3
-------
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/753e85cd-3644-4880-9995-562eeaa5fd28)
**Solution**
```bash
1. Check the network connectivity for local
2. In case if we are using instance, check the igw connection and outbound rules too.
```

ERROR 4
-------
When we try to get a reponse in nodejs from webserver. we will get this error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e3582edd-19f4-4022-9720-ce21d4f30bd6)
**Solution**
```bash
1. We have to check the nodejs code running or not. In case not running, we need to run that code. after that we have to use `curl -l (app-server-ip-address):(nodeport)` command from the webserver.

example:
in app(node) server,
`node index.js` or 'nodemon index.js`
```




