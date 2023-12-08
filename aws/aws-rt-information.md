

```py
import boto3
import csv

def get_associations(i, subnets):
    assoc = []
    for j in i['Associations']:
        if 'GatewayId' in j:
            assoc.append(j['GatewayId'])
        elif 'SubnetId' in j:
            assoc.append(j['SubnetId'] + '(' + subnets[j['SubnetId']] + ')')
    return assoc

def get_target(j):
    if 'GatewayId' in j:
        return j['GatewayId']
    elif 'LocalGatewayId' in j:
        return 'LocalGatewayId'
    elif 'TransitGatewayId' in j:
        return j['TransitGatewayId']
    elif 'NatGatewayId' in j:
        return j['NatGatewayId']
    elif 'InstanceId' in j:
        return j['InstanceId']
    elif 'NetworkInterfaceId' in j:
        return j['NetworkInterfaceId']
    elif 'VpcPeeringConnectionId' in j:
        return j['VpcPeeringConnectionId']
    elif 'DestinationPrefixListId' in j:
        return j['DestinationPrefixListId']
    else:
        return ''

def main():
    ec2 = boto3.client('ec2', region_name='ap-southeast-1')
    subnets = {"id": "name"}

    subnets_response = ec2.describe_subnets()
    for i in subnets_response['Subnets']:
        if 'Tags' in i:
            for j in i['Tags']:
                if j['Key'] == 'Name':
                    subnets[i['SubnetId']] = j['Value']

    response = ec2.describe_route_tables()

    title = ['Association', 'Name', 'Destination', 'Target', 'Propagated', 'Remarks']
    rows = [title]

    for i in response['RouteTables']:
        name = i['RouteTableId']
        assoc = get_associations(i, subnets)

        for j in i['Routes']:
            destination = j.get('DestinationCidrBlock', j.get('DestinationPrefixListId', ''))
            target = get_target(j)
            propagated = j['Origin'] == 'EnableVgwRoutePropagation'
            remarks = ' '
            rows.append([assoc, name, destination, target, propagated, remarks])

    filename = 'rt.csv'
    with open(filename, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerows(rows)

    print('=====>>> Output written to ' + filename)

if __name__ == "__main__":
    main()

```
