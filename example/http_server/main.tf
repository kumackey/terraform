variable "instance_type" {}

data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners = [
    "amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name = "state"
    values = [
      "available"]
  }
}

resource "aws_instance" "example" {
  ami = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.example_ec2.id]

  user_data = file("${path.module}/user_data.sh")
}

resource "aws_security_group" "example_ec2" {
  name = "example-ec2"

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

output "example_public_dns" {
  value = aws_instance.example.public_dns
}