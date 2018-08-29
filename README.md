# TODO:
- create a shared ssh key (note why this is insecure)
- writeup instructions for python/virtualenv/ansible and terraform install
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
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "docker" (1.0.1)...

...

* provider.docker: version = "~> 1.0"

Terraform has been successfully initialized!

... 

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
