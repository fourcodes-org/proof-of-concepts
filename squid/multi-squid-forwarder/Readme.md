_squid configuration_

|squid name | subnet range|
|---|---|
| iz-it-squid  | 192.168.10.2 |
| ez-it-squid  | 192.168.10.3 |
| ez-gut-squid | 192.168.10.4 |

_traffic flow_

     [Client]
        |
        | iz-it-squid   (192.168.10.2)
        |
        | ez-it-squid   (192.168.10.3)
        |
        | ez-gut-squid  (192.168.10.4)
        |
    [Internet]

_works_

```bash
docker network create --driver=bridge --subnet=192.168.10.0/24 s1

docker run -d --name container1 --network s1 jjino/iz-it-squid
docker run -d --name container2 --network s1 jjino/ez-it-squid
docker run -d --name container3 --network s1 jjino/ez-gut-squid

docker inspect container1

```


_debug_

```bash
tail -f /var/log/squid/access.log


```

`sudo vim /etc/environment`

```bash
http_proxy="http://192.168.10.2:3128/"
https_proxy="http://192.168.10.2:3128/"
```
