resource "aws_iam_group" "admin" {
  name = "admin"
  path = "/"
}

resource "aws_iam_user" "kumaki" {
  name = "kumaki"
  path = "/"
}

resource "aws_iam_user" "terraform" {
  name = "terraform"
  path = "/"
}

resource "aws_iam_user_group_membership" "kumaki_admin" {
  user   = aws_iam_user.kumaki.name
  groups = [
    aws_iam_group.admin.name
  ]
}

resource "aws_iam_user_group_membership" "terraform_admin" {
  user   = aws_iam_user.terraform.name
  groups = [
    aws_iam_group.admin.name
  ]
}

data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "admin_administrator_access" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

data "aws_iam_policy" "iam_user_change_password" {
  arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_user_policy_attachment" "kumaki_iam_user_change_password" {
  user       = aws_iam_user.kumaki.name
  policy_arn = data.aws_iam_policy.iam_user_change_password.arn
}