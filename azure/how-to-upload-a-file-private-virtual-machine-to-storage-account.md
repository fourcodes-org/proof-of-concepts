_how-to-upload-a-file-private-virtual-machine-to-storage-account.md_

**How to transfer files from private instances to storage accounts**

_Requirements_

1.	Virtual machine
2.	Storage account

**Find virtual machine networks and subnets from the Azure Portal console.**

1.	Login the azure portal 
2.	Navigate to azure virtual machine

![image](https://user-images.githubusercontent.com/57703276/236109580-4656414d-51d8-4e5a-a186-617a73da505a.png)

**Create the virtual network rule in the storage account.**

1.	Login the azure portal 
2.	Navigate to azure storage account

![image](https://user-images.githubusercontent.com/57703276/236109666-4299092c-9c9a-425b-97f3-1ed3e744117f.png)

You will have to create the virtual network rule based on your existing virtual machine located in the virtual network VPC. Once rules are created, you login to the virtual machine and create a zip file. In the storage account, navigate to the container and create the SAS token to upload the file from the virtual machine.

**How to create the SAS token**

![image](https://user-images.githubusercontent.com/57703276/236109749-bf5dd9a8-c656-4d61-a43c-b97a4ed30a01.png)


![image](https://user-images.githubusercontent.com/57703276/236109787-91589447-5e84-4a55-84e2-b701cb4bc5a8.png)

Copy the Blob SAS URL.


For example,

```bash
https://xxxxxxx.blob.core.windows.net/dmeo?sp=racwdl&st=2023-05-04T03:30:34Z&se=2023-05-04T11:30:34Z&spr=https&sv=2022-11-02&sr=c&sig=RQ0pM9d4zuAKuhSoYcDb8yE6rvij9yHkFDLdfgbvjIg%3Dupload strategy
```

**upload strategy**

Log in to the virtual machine and create the zip file with the name demo.zip. This file must have the files that, based on your expectations, need to be converted into a zip.
Open the command prompt and navigate to a particular location. This location should have a zip file if you followed the previous step.

**command**

```bash
curl -H "x-ms-blob-type: BlockBlob" --upload-file demo.zip --url "https://sdcmigration1.blob.core.windows.net/dmeo/demo.zip?sp=racwdl&st=2023-05-04T03:30:34Z&se=2023-05-04T11:30:34Z&spr=https&sv=2022-11-02&sr=c&sig=RQ0pM9d4zuAKuhSoYcDb8yE6rvij9yHkFDLdfgbvjIg%3D"
```

**Note** Include the file name in your URL.

Execution done, go to the azure storage account and navigate to the networking tab. Disable the virtual rule as earlier you had been created.

![image](https://user-images.githubusercontent.com/57703276/236110033-e71ab2af-ec06-4f57-95d1-b6aba0581465.png)

_navigate to storage account container_

![image](https://user-images.githubusercontent.com/57703276/236110077-b32cda69-bf2f-4e63-a127-f04d92e9820c.png)


Click the three dots and select the download option, and it will return the file via browser.
