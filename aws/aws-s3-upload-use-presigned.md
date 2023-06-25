

```py
import json
import boto3
s3 = boto3.client(
            "s3", config=boto3.session.Config(signature_version='s3v4'))


def single(bucket, key, ExpiresIn):
    singleUploadDetails = []
    params = {'Bucket': bucket, 'Key': key}
    singleUploadDetails.append(s3.generate_presigned_url(ClientMethod="put_object", Params=params, ExpiresIn=ExpiresIn))
    return singleUploadDetails


s3_ = single("application-s3-html", "jino.txt", 300)
print(s3_)

```

_upload a file_

```py
import requests
test_file = open("jino.txt", "rb")

test_url = "https://xxxxxWS4-HMAC-SHA256&X-Amz-Credential=xxxx%xx%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=xxxx&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Security-Token=IQoxxDmFwLXNvdXRoLX&X-Amz-Signature=x"
test_response = requests.put(test_url, files = {"form_field_name": test_file})
print(test_response)
```
