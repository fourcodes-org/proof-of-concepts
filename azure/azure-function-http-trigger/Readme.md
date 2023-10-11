
_function http trigger_

_configuration_

```cnf
WEBSITE_RUN_FROM_PACKAGE = 1
```

_deployment bash script_

```bash
curl -X POST \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/binary" \
  --data-binary @app.zip\
  "https://januo-fn.scm.azurewebsites.net/api/zipdeploy"
```

`__init.py__`

```py
import logging
import json
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Handle GET request
    if req.method == 'GET':
        return handle_get(req)

    # Handle POST request
    elif req.method == 'POST':
        return handle_post(req)

    # Handle other methods
    else:
        return func.HttpResponse("Method not allowed", status_code=405)

def handle_get(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        json.dumps({
            'method': req.method,
            'url': req.url,
            'headers': dict(req.headers),
            'params': dict(req.params),
            'get_body': req.get_body().decode()
        })
    )

def handle_post(req: func.HttpRequest) -> func.HttpResponse:
    try:
        req_body = req.get_json()
        return func.HttpResponse(
            json.dumps({
                'method': req.method,
                'url': req.url,
                'headers': dict(req.headers),
                'params': dict(req.params),
                'post_body': req_body
            })
        )
    except ValueError:
        return func.HttpResponse("Invalid JSON payload", status_code=400)
```

_function.json_

```json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [
        "get",
        "post"
      ]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "$return"
    }
  ],
  "scriptFile": "__init__.py",
  "entryPoint": "main",
  "disabled": false
}
```
