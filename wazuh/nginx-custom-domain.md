$$ Configuring-SSL-certificates-on-the-Wazuh-dashboard-using-NGINX $$

## Setting up NGINX as Reverse proxy

_Installing the NGINX software on the Wazuh dashboard_

```cmd
apt-get update
apt-get install nginx
```
_Start NGINX_

```cmd
systemctl start nginx
systemctl status nginx
```
* Edit the /etc/wazuh-dashboard/opensearch_dashboards.yml file and change the default dashboard port from 443 to another available port number
* change port 443 **to** 442 or 8443
```cmd
vim /etc/wazuh-dashboard/opensearch_dashboards.yml
```
```yml
server.host: 0.0.0.0
opensearch.hosts: https://127.0.0.1:9200
server.port: 8443
opensearch.ssl.verificationMode: certificate
# opensearch.username: kibanaserver
# opensearch.password: kibanaserver
opensearch.requestHeadersWhitelist: ["securitytenant","Authorization"]
opensearch_security.multitenancy.enabled: false
opensearch_security.readonly_mode.roles: ["kibana_read_only"]
server.ssl.enabled: true
server.ssl.key: "/etc/wazuh-dashboard/certs/wazuh-dashboard-key.pem"
server.ssl.certificate: "/etc/wazuh-dashboard/certs/wazuh-dashboard.pem"
opensearch.ssl.certificateAuthorities: ["/etc/wazuh-dashboard/certs/root-ca.pem"]
uiSettings.overrides.defaultRoute: /app/wazuh
opensearch_security.cookie.secure: true
```
* Navigate to the /etc/nginx/conf.d directory and create a wazuh.conf file for the certificate installation
```cmd
unlink /etc/nginx/sites-enabled/default
cd /etc/nginx/conf.d
touch wazuh.conf
```
_Edit `wazuh.conf`_

```cnf
server {
   listen 80 default_server;
   server_name <YOUR_DOMAIN_NAME>;
   location / {
      proxy_pass https://<WAZUH_DASHBOARD_IP>:<PORT_NUMBER>;
      proxy_set_header Host $host;
   }
}
```
```cnf
server {
    server_name wazuh.fourcodes.net;

    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/certificate/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/certificate/private.pem;

    location / {
        proxy_pass https://54.179.194.236:8443;
        proxy_set_header Host $host;
    }
}

server {
    if ($host = wazuh.fourcodes.net) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    server_name wazuh.fourcodes.net;
    return 404;
}
```
_check config_
```cmd
nginx -t
```

_Restart the NGINX service_
```cmd
sudo systemctl restart nginx
```
_Restart the Wazuh dashboard and the Wazuh server_

```cmd
sudo systemctl restart wazuh-dashboard
sudo systemctl restart wazuh-manager
```

_**Access the Wazuh dashboard via the configured domain name**_

```url
wazuh.fourcodes.net
```
