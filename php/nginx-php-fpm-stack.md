

```bash
docker network create php-app-net
docker image pull nginx:alpine
docker run -d --name nginx nginx:alpine
docker container cp nginx:/etc/nginx/conf.d/default.conf .
docker rm -f nginx
```
_php-fpm container start_
```bash
docker container run -d --name php-fpm --restart always --network php-app-net -v ${pwd}/website/:/usr/share/nginx/html php:fpm
```

Modify the default NGINX configuration file based on your PHP-FPM configuration. NGINX does not support core PHP, so here we are using PHP-FPM

```conf
server {
    listen 80;
    server_name example.com;

    location / {
        root /usr/share/nginx/html;
        index index.php index.html;
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

_nginx container start_

```bash
docker container run -d --name nginx --restart always --network php-app-net -p 80:80 -v $(pwd)/website/:/usr/share/nginx/html -v $(pwd)/default.conf:/etc/nginx/conf.d/default.conf nginx:alpine
```

Access you application http://localhost
