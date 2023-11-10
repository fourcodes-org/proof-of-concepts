## Terraform Offline Mode Setup for AWS

### Overview

This guide outlines the steps to enable Terraform offline mode for managing AWS EC2 instances. Offline mode is useful when internet access is restricted, and you need to use Terraform with AWS providers.

### Prerequisites

- Terraform installed locally
- AWS CLI configured with necessary credentials
- Internet access to download Terraform providers initially

### Steps

#### 1. Configure Provider File

Edit your Terraform provider file (`main.tf` or any other name) to include the necessary backend configuration and AWS provider setup.

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-store"
    key            = "test.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
  required_providers {
    aws = {}
    local = {}
  }
}

provider "aws" {
  region    = "ap-southeast-1"
  sts_region = "ap-southeast-1"
  endpoints {
    sts = "https://sts.ap-southeast-1.amazonaws.com"
  }
}
```

#### 2. Test Configuration

Run the following commands to test and initialize the Terraform configuration:

```bash
AWS_STS_REGIONAL_ENDPOINTS=regional terraform init
export AWS_STS_REGIONAL_ENDPOINTS=regional
TF_LOG=DEBUG terraform init
```

#### 3. Create Local Terraform Provider Directory

##### 3.1 For AWS Provider

Create the directory for the AWS provider:

```bash
mkdir -p .terraform.d/plugins/registry.terraform.io/hashicorp/aws/
cd .terraform.d/plugins/registry.terraform.io/hashicorp/aws/
wget https://releases.hashicorp.com/terraform-provider-aws/5.24.0/terraform-provider-aws_5.24.0_linux_amd64.zip
unzip terraform-provider-aws_5.24.0_linux_amd64.zip
cd -
```

##### 3.2 For Local Provider

Create the directory for the local provider:

```bash
mkdir -p .terraform.d/plugins/registry.terraform.io/hashicorp/local/
cd .terraform.d/plugins/registry.terraform.io/hashicorp/local/
wget https://releases.hashicorp.com/terraform-provider-local/2.4.0/terraform-provider-local_2.4.0_linux_amd64.zip
unzip terraform-provider-local_2.4.0_linux_amd64.zip
cd -
```

#### 4. Terraform Init with Local Providers

Run the following command to initialize Terraform, including the local provider directory:

```bash
TF_LOG=DEBUG terraform init -plugin-dir=".terraform.d/plugins/" -reconfigure
```

If there are no changes to the provider configuration, you can use the following command:

```bash
terraform init -plugin-dir=".terraform.d/plugins/"
```

### Conclusion

You have successfully set up Terraform in offline mode with the required AWS providers for managing EC2 instances. Ensure to follow these steps whenever you update the Terraform provider versions or change the configuration.
