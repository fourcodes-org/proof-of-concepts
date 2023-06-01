_aws-api-gateway-lambda-dynamodb.md_


_lambda code_

```py
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = "api-data"

def lambda_handler(event, context):
    print(event['httpMethod'])

    if (event['httpMethod'] == 'GET'):
        data = get_records()
        print(data)
        return {
            "statusCode": 200,
            "body": json.dumps({"statusCode": 200,"data": data}),
            "headers": {
                "Content-Type": "application/json"
            }
        }

    elif (event['httpMethod'] == 'POST'):
        body = json.loads(event['body'])
        vname = 'name' in body.keys()
        vid = 'id' in body.keys()
        vdob = 'dob' in body.keys()
        if (vname == True and vid == True and vdob == True):

            name = body['name']
            id = body['id']
            dob = body['dob']
            data = create_records(name, id, dob)
            return data
        else:
            return {
                'statusCode': 400,
                "body": json.dumps({"statusCode": 400, "Message": "BadRequest"})
            }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid HTTP Method')
        }

def get_records():
    table = dynamodb.Table(table_name)
    response = table.scan()
    records = response['Items']
    return records

def create_records(name, id, dob):
    table = dynamodb.Table(table_name)
    print(name, id, dob)
    Item = {
        'name': name,
        'id': id,
        'dob': dob
    }
    response = table.put_item(Item=Item)
    return {
        'statusCode': 200,
        'body': json.dumps(response)
        
    } 
```
