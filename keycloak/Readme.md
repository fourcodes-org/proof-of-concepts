# keycloak


```console
version: '3'
volumes:
  postgres_data:
    driver: local
services:
  postgres:
    image: postgres:16.0
    container_name: postgres
    hostname: postgres
    mem_limit: 1g
    cpu_shares: 1024
    security_opt:
      - no-new-privileges:true
    healthcheck:
      test: ["CMD", "pg_isready", "-q", "-d", "keycloak", "-U", "keycloakuser"]
      timeout: 45s
      interval: 10s
      retries: 10
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloakuser
      POSTGRES_PASSWORD: keycloakpass
    restart: on-failure:5
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    container_name: keycloak
    hostname: keycloak
    restart: on-failure:5
    environment:
      KC_HEALTH_ENABLED: true
      DB_VENDOR: POSTGRES
      DB_ADDR: postgres
      DB_DATABASE: keycloak
      DB_USER: keycloakuser
      DB_SCHEMA: public
      DB_PASSWORD: keycloakpass
      KEYCLOAK_ADMIN: rcms
      KEYCLOAK_ADMIN_PASSWORD: rcms
      KC_PROXY_ADDRESS_FORWARDING: true
      KC_HTTP_ENABLED: true
      KC_HOSTNAME_URL: https://auth.fourcodes.net
      KC_HOSTNAME_ADMIN_URL: https://auth.fourcodes.net
      KC_HOSTNAME_PATH: /
      KC_HOSTNAME_STRICT_HTTPS: true
      KC_HOSTNAME_STRICT: false
      KC_HOSTNAME_STRICT_BACKCHANNET: true
      KC_PROXY: edge
    ports:
      - '8080:8080'
    command:
      - start
    depends_on:
      - postgres
  proxy:
    image: docker.io/library/auth.fourcodes.net:latest
    container_name: proxy
    hostname: proxy
    restart: on-failure:5
    ports:
      - 80:80
      - 443:443
    depends_on:
      - keycloak
```

# monitor the keycloak



1. /health/live
2. /health/ready
3. /health/started
4. /health
5. /metrics


# perfomance

You have to increase buffer sizes.

On Linux systems, in `/etc/sysctl.conf` add those two lines :

 
```conf
# Allow a 25MB UDP receive buffer for JGroups
net.core.rmem_max = 26214400
# Allow a 1MB UDP send buffer for JGroups
net.core.wmem_max = 1048576
```
