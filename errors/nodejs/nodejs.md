ERROR 1
-------
When we try to get a reponse in nodejs from webserver. we will get this error.
![image](https://github.com/januo-org/proof-of-concepts/assets/91359308/e3582edd-19f4-4022-9720-ce21d4f30bd6)
**Solution**
```bash
1. We have to check the nodejs code running or not. In case not running, we need to run that code. after that we have to use `curl -l (app-server-ip-address):(nodeport)` command from the webserver.

example:
in app(node) server,
`node index.js` or 'nodemon index.js`
```
