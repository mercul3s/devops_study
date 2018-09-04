# prompt for your aws iam username and account key path.

variable "user_name" {}
variable "region" {
    default = "us-west-2"
}

provider "aws" {
    region = "${var.region}"
}

resource "aws_security_group" "instance" {
  
  name = "devops-study"
    // ssh access
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ssh access"
  }
  
  // web access
  ingress {
      from_port   = 80 
      to_port     = 8080 
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ssh access"
  }
}

resource "aws_instance" "webserver" {
    ami           = "ami-51537029"
    instance_type = "t2.micro"
    iam_instance_profile = "${var.user_name}" 
    associate_public_ip_address = true
    key_name = "${var.user_name}" 
    
    timeouts {
        create = "10m"
        delete = "10m"
    }
   
    tags {
        Name = "${var.user_name}.devops-study"
    }
}

resource "aws_launch_configuration" "provisioner" {
  image_id        = "ami-51537029"
  instance_type   = "t2.micro"
  key_name = "${var.user_name}"
  security_groups = ["${aws_security_group.instance.id}"]
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
