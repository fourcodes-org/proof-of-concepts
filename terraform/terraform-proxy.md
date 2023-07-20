_terraform proxy_

If you wish to implement the Terraform proxy, you will need the proxy server's IP address and details. Without this information, you won't be able to route the traffic through the proxy.

To proceed, open the file using the following command:

```
sudo vim /etc/environment
```

Then, add the following configurations under this file and save it:

```
http_proxy="http://192.168.10.2:3128/"
https_proxy="http://192.168.10.2:3128/"
```

You can create the Terraform resource with the help of proxy servers.
