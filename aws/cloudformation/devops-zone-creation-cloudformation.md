
```yml
Parameters:
  ProjectName:
    Type: String
    Default: mc
  Environment:
    Type: String
    Default: uat
  ExistingVpcId:
    Type: String
    Default: vpc-0fb0b9c30d8082027
  EC2KeyName:
    Type: String
    Default: mc
  SubnetCIDRZoneA:
    Type: String
    Default: 10.0.1.0/24
  SubnetCIDRZoneB:
    Type: String
    Default: 10.0.2.0/24
  InstanceType:
    Type: String
    Default: t2.micro

Resources:

  NetworkAclZoneA:
    Type: 'AWS::EC2::NetworkAcl'
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-nacl-zone-a"

  NetworkAclZoneB:
    Type: 'AWS::EC2::NetworkAcl'
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-nacl-zone-b"

  NetworkAclEntryInboundAllowAll:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 100
      Protocol: -1
      RuleAction: allow
      Egress: false
      CidrBlock: 0.0.0.0/0

  NetworkAclEntryOutboundAllowAll:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 100
      Protocol: -1
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0

  NetworkAclEntryInboundAllowAllZoneB:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 100
      Protocol: -1
      RuleAction: allow
      Egress: false
      CidrBlock: 0.0.0.0/0

  NetworkAclEntryOutboundAllowAllZoneB:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 100
      Protocol: -1
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0

  RouteTableZoneA:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-rt-zone-a"

  SubnetZoneA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ExistingVpcId
      CidrBlock: !Ref SubnetCIDRZoneA
      AvailabilityZone: ap-south-1a
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-devops-profile"

  SubnetZoneANetworkAclAssociation:
    Type: 'AWS::EC2::SubnetNetworkAclAssociation'
    Properties:
      SubnetId: !Ref SubnetZoneA
      NetworkAclId: !Ref NetworkAclZoneA

  SubnetZoneB:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ExistingVpcId
      CidrBlock: !Ref SubnetCIDRZoneB
      AvailabilityZone: ap-south-1b
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-devops-profile"

  SubnetZoneBNetworkAclAssociation:
    Type: 'AWS::EC2::SubnetNetworkAclAssociation'
    Properties:
      SubnetId: !Ref SubnetZoneB
      NetworkAclId: !Ref NetworkAclZoneB

  RouteTableZoneB:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-rt-zone-b"

  SubnetZoneARouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTableZoneA
      SubnetId: !Ref SubnetZoneA

  SubnetZoneBRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref RouteTableZoneB
      SubnetId: !Ref SubnetZoneB

  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for Zone A
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-uat-subnet-a-sg"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0

  IAMRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub "bca-${ProjectName}-${Environment}-devops-role"
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: devops-agent-required-policies
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - "*"
                Resource: "*"
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-devops-profile"

  IAMRoleInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: !Sub "bca-${ProjectName}-${Environment}-devops-iam-profile"
      Roles:
        - !Ref IAMRole

  LinuxEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      IamInstanceProfile: !Ref IAMRoleInstanceProfile
      SecurityGroupIds:
        - !GetAtt SecurityGroup.GroupId
      SubnetId: !Ref SubnetZoneA
      ImageId: ami-XXXXXXXXXXXXXXXXX
      KeyName: !Ref EC2KeyName
    Tags:
      - Key: env
        Value: !Ref Environment
      - Key: Name
        Value: !Sub "bca-${ProjectName}-${Environment}-devops-profile"

  S3Bucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: !Sub "bca-${ProjectName}-${Environment}-devops-bucket"
      Tags:
        - Key: env
          Value: !Ref Environment
```
