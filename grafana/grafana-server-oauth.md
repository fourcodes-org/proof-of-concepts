

```conf
[server]
root_url = https://grafana.fourcodes.net/

[auth.generic_oauth]
enabled = true
name = Keycloak-OAuth
auto_login = false
allow_sign_up = true
tls_skip_verify_insecure = true
client_id = fourcodes-org-grafana-client
client_secret = yYKyLWtYVXQBFZAKYGXHteoctlrCnnJB
scopes = openid profile email roles
email_attribute_path = email
login_attribute_path = username
name_attribute_path = full_name
auth_url = https://keycloak.fourcodes.net/realms/fourcodes-org/protocol/openid-connect/auth
token_url = https://keycloak.fourcodes.net/realms/fourcodes-org/protocol/openid-connect/token
api_url = https://keycloak.fourcodes.net/realms/fourcodes-org/protocol/openid-connect/userinfo
role_attribute_path = contains(realm_access.roles[*], 'grafana_admin_role') && 'Admin' || contains(realm_access.roles[*], 'grafana_editor_role') && 'Editor' || 'Viewer'
groups_attribute_path = groups
logout_redirect_url = https://keycloak.fourcodes.net/realms/fourcodes-org/protocol/openid-connect/logout
```
