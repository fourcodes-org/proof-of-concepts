

```yml
---
Parameters:
  ProjectName:
    Type: String
    Default: mc
  Environment:
    Type: String
    Default: uat
  ExistingVpcId:
    Type: String
    Default: vpc-088e36f2e86dfa7b1
  EC2KeyName:
    Type: String
    Default: dev-devops-key
  SubnetCIDRZoneA:
    Type: String
    Default: 10.0.1.0/24
  SubnetCIDRZoneB:
    Type: String
    Default: 10.0.2.0/24
  InstanceType:
    Type: String
    Default: t2.xlarge
  WindowsAmiId:
    Type: String
    Default: ami-062508d30d9f2cb68
  LinuxAmiId:
    Type: String
    Default: ami-02acda7aaa1f944e5 
  GitLabLinuxRunnerToken:
    Type: String
    Default: glrt-iymAsYH8pUF5o-wnnd6F
    Description: uat-linux-shared-runner token
  GitLabWindowsRunnerToken:
    Type: String
    Default: glrt-dr6oPuBJucsY3Gvuc3o9
    Description: uat-windows-shared-runner token
  GitLabUrl:
    Type: String
    Default: https://gitlab.com
    Description: GitLab URL

Conditions:
  CreateWindowsEC2Instance: !Equals [!Ref Environment, 'uat']

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
      AvailabilityZone: !Sub '${AWS::Region}a'
      MapPublicIpOnLaunch: false
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
      AvailabilityZone: !Sub '${AWS::Region}b'
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

  S3Bucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: !Sub "bca-${ProjectName}-${Environment}-devops-bucket-state"
      Tags:
        - Key: env
          Value: !Ref Environment

  SecurityGroupForVpcEndPoints:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for vpc endpoints
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-vpc-endpoints-sg"
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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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
      # Tags:
      #   - Key: env
      #     Value: !Ref Environment
      #   - Key: Name
      #     Value: !Sub "vpce-cnx${ProjectName}-${Environment}mzna-com.amazonaws.${AWS::Region}.logs"

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

  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group for Zone Runners
      VpcId: !Ref ExistingVpcId
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-uat-runner-sg"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 3389
          ToPort: 3389
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

  WindowsEC2Instance:
    Type: AWS::EC2::Instance
    Condition: CreateWindowsEC2Instance
    Properties:
      InstanceType: !Ref InstanceType
      IamInstanceProfile: !Ref IAMRoleInstanceProfile
      SecurityGroupIds:
        - !GetAtt SecurityGroup.GroupId
      SubnetId: !Ref SubnetZoneA
      ImageId: !Ref WindowsAmiId
      KeyName: !Ref EC2KeyName
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-windows-gitlab-runner"
      UserData:
        Fn::Base64: !Sub |
          <powershell>
          $InstallerUrl = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
          $InstallerFileName = "python-3.9.7.exe"
          $InstallPath = "C:\Python3.9.7"
          Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerFileName
          Start-Process -Wait -FilePath $InstallerFileName -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0", "Include_launcher=1", "Include_doc=0", "InstallLauncherAllUsers=1", "Include_tcltk=0", "Include_pip=1", "InstallAllUsers=1", "TargetDir=$InstallPath"
          Remove-Item -Path $InstallerFileName
          $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
          $env:Path += ";$InstallPath;$InstallPath\Scripts"
          [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
          python --version
          python -m pip install awscli
          New-Item -Path 'C:\GitLab-Runner' -ItemType Directory
          cd 'C:\GitLab-Runner'
          Invoke-WebRequest -Uri "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe" -OutFile "gitlab-runner.exe"
          .\gitlab-runner.exe install
          .\gitlab-runner.exe start
          .\gitlab-runner register --non-interactive --url "${GitLabUrl}" --registration-token "${GitLabLinuxRunnerToken}" --executor "shell" --name "${Environment}-windows-gitlab-remote-runner"
          $gitDownloadUrl = "https://github.com/git-for-windows/git/releases/download/v2.34.0.windows.2/Git-2.34.0.2-64-bit.exe"
          $installationPath = "C:\Program Files\Git"
          $installerPath = "$env:TEMP\GitInstaller.exe"
          Invoke-WebRequest -Uri $gitDownloadUrl -OutFile $installerPath
          Start-Process -Wait -FilePath $installerPath -ArgumentList "/SILENT"
          [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$installationPath\cmd;$installationPath\bin", [System.EnvironmentVariableTarget]::Machine)
          Remove-Item -Path $installerPath
          git --version
          </powershell>

  LinuxEC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      IamInstanceProfile: !Ref IAMRoleInstanceProfile
      SecurityGroupIds:
        - !GetAtt SecurityGroup.GroupId
      SubnetId: !Ref SubnetZoneA
      ImageId: !Ref LinuxAmiId
      KeyName: !Ref EC2KeyName
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "bca-${ProjectName}-${Environment}-linux-gitlab-runner"
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash -xe
          echo "I am goin to excute the script for devops activity."
          echo "Update the system and install required dependencies"
          sudo yum update -y
          sudo yum install -y wget unzip jq skopeo python3 python3-pip
          sudo pip3 install awscli
          echo 'export PATH="/usr/local/bin:$PATH"' | sudo tee -a /etc/bashrc
          echo "Install Terraform"
          wget "https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip"
          unzip "terraform_1.5.7_linux_amd64.zip"
          sudo mv terraform /usr/local/bin/
          echo "Install GitLab Runner"
          curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
          sudo yum install -y gitlab-runner
          echo "Start and enable GitLab Runner"
          sudo systemctl start gitlab-runner
          sudo systemctl enable gitlab-runner
          echo "Clean up"
          rm "terraform_1.5.7_linux_amd64.zip"
          echo "AWS CLI, jq, Skopeo, Terraform, and GitLab Runner installation completed."
          echo "Install docker on the server"
          sudo subscription-manager repos --enable rhel-8-for-x86_64-appstream-optional-rpms
          sudo yum install docker -y
          sudo systemctl enable podman
          echo "Register the GitLab Runner"
          sudo gitlab-runner register --non-interactive --url "${GitLabUrl}" --registration-token "${GitLabLinuxRunnerToken}" --executor "shell" --name "${Environment}-linux-gitlab-remote-runner"

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

  # PrivateHostedZoneShip: 
  #   Type: AWS::Route53::HostedZone
  #   Properties:
  #     HostedZoneConfig: 
  #       Comment: 'My hosted zone for ship.gov.sg'
  #     Name: ship.gov.sg
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

  # VpcEndpointForNexusIq:
  #   Type: 'AWS::EC2::VPCEndpoint'
  #   Properties:
  #     VpcEndpointType: 'Interface'
  #     ServiceName: com.amazonaws.vpce.ap-southeast-1.vpce-svc-00943fbdd70eeddf9
  #     VpcId: !Ref ExistingVpcId
  #     SubnetIds: 
  #       - !Ref SubnetZoneA
  #       - !Ref SubnetZoneB
  #     SecurityGroupIds:
  #       - !Ref SecurityGroupForVpcEndPoints

  # PrivateHostedZoneRecordForNexusIq:
  #   Type: AWS::Route53::RecordSet
  #   Properties:
  #     HostedZoneId: !GetAtt PrivateHostedZoneShip.Id
  #     Comment: VPC Endpoint Record
  #     Name: nexus-iq.ship.gov.sg 
  #     Type: CNAME
  #     TTL: 300
  #     ResourceRecords:
  #       - !Select ['1', !Split [':', !Select ['0', !GetAtt VpcEndpointForNexusIq.DnsEntries]]]








  # Temporary Resources
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: MyInternetGateway

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref ExistingVpcId
      InternetGatewayId: !Ref InternetGateway

  InternetGatewayRoute:
    Type: AWS::EC2::Route
    DependsOn: AttachGateway
    Properties:
      RouteTableId: !Ref RouteTableZoneA
      DestinationCidrBlock: '0.0.0.0/0'
      GatewayId: !Ref InternetGateway

  LinuxEip:
    Type: AWS::EC2::EIP
    Properties:
      Domain: vpc
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "eip-${ProjectName}-${Environment}-linux-gitlab-runner"

  EipAssociation:
    Type: AWS::EC2::EIPAssociation
    Properties:
      InstanceId: !Ref LinuxEC2Instance
      EIP: !Ref LinuxEip

  WindowsEip:
    Type: AWS::EC2::EIP
    Properties:
      Domain: vpc
      Tags:
        - Key: env
          Value: !Ref Environment
        - Key: Name
          Value: !Sub "eip-${ProjectName}-${Environment}-windows-gitlab-runner"

  WindowsEipAssociation:
    Type: AWS::EC2::EIPAssociation
    Properties:
      InstanceId: !Ref WindowsEC2Instance
      EIP: !Ref WindowsEip
```

_stack creation_

```ps1
aws cloudformation create-stack --stack-name bca-mc-uat-devops-setup --template-body file://main.yml --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
```

_update the stack_

```ps1
aws cloudformation update-stack --stack-name bca-mc-uat-devops-setup --template-body file://main.yml --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM"
```


