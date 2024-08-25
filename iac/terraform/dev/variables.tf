
variable "region" {
  type = string
}

variable "env" {
  type = string
  default = "dev"
}

variable "app_name" {
  type = string
}

variable "tags" {
  type = map
}

variable "key_pair_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "windows_instance_name" {
  type = string
}

variable "windows_security_group_ids" {
  type = list
}

variable "jenkins_core_url" {
  type = string
}

variable "jenkins_core_secret" {
  type = string
}

variable "jenkins_core_agent" {
  type = string
}

variable "jenkins_security_group_ids" {
  type = list
}
