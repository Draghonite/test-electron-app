provider "aws" {
  region = var.region
}

#region Jenkins server

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["al*-ami-*-kernel-*-x86_64"]
  }
}

# TODO: may need to make the windows instance dependent on this instance or conditional on var
resource "aws_instance" "jenkins" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.large"
  user_data = templatefile("user-data/user_data.sh", {

  })
  key_name = var.key_pair_name

  vpc_security_group_ids = var.jenkins_security_group_ids
  source_dest_check = false

  tags = var.tags
}

#endregion

#region Windows build agent

data "aws_ami" "windows" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows" {
  count = length(var.jenkins_core_url) > 0 && length(var.jenkins_core_secret) > 0 ? 1 : 0

  ami = data.aws_ami.windows.id
  instance_type = "t2.medium"
  user_data = templatefile("user-data/user_data.ps1", {
    windows_instance_name = var.windows_instance_name
    jenkins_core_url = var.jenkins_core_url
    jenkins_core_secret = var.jenkins_core_secret
    jenkins_core_agent = var.jenkins_core_agent
  })
  key_name = var.key_pair_name

  vpc_security_group_ids = var.windows_security_group_ids
  source_dest_check = false

  tags = var.tags
}

#endregion
