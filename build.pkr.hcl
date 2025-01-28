packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "root"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "ami_id" {
  type    = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "username" {
  type    = string
  default = "ubuntu"
}


# variable "additional_account_id" {
#   type    = string
#   default = "ami-1234"
# }

variable "device_name" {
  type    = string
  default = "/dev/sda1"
}

variable "volume_size" {
  type    = string
  default = "20"
}

variable "volume_type" {
  type    = string
  default = "gp2"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "custom_ami" {
  ami_name    = "webapp-ami-${local.timestamp}"
  ami_regions = [var.region]


  //ami_users = [var.additional_account_id]

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  instance_type = var.instance_type
  source_ami    = var.ami_id
  ssh_username  = var.username

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = var.device_name
    volume_size           = var.volume_size
    volume_type           = var.volume_type
  }

  tags = {
    Name = "Jenkins AMI"
    Date = local.timestamp
  }
}

build {
  name    = "Webapp AMI"
  sources = ["source.amazon-ebs.custom_ami"]

  provisioner "shell" {
    script = "updateOS.sh"
  }

  provisioner "shell" {
    script = "jenkins.sh"
  }


}
