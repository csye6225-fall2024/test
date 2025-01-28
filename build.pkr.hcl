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

resource "aws_security_group" "webapp_sg" {
  name        = "webapp-security-group"
  description = "Security group for web app allowing HTTP and HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

source "amazon-ebs" "custom_ami" {
  ami_name    = "webapp-ami-${local.timestamp}"
  ami_regions = [var.region]

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

  security_group = [aws_security_group.webapp_sg.name]

  tags = {
    Name = "Webapp AMI"
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
