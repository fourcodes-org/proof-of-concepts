_aws-apigateway-authorization-use-iam-role_

aws IAM ROLE authentication should be enabled like this.

![image](https://user-images.githubusercontent.com/57703276/220544675-9232f6c9-deb9-4103-90a3-d8a4d0e72132.png)

apigateway should be configure like this

![image](https://user-images.githubusercontent.com/57703276/220544832-e8caa984-443a-48fb-863f-adf8b1930d62.png)



create the user and attach it to a group. The following policy should be attached at the group level.

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["execute-api:Invoke"],
      "Resource": [
        "arn:aws:execute-api:ap-southeast-1:<aws account number>:<api id>/*/GET/bds"
      ]
    },
    {
      "Effect": "Deny",
      "Action": ["execute-api:Invoke"],
      "Resource": [
        "arn:aws:execute-api:ap-southeast-1:<aws account number>:<api id>/*/GET/gino"
      ]
    }
  ]
}
```

finally you should scrap the acces key and secret key from the user security credentials. open the postman under the authorization section you should select the `AWS Signature` and provide the appropriate values.

_success message_

![image](https://user-images.githubusercontent.com/57703276/220546560-7df683e7-ef23-45e0-8627-95e85390258f.png)

_deny message_

![image](https://user-images.githubusercontent.com/57703276/220546870-019dc3b2-57df-4a5f-b877-6a579bc4d074.png)


```py
import requests
from aws_requests_auth.boto_utils import AWSRequestsAuth

region = 'ap-southeast-1'

def request_api(api_id: str, api_key=None): 
    host = api_id+'.execute-api.'+region+'.amazonaws.com'
    base_url = f'https://{host}/Prod'
    get_url = f'{base_url}/hello'

    ACCESS_KEY='xxxxxxxxxxx'
    SECRET_ACCESS_KEY='xxxxxxxxxxxxxxxxxxx'
    auth = AWSRequestsAuth(aws_host=host, aws_region=region, aws_service='execute-api', aws_access_key=ACCESS_KEY, aws_secret_access_key=SECRET_ACCESS_KEY)
    response = requests.get(get_url, timeout=2, auth=auth)

    return response

response = request_api('acmulXXXXX')
print (response.text)

```


_conditional json policy_

```js
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["execute-api:Invoke"],
        "Resource": [
          "arn:aws:execute-api:ap-southeast-1:<aws account number>:<api id>/*/GET/bds"
        ],
        "Condition" : { "StringEquals" : { "aws:username" : "johndoe" }}
      },
      {
        "Effect": "Deny",
        "Action": ["execute-api:Invoke"],
        "Resource": [
          "arn:aws:execute-api:ap-southeast-1:<aws account number>:<api id>/*/GET/gino"
        ],
        "Condition" : { "StringEquals" : { "aws:username" : "johndoe" }}
      }
    ]
}
```



_multiple rule access_

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:ap-south-1:ACCOUNT:APIID/dev/GET/gino"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:ap-south-1:ACCOUNT:APIID/dev/GET/demo"
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "execute-api:Invoke",
            "Resource": "arn:aws:execute-api:ap-south-1:ACCOUNT:APIID/STAGENAME/METHOD/PATH"
        }
    ]
}

```
