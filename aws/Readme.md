aws rest api call

```py
import boto3
boto3.set_stream_logger(name='botocore')
```

while execute the script it will show all the AWS REST API.


_aws Resource naming convention_

```bash
[resource-common-name]-[project-name]-[project-code]-[environment]-[purpose-resource]

lambda-januo-001-dev-event
lambda-januo-001-dev-replication
lambda-januo-001-dev-process
role-januo-001-dev-lambda-process
policy-januo-001-dev-process
```
