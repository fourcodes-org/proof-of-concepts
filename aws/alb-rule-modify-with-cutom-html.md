

```bash
aws elbv2 modify-listener --listener-arn  "arn:aws:elasticloadbalancing:ap-xx-1:xxxxx:listener/app/alb-cnxcp-prdizrouting-xxxx/xxxx/xxx" \ --default-actions file://actions.json

```


action.json

```json
[
  {
    "Type": "fixed-response",
    "Order": 1,
    "FixedResponseConfig": {
      "MessageBody": "<!doctype html>\n<title>Site Maintenance</title>\n<style>\n  body { text-align: center; padding: 150px; }\n  h1 { font-size: 50px; }\n  body { font: 20px Helvetica, sans-serif; color: #333; }\n  article { display: block; text-align: left; width: 650px; margin: 0 auto; }\n  a { color: #dc8100; text-decoration: none; }\n  a:hover { color: #333; text-decoration: none; }\n</style>a\n<article>\n    <h1>We&rsquo;ll be back soon!</h1>\n    <div>\n        <p>Sorry for the inconvenience but we&rsquo;re performing some maintenance at the moment. If you need to you can always <a href=\"mailto:\">contact us</a>, otherwise we&rsquo;ll be back online shortly!</p>\n        <p>&mdash; The Team</p>\n    </div>\n</article>",
      "StatusCode": "503",
      "ContentType": "text/html"
    }
  }
]
```
