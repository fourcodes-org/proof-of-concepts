_event structure_

```json
{'resource': '/users', 'path': '/users', 'httpMethod': 'POST', 'headers': None, 'multiValueHeaders': None, 'queryStringParameters': None, 'multiValueQueryStringParameters': None, 'pathParameters': None, 'stageVariables': None, 'requestContext': {'resourceId': 'aq13ag', 'resourcePath': '/users', 'httpMethod': 'POST', 'extendedRequestId': 'IGvR9FDkBcwFjlQ=', 'requestTime': '15/Jul/2023:12:34:58 +0000', 'path': '/users', 'accountId': '948582409830', 'protocol': 'HTTP/1.1', 'stage': 'test-invoke-stage', 'domainPrefix': 'testPrefix', 'requestTimeEpoch': 1689424498666, 'requestId': 'ff8cd0fe-5f2f-4f93-8aab-c6de28675fcb', 'identity': {'cognitoIdentityPoolId': None, 'cognitoIdentityId': None, 'apiKey': 'test-invoke-api-key', 'principalOrgId': None, 'cognitoAuthenticationType': None, 'userArn': 'arn:aws:iam::948582409830:root', 'apiKeyId': 'test-invoke-api-key-id', 'userAgent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0', 'accountId': '948582409830', 'caller': '948582409830', 'sourceIp': 'test-invoke-source-ip', 'accessKey': 'ASIA5ZW7K4ZTB5RBEJUP', 'cognitoAuthenticationProvider': None, 'user': '948582409830'}, 'domainName': 'testPrefix.testDomainName', 'apiId': 'v2x3eh6de5'}, 'body': '{\n\t"name": "gino",\n\t"id": "1"\n}', 'isBase64Encoded': False}

```


_aws-python-dynamodb-lambda_

```py
import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMO_DB_NAME')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    http_method = event.get('httpMethod')

    if http_method == 'GET':
        data = get_records()
        response = create_response(200, data)
    elif http_method == 'POST':
        body = json.loads(event['body'])
        required_keys = ['name', 'id', 'dob']
        if all(key in body for key in required_keys):
            record = {
                'name': body['name'],
                'id': body['id'],
                'dob': body['dob']
            }
            records = create_records(record)
            response = create_response(200, records)
        else:
            response = create_response(400, {'Message': 'BadRequest'})
    else:
        response = create_response(400, 'Invalid HTTP Method')

    return response

def get_records():
    response = table.scan()
    records = response['Items']
    return records

def create_records(record):
    response = table.put_item(Item=record)
    return response

def create_response(status_code, data):
    return {
        'statusCode': status_code,
        'body': json.dumps({'statusCode': status_code, 'data': data})
    }
```
