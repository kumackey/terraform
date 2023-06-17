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

data "aws_iam_policy_document" "ec2_for_ssm" {
  source_json = data.aws_iam_policy.ec2_for_ssm.policy

  statement {
    effect = "Allow"
    resources = [
      "*"
    ]

    actions = [
    ]
  }
}

data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "ec2_for_ssm_role" {
  source = "./iam"
  name = "ec2-for-ssm"
  identifier = "ec2.amazonaws.com"
  policy = data.aws_iam_policy_document.ec2_for_ssm.json
}

resource "aws_iam_instance_profile" "ec2_for_ssm" {
  name = "ec2-for-ssm"
  role = module.ec2_for_ssm_role.iam_role_name
}

resource "aws_instance" "example_for_operation" {
  ami = "ami0c3fd0f5d33134a76"
  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_for_ssm.name
  subnet_id = aws_subnet.private_0.id
  user_data = file("./user_data.sh")
}

output "operation_instance_id" {
  value = aws_instance.example_for_operation.id
}

resource "aws_s3_bucket" "operation" {
  bucket = "operation-pragmatic-terraform"

  lifecycle_rule {
    enabled = true

    expiration {
      days = "180"
    }
  }
}

resource "aws_cloudwatch_log_group" "operation" {
  name = "/operation"
  retention_in_days = 180
}

resource "aws_ssm_document" "session_manager_run_shell" {
  document_type = "Session"
  document_format = "JSON"
  name = "SSM-SessionManagerRunShell"
  content = <<EOF
{
}
EOF
}