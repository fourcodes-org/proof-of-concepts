This script will generate the CSV file with information.

```py
import boto3
import csv

def get_subnet_names(subnets_response):
    subnets = {"id": "name"}
    for i in subnets_response['Subnets']:
        if 'Tags' in i:
            for j in i['Tags']:
                if j['Key'] == 'Name':
                    subnets[i['SubnetId']] = j['Value']
        else:
            subnets[i['SubnetId']] = i['SubnetId']
    return subnets

def get_associations(i, subnets):
    assoc = []
    for j in i['Associations']:
        if 'SubnetId' in j:
            assoc.append(j['SubnetId'] + '(' + subnets[j['SubnetId']] + ')')
        else:
            assoc.append('')
    return assoc

def get_rules_info(j):
    cidr = '-' if 'CidrBlock' not in j else j['CidrBlock']
    port = '-' if 'PortRange' not in j else f"{j['PortRange']['From']}-{j['PortRange']['To']}"
    protocol = 'All' if j['Protocol'] == '-1' else j['Protocol']
    type = 'Egress' if j['Egress'] else 'Ingress'
    rules = f"CIDR: {cidr}, Type: {type}, Protocol: {protocol}, Port Range: {port}, Action: {j['RuleAction']}"
    return rules

def main():
    ec2 = boto3.client('ec2', region_name='ap-southeast-1')
    
    subnets_response = ec2.describe_subnets()
    subnets = get_subnet_names(subnets_response)

    response = ec2.describe_network_acls(MaxResults=1000)

    title = ['Association', 'Name', 'Rules', 'Is Default', 'VPC']
    rows = [title]

    for i in response['NetworkAcls']:
        name = i['NetworkAclId']
        assoc = get_associations(i, subnets)
        is_default = i['IsDefault']
        vpc = i['VpcId']

        for j in i['Entries']:
            rules = get_rules_info(j)
            rows.append([assoc, name, rules, is_default, vpc])

    filename = 'nacl2.csv'
    with open(filename, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(rows)

    print('=====>>> Output written to ' + filename)

if __name__ == "__main__":
    main()
```
