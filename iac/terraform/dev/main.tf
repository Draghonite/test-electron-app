provider "aws" {
  region = var.region
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows" {
  ami = data.aws_ami.windows.id
  instance_type = "t2.medium"
  user_data = templatefile("user_data.ps1", {
    windows_instance_name = var.windows_instance_name
    jenkins_core_url = var.jenkins_core_url
    jenkins_core_secret = var.jenkins_core_secret
    jenkins_core_agent = var.jenkins_core_agent
  })
  key_name = var.key_pair_name

  vpc_security_group_ids = var.security_group_ids
  source_dest_check = false

  tags = var.tags
}
