resource "aws_ssm_parameter" "db_username" {
  name = "/db/username"
  type = "String"
  value = "root"
  description = "データベースのユーザ名"
}

resource "aws_ssm_parameter" "db_raw_password" {
  name = "/db/raw_password"
  type = "SecureString"
  value = "uninitialized"
  description = "データベースのパスワード"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

