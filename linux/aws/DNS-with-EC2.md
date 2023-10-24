# How to configure Internal Network using DNS
1. Create a VPC With a help of `10.0.0.0/24` ip range.
1. Then, Create a aws ec2 instance
2. In that instance private ip is `10.0.0.8`
3. Then, we need to follow the below cont

Solution:
--------
**Login as a root**
```
sudo -i
```
**Install BIND Packages**
```
apt -y install bind9 bind9utils
```
**Then, We need to follow the below configuraiton for the DNS.**

Configure BIND for Internal Network. In this case, our local network is [10.0.0.0/24].
```sh
# vim /etc/bind/named.conf

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
include "/etc/bind/named.conf.internal-zones";
```

```sh
## vim /etc/bind/named.conf.options

# add : set ACL entry for local network
acl internal-network {
        10.0.0.0/24;
};

options {
        directory "/var/cache/bind";

        # add local network set on [acl] section above
        # network range you allow to recieve queries from hosts
        allow-query { localhost; internal-network; };
        # network range you allow to transfer zone files to clients
        # add secondary DNS servers if it exist
        allow-transfer { localhost; };
        # add : allow recursion
        recursion yes;

        //=======================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //=======================================================================

        dnssec-validation auto;

        # if not listen IPV6, change [any] to [none]
        listen-on-v6 { any; };
};
```
```sh
# vim /etc/bind/named.conf.internal-zones

zone "srv.world" IN {
        type master;
        file "/etc/bind/srv.world.lan";
        allow-update { none; };
};
zone "0.0.10.in-addr.arpa" IN {
        type master;
        file "/etc/bind/0.0.10.db";
        allow-update { none; };
};
```
```sh
# vim /etc/default/named

# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind -4"
```
Create zone files that servers resolve IP address from Domain name.
The below uses Internal network [10.0.0.0/24], Domain name [srv.world].

```sh
# vim /etc/bind/srv.world.lan

$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        # any numerical values are OK for serial number
        # recommended : [YYYYMMDDnn] (update date + number)
        2022042601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define Name Server
        IN  NS      dlp.srv.world.

        # define Name Server's IP address
        IN  A       10.0.0.8           ## ec2 private ip

        # define Mail Exchanger Server
        IN  MX 10   dlp.srv.world.

# define each IP address of a hostname
dlp     IN  A       10.0.0.8
www     IN  A       10.0.0.9  ### add another private ip
```
Create zone files that servers resolve IP address from Domain name.
The below uses Internal network [10.0.0.0/24], Domain name [srv.world].

```sh
# vim /etc/bind/0.0.10.db

$TTL 86400
@   IN  SOA     dlp.srv.world. root.srv.world. (
        2022042601  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
        # define Name Server
        IN  NS      dlp.srv.world.

# define each hostname of an IP address
8      IN  PTR     dlp.srv.world.
9      IN  PTR     www.srv.world. 
```
Restart the service.
```sh
systemctl restart named
```
Change DNS setting to refer to own DNS if need.
```sh
# vim /etc/netplan/01-netcfg.yaml

# change to self IP address
    nameservers:
        addresses: [10.0.0.8]
```
Restrict the file.
```
chmod 600 /etc/netplan/01-netcfg.yaml
```
```
netplan apply
```
Verify Name and Address Resolution. If [ANSWER SECTION] is shown, that's OK.
```
dig dlp.srv.world.

dig -x 10.0.0.30
```
```
nslookup dlp.srv.world

nslookup www.srv.world
```
![image](https://github.com/fourtimes/AWS/assets/91359308/24176cc0-8ea0-4742-bf0e-d9059ea7f774)


Reference - https://www.server-world.info/en/note?os=Ubuntu_22.04&p=dns&f=1
