

```py
import json
import boto3
import os

region_name = os.environ.get('REGION')
domain_name = os.environ.get('DOMAIN_NAME')
load_balancer_listener_arn = os.environ.get('LOAD_BALANCER_LISTENER_ARN')

alb_client = boto3.client('elbv2', region_name=region_name)

class AlbRuleUpdate():
    def __init__(self, listener_arn):
        self.listener_arn = listener_arn
        self.rule_arn = self.get_rule_arn()

    def create_rule(self):
        if not self.rule_arn:
            new_rule = {
                'ListenerArn': self.listener_arn,
                'Priority': 1,
                'Conditions': [
                    {
                        'Field': 'host-header',
                        'Values': [domain_name]
                    }
                ],
                'Actions': [
                    {
                        'Type': 'fixed-response',
                        'Order': 1,
                        'FixedResponseConfig': {
                            'MessageBody': '<!doctype html><title>Site Maintenance</title><style>body{text-align:center;padding:150px;}h1{font-size:50px;}body{font:20px Helvetica,sans-serif;color:#333;}article{display:block;text-align:left;width:650px;margin:0 auto;}a{color:#dc8100;text-decoration:none;}a:hover{color:#333;text-decoration:none;}</style><article><h1>We will be back soon!</h1><div><p>Sorry for the inconvenience caused. We are performing maintenance work at the moment. Please contact us at <a href="mailto:final_support@januo.com">final_support@januo.com</a> if you require further clarification.</p></div></article>',
                            'StatusCode': '200',
                            'ContentType': 'text/html'
                        }
                    }
                ]
            }
            alb_client.create_rule(**new_rule)

    def get_rule_arn(self):
        rules = alb_client.describe_rules(ListenerArn=self.listener_arn)['Rules']
        for rule in rules:
            if rule['Priority'] == '1':
                return rule['RuleArn']
        return None

    def delete_rule(self):
        if self.rule_arn:
            alb_client.delete_rule(RuleArn=self.rule_arn)

def lambda_handler(event, context):
    
    alb = AlbRuleUpdate(load_balancer_listener_arn)
    
    event_name = event.get('event_name', '')

    if event_name == 'start-maintenance':
        alb.create_rule()
        return {
            'statusCode': 200,
            'body': json.dumps({
                'action': 'start maintenance',
                'state': 'success'
            })
        }

    elif event_name == 'stop-maintenance':
        alb.delete_rule()
        return {
            'statusCode': 200,
            'body': json.dumps({
                'action': 'stop maintenance',
                'state': 'success'
            })
        }

    else:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'Invalid event_name',
                'state': 'failed'
            })
        }

```
