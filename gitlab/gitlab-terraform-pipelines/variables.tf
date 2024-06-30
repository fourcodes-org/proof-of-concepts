variable "aws_region" {
    type        = string
    default     = "ap-southeast-1"
    description = "The AWS region where resources will be deployed"
}

variable "environment" {
    type        = string
    default     = "dev"
    description = "The environment in which the infrastructure will be deployed (e.g., dev, uat, prd)"
}