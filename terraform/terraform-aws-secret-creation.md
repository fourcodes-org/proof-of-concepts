
```tf
resource "aws_secretsmanager_secret" "sm1" {
  name = var.kms_id_secret_name
}

resource "aws_secretsmanager_secret_version" "sm1" {
  secret_id     = aws_secretsmanager_secret.sm1.id
  secret_string = var.kms_id_secret_value
}

variable "kms_id_secret_name" {}
variable "kms_id_secret_value" {}

kms_id_secret_name = ""
kms_id_secret_value = ""
```
