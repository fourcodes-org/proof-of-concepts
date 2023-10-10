
_function htpp trigger_

```cnf
WEBSITE_RUN_FROM_PACKAGE = 1
```

```bash
curl -X POST \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/binary" \
  --data-binary @app.zip\
  "https://januo-fn.scm.azurewebsites.net/api/zipdeploy"
```
