
```tf
resource "aws_secretsmanager_secret" "kms_id_secret_name" {
  name = var.kms_id_secret_name
}

resource "aws_secretsmanager_secret_version" "kms_id_secret_value" {
  secret_id     = aws_secretsmanager_secret.kms_id_secret_name.id
  secret_string = var.kms_id_secret_value
}

variable "kms_id_secret_name" {}
variable "kms_id_secret_value" {}

kms_id_secret_name = ""
kms_id_secret_value = ""
```
