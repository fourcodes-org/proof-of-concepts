

```yml
Parameters:
  dynamoDbName:
    Type: String
    Default: "users"
  lambdRoleName:
    Type: String
    Default: "users"
  lambdaFunctionName:
    Type: String
    Default: "users"
  ApiGatewayName:
    Type: String
    Default: "users"

Resources:
  DynamodbCreation:
    Type: AWS::DynamoDB::Table
    Properties:
      TableName: !Ref dynamoDbName
      AttributeDefinitions:
        - AttributeName: name
          AttributeType: S
      KeySchema:
        - AttributeName: name
          KeyType: HASH
      ProvisionedThroughput:
        ReadCapacityUnits: 5
        WriteCapacityUnits: 5

  lambdaRoleCreation:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Ref lambdRoleName
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: MyLambdaPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - dynamodb:*
                Resource: !GetAtt DynamodbCreation.Arn
              - Effect: "Allow"
                Action:
                  - "logs:CreateLogGroup"
                  - "logs:CreateLogStream"
                  - "logs:PutLogEvents"
                Effect: "Allow"
                Resource:
                  - "*"
              - Effect: "Allow"
                Action:
                  - "logs:CreateLogGroup"
                  - "logs:CreateLogStream"
                  - "logs:PutLogEvents"
                  - "ec2:CreateNetworkInterface"
                  - "ec2:DescribeNetworkInterfaces"
                  - "ec2:DeleteNetworkInterface"
                Resource: "*"

  lambdaFunctionCreation:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Ref lambdaFunctionName
      Runtime: python3.8
      Handler: index.lambda_handler
      Role: !GetAtt lambdaRoleCreation.Arn
      MemorySize: 128
      Timeout: 60
      Environment:
        Variables:
          DYNAMO_DB_NAME: !Ref dynamoDbName
      Code:
        ZipFile: |
          import json
          import boto3
          import os

          dynamodb = boto3.resource('dynamodb')
          table_name = os.environ.get('DYNAMO_DB_NAME')

          def lambda_handler(event, context):
              if (event['httpMethod'] == 'GET'):
                  data = get_records()
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

  ApiGatewayCreation:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: !Ref ApiGatewayName

  ApiGatewayResourceCreation:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Ref ApiGatewayCreation
      ParentId: !GetAtt ApiGatewayCreation.RootResourceId
      PathPart: users

  ApiGatewayGetMethodCreation:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref ApiGatewayCreation
      ResourceId: !Ref ApiGatewayResourceCreation
      HttpMethod: GET
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub
          - arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${lambdaArn}/invocations
          - lambdaArn: !GetAtt lambdaFunctionCreation.Arn

  ApiGatewayPostMethodCreation:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref ApiGatewayCreation
      ResourceId: !Ref ApiGatewayResourceCreation
      HttpMethod: POST
      AuthorizationType: NONE
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub
          - arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${lambdaArn}/invocations
          - lambdaArn: !GetAtt lambdaFunctionCreation.Arn

  ApiGatewayDeploymentCreation:
    Type: AWS::ApiGateway::Deployment
    DependsOn:
      - ApiGatewayGetMethodCreation
      - ApiGatewayPostMethodCreation
    Properties:
      RestApiId: !Ref ApiGatewayCreation

  ApiGatewayStageCreation:
    Type: AWS::ApiGateway::Stage
    Properties:
      StageName: Prod
      RestApiId: !Ref ApiGatewayCreation
      DeploymentId: !Ref ApiGatewayDeploymentCreation
      MethodSettings:
        - HttpMethod: "*"
          ResourcePath: "/*"
          ThrottlingRateLimit: 1000
          ThrottlingBurstLimit: 5000
          CachingEnabled: true
          CacheTtlInSeconds: 300
          CacheDataEncrypted: true

  lambdaApiGatewayInvoke:
    Type: "AWS::Lambda::Permission"
    Properties:
      Action: "lambda:InvokeFunction"
      FunctionName: !GetAtt "lambdaFunctionCreation.Arn"
      Principal: "apigateway.amazonaws.com"
      SourceArn: !Sub "arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${ApiGatewayCreation}/*/*/*"

Outputs:
  ApiEndpoint:
    Description: Endpoint URL of the API Gateway
    Value: !Sub "https://${ApiGatewayCreation}.execute-api.${AWS::Region}.amazonaws.com/Prod/users"

```

_create the stack_

please use the following command to create your stack.

```bash
aws cloudformation create-stack --stack-name postman-api --template-body file://main.yml --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
```

_update stack_

please use the following command to update your existing stack.

```bash
aws cloudformation update-stack --stack-name postman-api --template-body file://main.yml --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
```


_delete stack_

please use the following command to delete your stack.

```bash
aws cloudformation delete-stack --stack-name postman-api
```

_validation_

`POST METHOD`

```json
{
	"name": "gino",
	"id": "1",
	"dob": "12March2023"
}
```
