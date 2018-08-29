I'll do an ~10-15 minute talk introducing infrastructure as code where we will cover:
- what are infrastructure templating and configuration management
- an example scenario for how to use tooling to build and configure a webserver
- an intro to Terraform
- an overview of the exercise (currently writing this up, will give you a link to a repo by friday!)
Then we'll go through the exercise together. By the end of the study session, you will hopefully have a local docker container configured and built by Terraform.
To run the exercise, you will need to install
[docker](https://docs.docker.com/install/#supported-platforms) and
[Terraform](https://www.terraform.io/intro/getting-started/install.html)
Docker and Terraform have builds available for mac, linux, and windows.

# TODO:
- create a shared ssh key (note why this is insecure)
- ~~writeup instructions for python/virtualenv/ansible and terraform installi~~
- (or just create a vm???)
- install terraform
	- terraform apply will do:
	- creates a docker or vagrant host that installs python, ansible, and an ssh key via ansible
	- for the study session: 
		- clone the repo
		- install terraform
		- terraform init
		```
		$ terraform init
		Initializing provider plugins...
    Checking for available provider plugins on https://releases.hashicorp.com...
    Downloading plugin for provider "docker" (1.0.1)...

    <output abbreviated> 

    * provider.docker: version = "~> 1.0"

    Terraform has been successfully initialized!

    <output abbreviated> 

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
```
		- terraform apply
		- then go hack on ansible!

	- go over: 
		- what config management and provisioning scripts are for, and how they differ
		- why we use both
		- ansible console
		- think of some other things to install!
		- change something and run ansible to configure it

	- list of commands to explan
		- terraform init
		- terraform plan
		- terraform apply
