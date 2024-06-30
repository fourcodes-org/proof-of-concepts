provider "aws" {
    region = var.aws_region
    sts_region = var.aws_region
}

terraform {
    backend "s3" {}
}