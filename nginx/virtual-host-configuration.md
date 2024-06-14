

`/etc/nginx/sites-available/wazuh.scanslips.in.conf`

```conf
server {

    # Listen rules
    listen       80;
    
    # Domain name
    server_name  wazuh.scanslips.in;
    
    # Log configurations
    access_log           /var/log/nginx/wazuh.scanslips.in.access.log;
    error_log            /var/log/nginx/wazuh.scanslips.in.error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; object-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; frame-ancestors 'self';" always;

    # Hide nginx version
    server_tokens off;
    
    # Document root
    location / {
        root   /var/www/wazuh.scanslips.in;
        index  index.html index.htm;
    }
    
    # Http to https redirect rule
    return 301 https://$host$request_uri;
}

server {

    # Listen rules
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    # Domain name
    server_name wazuh.scanslips.in;

    # Ssl configurations
    ssl_certificate      /etc/nginx/ssl-certificate/certificate.crt; 
    ssl_certificate_key  /etc/nginx/ssl-certificate/private.key;    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Log configurations
    access_log           /var/log/nginx/wazuh.scanslips.in.access.log;
    error_log            /var/log/nginx/wazuh.scanslips.in.error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; object-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; frame-ancestors 'self';" always;

    # Hide nginx version
    server_tokens off;

    # Document root
    location / {
        root   /var/www/wazuh.scanslips.in;
        index  index.html index.htm;
    }
}
```

# create the ssl cerficate directory

```console
mkdir /etc/nginx/ssl-certificate
sudo ln -s /etc/nginx/sites-available/wazuh-scanslips.in.conf /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```
