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
