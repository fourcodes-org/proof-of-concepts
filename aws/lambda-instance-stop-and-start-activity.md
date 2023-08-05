_lambda-instance-stop-and-start-activity_

```py
import json
import boto3

class InstancesAction:
    def __init__(self):
        self.client = boto3.client('ec2')
        # boto3.set_stream_logger(name='botocore')
        
    def find_instance_id(self):
        response = self.client.describe_instances()
        instances = response['Reservations']
        instance_id = []
        for i in instances:
            for j in i['Instances']:
                instance_id.append(j['InstanceId'])
        return instance_id

    def stop_instance(self):
        response = self.client.stop_instances(InstanceIds=self.find_instance_id())
        return response

    def start_instance(self):
        response = self.client.start_instances(InstanceIds=self.find_instance_id())
        return response


def lambda_handler(event, context):
    if event['Action'] == "stop":
        InstancesAction().stop_instance()
    else:
        InstancesAction().start_instance()

```
