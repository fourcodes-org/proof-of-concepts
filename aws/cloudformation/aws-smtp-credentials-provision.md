

```yml
AWSTemplateFormatVersion: '2010-09-09'
Description: Create SMTP Credentials for Amazon SES
Parameters:
  IamUser:
    Type: String
    Description: The name of the IAM user for SMTP credentials
    Default: smtpuser
  IamAccessKeyVersion:
    Type: Number
    Default: 1
    Description: Version number of the AWS access keys. Increment this number to rotate the keys.
    MinValue: 1
  SesRegion:
    Type: String
    Default: us-east-1
    Description: The AWS region where SES is located

Resources:
  SmtpUserGroup:
    Type: AWS::IAM::Group
    Properties:
      GroupName: SMTPUserGroup

  SmtpUserPolicy:
    Type: AWS::IAM::Policy
    Properties:
      PolicyName: SMTPUserPolicy
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Action: ses:SendRawEmail
            Resource: '*'
      Groups:
        - !Ref SmtpUserGroup

  SmtpUser:
    Type: AWS::IAM::User
    Properties:
      UserName: !Ref IamUser
      Groups:
        - !Ref SmtpUserGroup

  SmtpUserAccessKey:
    Type: AWS::IAM::AccessKey
    Properties:
      UserName: !Ref SmtpUser

Outputs:
  AccessKeyId:
    Description: IAM User Access Key ID
    Value: !Ref SmtpUserAccessKey
    Export:
      Name: !Sub "${AWS::StackName}-AccessKeyId"

  SecretAccessKey:
    Description: IAM User Secret Access Key
    Value: !GetAtt SmtpUserAccessKey.SecretAccessKey
    Export:
      Name: !Sub "${AWS::StackName}-SecretAccessKey"

```
