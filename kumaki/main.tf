provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      ManagedBy = "Terraformer"
    }
  }
}

variable "notification_emails" {
  type    = list(string)
  default = [
    "kumak1t09e0@gmail.com"
  ]
}

resource "aws_budgets_budget" "total" {
  name              = "total_budgets"
  budget_type       = "COST"
  limit_amount      = "10.0"
  limit_unit        = "USD"
  time_unit         = "DAILY"
  time_period_start = "2023-05-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 20
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.notification_emails
  }
}

