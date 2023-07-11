```tf
resource "aws_secretsmanager_secret" "scm" {
  name = var.rc_secret_name
}

resource "aws_secretsmanager_secret_version" "scm" {
  secret_id     = aws_secretsmanager_secret.scm.id
  secret_string = jsonencode(var.rc_secret_value)
}

variable "rc_secret_name" {}
variable "rc_secret_value" {
  type = map(string)
}



rc_secret_name = "respoce_controller_secret"
rc_secret_value = {
    key1 = "value1"
    key2 = "value2"
}

```
