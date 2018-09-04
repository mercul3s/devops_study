# prompt for your aws iam username and account key path.

variable "user_name" {}

variable "region" {
    default = "us-west-2"
}

provider "aws" {
    region = "${var.region}"
}

data "aws_canonical_user_id" "current" {}

locals {
  "account_name" = "${var.user_name}"
}

resource "aws_security_group" "webserver" {
  
  name = "devops-study"
  description = "Allow inbound traffic"
  
  // ssh access
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description = "ssh access"
  }
  
  // web access
  ingress {
      from_port   = 80 
      to_port     = 8000 
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description = "http access"
  }
}

resource "aws_instance" "webserver" {
    ami           = "ami-51537029"
    instance_type = "t2.micro"
    iam_instance_profile = "devops-study" 
    associate_public_ip_address = true
    key_name = "${var.user_name}" 
    
    timeouts {
        create = "10m"
        delete = "10m"
    }
   
    tags {
        Name = "${local.account_name}.devops-study"
    }
    
    vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
}

resource "aws_launch_configuration" "provisioner" {
  image_id        = "ami-51537029"
  instance_type   = "t2.micro"
  key_name = "${local.account_name}"
  security_groups = ["${aws_security_group.webserver.id}"]
  user_data       = "${file("provision_script.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

/*
provider "docker" {
# this is the hostname of the docker service running on your machine
	host = "unix:///var/run/docker.sock" 
}

resource "docker_container" "webserver" {
	image = "${docker_image.study_app.latest}"
	name = "webserver"
    restart = "on-failure"
    must_run = "true" 
    ports {
        internal = 8000
        external = 80
    }
}


resource "docker_image" "study_app" {
	name = "mercul3s/devops-study:latest"
}
*/
