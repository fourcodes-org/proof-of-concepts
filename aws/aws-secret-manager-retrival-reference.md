

```py
import pathlib
import boto3
import json

def check_availability(element, collection: iter):
    return element in collection

"""
{
  "allowed_file_type_list" : [ "py", "pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "jpg", "jpeg", "png", "bmp", "tiff", "gif", "bimx", "dwg", "pln", "rvt", "dwf", "dgn", "pla", "dxf", "ifc", "bcf", "zip", "mp4", "mpeg", "txt", "nwd", "mov", "avi", "shp", "shx", "dbf", "sbn", "sbx", "fbn", "fbx", "ain", "aih", "atx", "ixs", "mxs", "prj", "xml", "cpg"]
}
"""

allowed_file_type_list = [ "py", "pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "jpg", "jpeg", "png", "bmp", "tiff", "gif", "bimx", "dwg", "pln", "rvt", "dwf", "dgn", "pla", "dxf", "ifc", "bcf", "zip", "mp4", "mpeg", "txt", "nwd", "mov", "avi", "shp", "shx", "dbf", "sbn", "sbx", "fbn", "fbx", "ain", "aih", "atx", "ixs", "mxs", "prj", "xml", "cpg"]

secret_name = "prod/allowed-file-types-list"

def retrive_data_from_secret_manager(secret_name):
    client = boto3.client('secretsmanager')
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = get_secret_value_response['SecretString']
    return secret

def reads3JSON(bucket_name, file_name):
    s3 = boto3.resource('s3')
    content_object = s3.Object(bucket_name, file_name)
    file_content = content_object.get()['Body'].read().decode('utf-8')
    json_content = json.loads(file_content)
    return json_content['allowed_file_type_list']

def validation_of_source(allowed_file_type_list, name_of_file):
    extension_of_file = pathlib.Path(name_of_file).suffix
    actual_string = str(extension_of_file.rsplit(".", 1)[1])
    # file_status = check_availability(actual_string, retrive_data_from_secret_manager(secret_name))
    file_status = check_availability(actual_string, allowed_file_type_list)
    return file_status

print(validation_of_source(allowed_file_type_list, "scan.gitlab.ci.yml"))
```

_secret manager_

```py
import pathlib
import boto3
import json

def check_availability(element, collection: iter):
    return element in collection

def retrive_data_from_secret_manager(secret_name):
    client = boto3.client('secretsmanager')
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = get_secret_value_response['SecretString']
    return secret

def validation_of_source(name_of_file):
    extension_of_file = pathlib.Path(name_of_file).suffix
    actual_string = str(extension_of_file.rsplit(".", 1)[1])
    file_status = check_availability(actual_string, retrive_data_from_secret_manager(secret_name))
    # file_status = check_availability(actual_string, allowed_file_type_list)
    return file_status

secret_name = "sm-prod/allowed-file-types-list"
print(validation_of_source("demo.py")
```
