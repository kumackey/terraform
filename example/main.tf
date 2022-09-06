provider "aws" {
  region = "ap-northeast-1"
}

locals {
  example_instance_type = "t3.micro"
}

module "web_server" {
  source = "./http_server"
  instance_type = local.example_instance_type
}

output "example_public_dns" {
  value = module.web_server.example_public_dns
}