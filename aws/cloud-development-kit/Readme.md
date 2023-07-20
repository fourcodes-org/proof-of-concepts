cloud development kit

| Operating System |
| --------------- |
| ubuntu machine ( x64 ) |
        
| Dependencies Packages |
| --------------- |
| sudo apt update |
| sudo apt install python3 -y |
| sudo apt install python3-pip -y |


cdk installtion && verify

        curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
        sudo apt-get install -y nodejs
        sudo npm -g install cdk
        cdk --version


| configure aws credentials |
| --------------- |
| aws configure |



Reference: 

- https://docs.aws.amazon.com/cdk/api/latest/python/aws_cdk.aws_lambda/Function.html
- https://pypi.org/project/aws-cdk.aws-s3-deployment/
- https://docs.aws.amazon.com/cdk/api/latest/python/index.html
