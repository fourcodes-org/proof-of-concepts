```yml
---
Parameters:
  CommonOrg:
    Type: String
    Default: bca
  ProjectName:
    Type: String
    Default: nsigncore
  Environment:
    Type: String
    Default: uat
  PeerVpcCidrBlock:
    Type: String
    Default: 10.211.83.128/25      # sh-bca-cnxcp-uat-account devops zone cidr
  VpcPeeringConnectionId:
    Type: String
    Default: pcx-031ca283365a444d6 # sh-bca-cnxcp-uat-account peering connection id
  ExistingVpcId:
    Type: String
    Default: vpc-03d3de03d7d8d39ec 
  ExistingVpcCIDR:
    Type: String
    Default: 10.219.122.0/25
  EC2KeyName:
    Type: String
    Default: ec2key-nsigncore-uat-devops
  SubnetCIDRZoneA:
    Type: String
    Default: 10.219.122.0/26
  SubnetCIDRZoneB:
    Type: String
    Default: 10.219.122.64/26
  InstanceType:
    Type: String
    Default: t2.xlarge
  GitLabLinuxRunnerToken:
    Type: String
    Default: glrt-2PUeA8yZaBPydQvjq66U
    Description: The GitLab token for the ship-hats repository is used with RedHat Linux Remote Runner.
  GitLabUrl:
    Type: String
    Default: https://sgts.gitlab-dedicated.com/
    Description: The GitLab URL for Ship-hats
  MinSize:
    Type: Number
    Description: Minimum number of instances in the Auto Scaling group
    Default: 1
  MaxSize:
    Type: Number
    Description: Maximum number of instances in the Auto Scaling group
    Default: 2
  DesiredCapacity:
    Type: Number
    Description: Desired capacity of the Auto Scaling group
    Default: 1
  AutoScalingLinuxAmiId:
    Type: String
    Default: ami-0c0cd55a5fbced0c2
    Description: This is the image used for EC2 RedHat Linux instance creation, which has default Ansible packages installed.
Resources:
  NetworkAclZoneA:
    Type: 'AWS::EC2::NetworkAcl'
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "nacl-a-${ProjectName}-${Environment}-devops-01"

  NetworkAclZoneB:
    Type: 'AWS::EC2::NetworkAcl'
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "nacl-b-${ProjectName}-${Environment}-devops-02"

  NetworkAclZoneAAclEntryInboundAllowAll100:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 100
      Protocol: 6
      RuleAction: allow
      Egress: false
      CidrBlock: !Ref ExistingVpcCIDR
      PortRange:
        From: 1024
        To: 65535

  NetworkAclZoneAAclEntryInboundAllowAll99:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 99
      Protocol: 6
      RuleAction: allow
      Egress: false
      CidrBlock: !Ref ExistingVpcCIDR
      PortRange:
        From: 443
        To: 443

  NetworkAclZoneAAclEntryOutboundAllowAll100:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 100
      Protocol: 6
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0
      PortRange:
        From: 1024
        To: 65535

  NetworkAclZoneAAclEntryOutboundAllowAll99:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneA
      RuleNumber: 99
      Protocol: 6
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0
      PortRange:
        From: 443
        To: 443

  NetworkAclZoneBAclEntryInboundAllowAll100:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 100
      Protocol: 6
      RuleAction: allow
      Egress: false
      CidrBlock: !Ref ExistingVpcCIDR
      PortRange:
        From: 1024
        To: 65535

  NetworkAclZoneBAclEntryInboundAllowAll99:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 99
      Protocol: 6
      RuleAction: allow
      Egress: false
      CidrBlock: !Ref ExistingVpcCIDR
      PortRange:
        From: 443
        To: 443

  NetworkAclZoneBAclZoneBAclEntryOutboundAllowAll100:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 100
      Protocol: 6
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0
      PortRange:
        From: 1024
        To: 65535

  NetworkAclZoneBAclEntryOutboundAllowAll99:
    Type: 'AWS::EC2::NetworkAclEntry'
    Properties:
      NetworkAclId: !Ref NetworkAclZoneB
      RuleNumber: 99
      Protocol: 6
      RuleAction: allow
      Egress: true
      CidrBlock: 0.0.0.0/0
      PortRange:
        From: 443
        To: 443

  RouteTableZoneA:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "rt-a-${ProjectName}-${Environment}-devops-01"         

  SubnetZoneA:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ExistingVpcId
      CidrBlock: !Ref SubnetCIDRZoneA
      AvailabilityZone: !Sub '${AWS::Region}a'
      MapPublicIpOnLaunch: false
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "sub-a-${ProjectName}-${Environment}-devops-01"

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
      AvailabilityZone: !Sub '${AWS::Region}b'
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "sub-b-${ProjectName}-${Environment}-devops-02"

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
          Value: !Sub "rt-b-${ProjectName}-${Environment}-devops-02"         

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

  S3Bucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: !Sub "sst-s3-bca-${ProjectName}-${Environment}-terraform-state-store"
      VersioningConfiguration:
        Status: Enabled
      Tags:
        - Key: env
          Value: !Ref Environment

  S3BucketPolicy:
    Type: 'AWS::S3::BucketPolicy'
    Properties:
      Bucket: !Ref S3Bucket
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AllowSSLRequestsOnly
            Effect: Deny
            Principal:
              AWS: '*'
            Action: 's3:*'
            Resource:
              - Fn::Sub: "arn:aws:s3:::${S3Bucket}/*"
              - Fn::Sub: "arn:aws:s3:::${S3Bucket}"
            Condition:
              Bool:
                'aws:SecureTransport': 'false'

  SecurityGroupForVpcEndPoints:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for vpc endpoints
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "sgrp-${ProjectName}-${Environment}-devops-vpce"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  VpcEndpointForS3Gateway:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Gateway'
      VpcId: !Ref ExistingVpcId
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.s3'
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal: '*'
            Action:
              - '*'
            Resource:
              - '*'
      RouteTableIds:
        - !Ref RouteTableZoneA
        - !Ref RouteTableZoneB

  VpcEndpointForS3Interface:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.logs'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true
   
  VpcEndpointForSns:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.sns'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSqs:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.sqs'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForLambda:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.lambda'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEc2:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ec2'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForRds:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.rds'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForRds:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.rds-data'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForExecuteApi:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.execute-api'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints

  VpcEndpointForEcrApi:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecr.api'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEcrDkr:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecr.dkr'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSecretsManager:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.secretsmanager'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForElasticFileSystem:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.elasticfilesystem'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEcs:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecs'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEvents:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.events'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForeEcsAgent:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecs-agent'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEcsTelemetry:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ecs-telemetry'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEmailSmtp:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.email-smtp'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEc2Messages:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ec2messages'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSsm:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ssm'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForMonitoring:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.monitoring'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForBackup:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.backup'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForBackupGateway:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.backup-gateway'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForCloudTrail:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.cloudtrail'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForEbs:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ebs'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForElastiCache:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.elasticache'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForElasticLoadBalancing:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.elasticloadbalancing'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForKms:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.kms'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForTransfer:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.transfer'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForTransferServer:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.transfer.server'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSts:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.sts'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForDynamodb:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Gateway'
      VpcId: !Ref ExistingVpcId
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.dynamodb'
      PolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal: '*'
            Action:
              - '*'
            Resource:
              - '*'
      RouteTableIds:
        - !Ref RouteTableZoneA
        - !Ref RouteTableZoneB

  VpcEndpointForCloudformation:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.cloudformation'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForStates:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.states'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSsmMessages:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ssmmessages'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  VpcEndpointForSyncStates:
    Type: 'AWS::EC2::VPCEndpoint'
    Properties:
      VpcEndpointType: 'Interface'
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.sync-states'
      VpcId: !Ref ExistingVpcId
      SubnetIds: 
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      SecurityGroupIds:
        - !Ref SecurityGroupForVpcEndPoints
      PrivateDnsEnabled: true

  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for Zone Runners
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "sgrp-${ProjectName}-${Environment}-devops-runner"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 3128
          ToPort: 3128
          CidrIp: !Ref PeerVpcCidrBlock
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: !Ref ExistingVpcCIDR

  IAMRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: !Sub "iam-${ProjectName}-${Environment}-devops-role"
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
          Value: !Sub "iam-${ProjectName}-${Environment}-devops-role"

  IAMRoleInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      InstanceProfileName: !Sub "iam-${ProjectName}-${Environment}-devops-iam-profile"
      Roles:
        - !Ref IAMRole

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      AutoScalingGroupName: !Sub "asg-${ProjectName}-${Environment}-devops-linux-gitlab-runner"
      VPCZoneIdentifier:
        - !Ref SubnetZoneA
        - !Ref SubnetZoneB
      LaunchConfigurationName:
        Ref: AutoScalingGroupLaunchConfiguration
      MinSize: !Ref MinSize
      MaxSize: !Ref MaxSize
      DesiredCapacity: !Ref DesiredCapacity
      Tags:
        - Key: Name
          Value: !Sub "vm-${ProjectName}-${Environment}-devops-linux-gitlab-runner"
          PropagateAtLaunch: true

  AutoScalingGroupLaunchConfiguration:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: !Ref AutoScalingLinuxAmiId
      InstanceType: !Ref InstanceType
      SecurityGroups:
        - !GetAtt SecurityGroup.GroupId
      KeyName: !Ref EC2KeyName
      IamInstanceProfile: !Ref IAMRoleInstanceProfile
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          sudo systemctl start gitlab-runner
          sudo systemctl start podman

  RouteZoneAPeerRouteTableEntry:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTableZoneA
      DestinationCidrBlock: !Ref PeerVpcCidrBlock
      VpcPeeringConnectionId: !Ref VpcPeeringConnectionId

  RouteZoneBPeerRouteTableEntry:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref RouteTableZoneB
      DestinationCidrBlock: !Ref PeerVpcCidrBlock
      VpcPeeringConnectionId: !Ref VpcPeeringConnectionId

  # # Ship-Hats Resources
  # PrivateHostedZoneGitlab: 
  #   Type: AWS::Route53::HostedZone
  #   Properties:
  #     HostedZoneConfig: 
  #       Comment: 'My hosted zone for gitlab-dedicated.com'
  #     Name: gitlab-dedicated.com
  #     VPCs:
  #       - VPCRegion: !Sub '${AWS::Region}'
  #         VPCId: !Ref ExistingVpcId

  # VpcEndpointForGitLabSaaS:
  #   Type: 'AWS::EC2::VPCEndpoint'
  #   Properties:
  #     VpcEndpointType: 'Interface'
  #     ServiceName: com.amazonaws.vpce.ap-southeast-1.vpce-svc-0c4c6c964095f9102
  #     VpcId: !Ref ExistingVpcId
  #     SubnetIds: 
  #       - !Ref SubnetZoneA
  #       - !Ref SubnetZoneB
  #     SecurityGroupIds:
  #       - !Ref SecurityGroupForVpcEndPoints

  # PrivateHostedZoneRecordForGitLabSaas:
  #   Type: AWS::Route53::RecordSet
  #   Properties:
  #     HostedZoneId: !GetAtt PrivateHostedZoneGitlab.Id
  #     Comment: VPC Endpoint Record
  #     Name: sgts.gitlab-dedicated.com 
  #     Type: CNAME
  #     TTL: 300
  #     ResourceRecords:
  #       - !Select ['1', !Split [':', !Select ['0', !GetAtt VpcEndpointForGitLabSaaS.DnsEntries]]]

  # VpcEndpointForGitLabSaasRegistry:
  #   Type: 'AWS::EC2::VPCEndpoint'
  #   Properties:
  #     VpcEndpointType: 'Interface'
  #     ServiceName: com.amazonaws.vpce.ap-southeast-1.vpce-svc-06682b483e966c6d9
  #     VpcId: !Ref ExistingVpcId
  #     SubnetIds: 
  #       - !Ref SubnetZoneA
  #       - !Ref SubnetZoneB
  #     SecurityGroupIds:
  #       - !Ref SecurityGroupForVpcEndPoints

  # PrivateHostedZoneRecordForGitLabSaasRegistry:
  #   Type: AWS::Route53::RecordSet
  #   Properties:
  #     HostedZoneId: !GetAtt PrivateHostedZoneGitlab.Id
  #     Comment: VPC Endpoint Record
  #     Name: registry.sgts.gitlab-dedicated.com 
  #     Type: CNAME
  #     TTL: 300
  #     ResourceRecords:
  #       - !Select ['1', !Split [':', !Select ['0', !GetAtt VpcEndpointForGitLabSaasRegistry.DnsEntries]]]

  # # Temporary Resources
  # InternetGateway:
  #   Type: AWS::EC2::InternetGateway
  #   Properties:
  #     Tags:
  #       - Key: Name
  #         Value: igw-bca-${ProjectName}-${Environment}-devops

  # AttachGateway:
  #   Type: AWS::EC2::VPCGatewayAttachment
  #   Properties:
  #     VpcId: !Ref ExistingVpcId
  #     InternetGatewayId: !Ref InternetGateway

  # InternetGatewayRoute:
  #   Type: AWS::EC2::Route
  #   DependsOn: AttachGateway
  #   Properties:
  #     RouteTableId: !Ref RouteTableZoneA
  #     DestinationCidrBlock: '0.0.0.0/0'
  #     GatewayId: !Ref InternetGateway

  # LinuxEip:
  #   Type: AWS::EC2::EIP
  #   Properties:
  #     Domain: vpc
  #     Tags:
  #       - Key: env
  #         Value: !Ref Environment
  #       - Key: Name
  #         Value: !Sub "eip-${ProjectName}-${Environment}-devops-linux-gitlab-runner"
  ```
