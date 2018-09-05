# prompt for your aws iam username and account key path.

variable "user_name" {}
variable "key_path" {}

variable "region" {
    default = "us-west-2"
}

provider "aws" {
    region = "${var.region}"
}

data "aws_canonical_user_id" "current" {}

locals {
  "account_name" = "${var.user_name}"
  "private_key" = "${var.key_path}"
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

  // route out to the internet
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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

resource "null_resource" "provision_docker" {
    connection {
        host = "${aws_instance.webserver.public_ip}"
        type = "ssh"
        user = "ubuntu"
        agent_identity = "${local.account_name}"
        private_key = "${file("${local.private_key}")}"
    }

    provisioner "remote-exec" {
        inline = [
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
            "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'",
            "sudo apt-get update",
            "apt-cache policy docker-ce",
            "sudo apt-get install -y docker.io",
            "sudo docker pull mercul3s/devops-study:latest",
            "sudo docker run -d -p 8000:8000 mercul3s/devops-study:latest"
        ]
    }
}
