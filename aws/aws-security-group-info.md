_aws-security-group-information python_

```py
import boto3
import csv

# # AWS credentials and region
# aws_access_key_id = 'YOUR_ACCESS_KEY'
# aws_secret_access_key = 'YOUR_SECRET_KEY'
region_name = 'ap-southeast-1'

# Create an EC2 client
# ec2 = boto3.client('ec2', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key, region_name=region_name)
ec2 = boto3.client('ec2', region_name=region_name)

# Get all security groups
response = ec2.describe_security_groups()

# Extract all information
security_groups = response['SecurityGroups']
headers = ['GroupID', 'GroupName', 'Description', 'VpcId', 'RuleType', 'PortRange', 'Protocol', 'Source']

# Create a CSV file
csv_file_path = 'security_groups.csv'

with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(headers)

    for group in security_groups:
        group_id = group['GroupId']
        group_name = group['GroupName']
        description = group['Description']
        vpc_id = group['VpcId']

        # Extract inbound rules
        for rule in group['IpPermissions']:
            from_port = rule.get('FromPort', '')
            to_port = rule.get('ToPort', '')
            protocol = rule.get('IpProtocol', '')
            source = rule.get('IpRanges', [{'CidrIp': '0.0.0.0/0'}])[0]['CidrIp']
            writer.writerow([group_id, group_name, description, vpc_id, 'Inbound', f"{from_port}-{to_port}", protocol, source])

        # Extract outbound rules
        for rule in group['IpPermissionsEgress']:
            to_port = rule.get('ToPort', '')
            protocol = rule.get('IpProtocol', '')
            destination = rule.get('IpRanges', [{'CidrIp': '0.0.0.0/0'}])[0]['CidrIp']
            writer.writerow([group_id, group_name, description, vpc_id, 'Outbound', to_port, protocol, destination])

print(f'Security group details saved to {csv_file_path}')

```
