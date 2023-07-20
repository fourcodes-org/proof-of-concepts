Stack Details:


| S3bucket | Lambda | DynamoDb |
| --------------- | --------------- | --------------- |
| 1. Create S3 bucket| 1. create iam role | 1. Create dynamodb |
| 2. Upload the file into s3 bucket | 2. Lambdafunction Create |  |
|  | 3. Create event trigger function in cloudwatch |  |
    

Deploy procedures

    pip3 install -r requirements.txt 
    cdk bootstrap -b [unique s3backetname] 
    cdk list
    cdk synthesize First-Stack
    cdk synthesize Second-Stack
    cdk synthesize Third-Stack
    cdk synthesize Fourth-Stack

First Stack deploy

    cdk deploy First-Stack \
    --parameters uploadBucketName=jinojoes3bucket \
    --parameters FirstLambdaName=lambda1 

Second Stack Deploy

    cdk deploy Second-Stack \
    --parameters SecondLambdaName=lambda2 

Third Stack Deploy

    cdk deploy Third-Stack \
    --parameters ThirdLambdaName=lambda3 

Fourth Stack Deploy

    cdk deploy Fourth-Stack \
    --parameters FourthLambdaName=lambda4 

FifthStack Deploy

    cdk deploy Fifth-Stack \
    --parameters FirstDynamodbName=Dynamodb1  \
    --parameters SecondDynamodbName=Dynamodb2 \
    --parameters ThirdDynamodbName=Dynamodb3  \
    --parameters FourthDynamodbName=Dynamodb4


Destroy stacks

    cdk destroy First-Stack Fourth-Stack Second-Stack Third-Stack Fifth-Stack
