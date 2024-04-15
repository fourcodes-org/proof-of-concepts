# Grafana keycloack single singOn implementation

```yml
---
version: '3'
services:
  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - 3000:3000
    restart: unless-stopped
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_SERVER_DOMAIN: "grafana-dashboard-client"
      GF_SERVER_ROOT_URL: "http://localhost:3000"
      GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
      GF_AUTH_GENERIC_OAUTH_NAME: "SingleSignOn"
      GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP: "true"
      GF_AUTH_GENERIC_OAUTH_CLIENT_ID: "grafana-dashboard-client"
      GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET: "h1UEkI7694zjC2dPRTpGhz75XwgL24u8"
      GF_AUTH_GENERIC_OAUTH_SCOPES: openid profile email 
      GF_AUTH_GENERIC_OAUTH_AUTH_URL: "https://keycloak.fourcodes.net/realms/fourcodes/protocol/openid-connect/auth"
      GF_AUTH_GENERIC_OAUTH_TOKEN_URL: "https://keycloak.fourcodes.net/realms/fourcodes/protocol/openid-connect/token"
      GF_AUTH_GENERIC_OAUTH_API_URL: "https://keycloak.fourcodes.net/realms/fourcodes/protocol/openid-connect/userinfo"
      GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH: contains(realm_access.roles[*], 'admin') && 'Admin' || contains(realm_access.roles[*], 'editor') && 'Editor' || 'Viewer'
      GF_AUTH_GENERIC_OAUTH_REDIRECT_URL: "http://localhost:3000/oauth/callback"
      GF_AUTH_GENERIC_OAUTH_LOGOUT_URL: "https://keycloak.fourcodes.net/realms/fourcodes/protocol/openid-connect/logout"
      # Additional session handling settings
      GF_SESSION_COOKIE_SECURE: "true"
      GF_SESSION_COOKIE_SAMESITE: "None" # or "Lax"
      GF_SESSION_LIFETIME: "3600" # Session lifetime in seconds, e.g., 1 hour
      GF_STRICT_FLUSH_INTERVAL: "true"
```

# Reference

https://stackoverflow.com/questions/68741412/grafana-generic-oauth-role-assignment
