# Intro to [Docker](https://docs.docker.com/why-docker) and [Terraform](https://www.terraform.io/intro/index.html)


This repo is setup as a guide to help you explore using Docker to host a simple
web application, and then Terraform to deploy and start that application on an
aws instance.

## Getting started

To get up and running, you'll need to clone or fork this repository, and then
install Docker and Terraform. Both have builds available for mac, linux, and
windows:
* [docker](https://docs.docker.com/install/#supported-platforms) and
* [Terraform](https://www.terraform.io/intro/getting-started/install.html)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
(or brew install if using a mac)

_Optional_

If you'd like to run the terraform example to launch an instance on AWS, you'll
need to [sign up for an AWS account](https://aws.amazon.com/free/). This example
uses a t2.micro instance, which is eligible for Amazon's free tier. For new
accounts, t2 micro instances are free for up to 750 hours of use, but please
make sure to terminate your instances when you're done with them to avoid
getting billed!

Additionally, you'll need somewhere to host your docker container so that
Terraform can fetch it - you can do so on [dockerhub](https://hub.docker.com/), 
which is free.

## Directory structure

This repo contains the following:
* A Dockerfile, which tells Docker how to build a container
* Our application, which is a tiny web service written in Go. It lives in
./app/main.go.
* A terraform plan - plan.tf. This describes how to build and configure an
    instance on aws that runs our web service. 

## Running the examples

### Docker

To start, we'll need to build an image our docker container. We'll use the
`docker build` command, passing it a name for the container:

```bash
  $ docker build -t study-app:latest .
    Sending build context to Docker daemon  101.3MB
    Step 1/6 : FROM golang:alpine
    ---> 20ff4d6283c0
    Step 2/6 : WORKDIR /app
    ---> Running in f94f8f58e8e0
    Removing intermediate container f94f8f58e8e0
    ---> 790a4a4453d8
    Step 3/6 : ADD ./app /app
    ---> e4dc74e16252
    Step 4/6 : RUN go build -o main .
    ---> Running in 498a28750f8f
    Removing intermediate container 498a28750f8f
    ---> aa0bf9afbad1
    Step 5/6 : EXPOSE 8000
    ---> Running in 85d275779a3d
    Removing intermediate container 85d275779a3d
    ---> 674d41c5eb1b
    Step 6/6 : ENTRYPOINT ["./main"]
    ---> Running in 49b5be363fbd
    Removing intermediate container 49b5be363fbd
    ---> 4c1d75fc3ef6
    Successfully built 4c1d75fc3ef6
    Successfully tagged study-app:latest
```

The `-t` flag tells docker to tag the image with the name provided. A tag is a
description or label of a container; docker can pull images by tag from docker
hub or another docker repository. You'll often see tags labeled `latest`, and
also `beta`, `nightly`, or even build numbers to denote which version the
container might be.

Once you've successfully built the image, you can see it on your machine by
running `docker images`:

```bash
  $ docker images
    
    REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
    study-app               latest              4c1d75fc3ef6        3 minutes ago       318MB
```

Now that you have an image, it's time to run it! 

```bash
  $ docker run -p 80:8000 study-app:latest
```
The `-p` flag tells the docker container to listen on port 80, and forward any
incoming requests to our service running on port 8000.

If it's successful, you won't see any output - open a new terminal session and
do a curl request to the service to see the output:

```bash
  $ curl localhost
  'Sup nerds!
```

**Success!** Our service is running in the docker container.

If you'd like to deploy your shiny new container or allow others to use it,
you'll need to make your container publicly available.

```bash
  $ docker login # you'll be prompted for your dockerhub credentials
  $ docker push <dockerhub username>/study-app:latest
```

Dockerfile Questions
* What do `WORKDIR` and `ADD` do?
* How does docker open a port for the service to listen on?
* How does the application run when the container is started?

### Terraform

Want to go further? Let's try running our container in a cloud instance. Once
you have terraform installed, you'll need to
[initialize](https://www.terraform.io/docs/commands/init.html) it to create a
state file and install the provider modules:

```bash
  $ terraform init
    
    Initializing provider plugins...
    - Checking for available provider plugins on https://releases.hashicorp.com...
    - Downloading plugin for provider "aws" (1.34.0)...
    - Downloading plugin for provider "null" (1.0.0)...

    The following providers do not have any version constraints in configuration,
    so the latest version was installed.

    To prevent automatic upgrades to new major versions that may contain breaking
    changes, it is recommended to add version = "..." constraints to the
    corresponding provider blocks in configuration, with the constraint strings
    suggested below.

    * provider.aws: version = "~> 1.34"
    * provider.null: version = "~> 1.0"

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
```

You'll also need to install and configure the aws cli; see [amazon's official
documentation for instructions on how to do
so.](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

Once you have aws cli setup, you'll need to create a keypair so you can ssh to
the instance later.

```bash
  $ aws ec2 create-key-pair --key-name <username> --query 'KeyMaterial' --output text > <username>.pem
  $ chmod 0600 <username>.pem
```

#TODO: aws iam role and permissions instructions

Now you're ready to create instances with terraform. Before you do, you can see
what operations terraform will perform by doing a dry run.
 
Note: you will be prompted for your username and a key path. If you've followed
the previous directions, your key should be in the current directory.

```bash
  $ terraform plan
    var.key_path
      Enter a value: ./<username>.pem

    var.user_name
      Enter a value: merc

    Refreshing Terraform state in-memory prior to plan...
    The refreshed state will be used to calculate this plan, but will not be
    persisted to local or remote state storage.

    data.aws_canonical_user_id.current: Refreshing state...

    ------------------------------------------------------------------------

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
      + create

    Terraform will perform the following actions:

      + aws_instance.webserver
          id:                                    <computed>
          ami:                                   "ami-51537029"
          arn:                                   <computed>
          associate_public_ip_address:           "true"
          availability_zone:                     <computed>
          cpu_core_count:                        <computed>
          cpu_threads_per_core:                  <computed>
          ebs_block_device.#:                    <computed>
          ephemeral_block_device.#:              <computed>
          get_password_data:                     "false"
          iam_instance_profile:                  "devops-study"
          instance_state:                        <computed>
          instance_type:                         "t2.micro"
          ipv6_address_count:                    <computed>
          ipv6_addresses.#:                      <computed>
          key_name:                              "merc"
          network_interface.#:                   <computed>
          network_interface_id:                  <computed>
          password_data:                         <computed>
          placement_group:                       <computed>
          primary_network_interface_id:          <computed>
          private_dns:                           <computed>
          private_ip:                            <computed>
          public_dns:                            <computed>
          public_ip:                             <computed>
          root_block_device.#:                   <computed>
          security_groups.#:                     <computed>
          source_dest_check:                     "true"
          subnet_id:                             <computed>
          tags.%:                                "1"
          tags.Name:                             "merc.devops-study"
          tenancy:                               <computed>
          volume_tags.%:                         <computed>
          vpc_security_group_ids.#:              <computed>

      + aws_security_group.webserver
          id:                                    <computed>
          arn:                                   <computed>
          description:                           "Allow inbound traffic"
          egress.#:                              "1"
          egress.1986995490.cidr_blocks.#:       "1"
          egress.1986995490.cidr_blocks.0:       "0.0.0.0/0"
          egress.1986995490.description:         ""
          egress.1986995490.from_port:           "0"
          egress.1986995490.ipv6_cidr_blocks.#:  "1"
          egress.1986995490.ipv6_cidr_blocks.0:  "::/0"
          egress.1986995490.prefix_list_ids.#:   "0"
          egress.1986995490.protocol:            "-1"
          egress.1986995490.security_groups.#:   "0"
          egress.1986995490.self:                "false"
          egress.1986995490.to_port:             "0"
          ingress.#:                             "2"
          ingress.1378041496.cidr_blocks.#:      "1"
          ingress.1378041496.cidr_blocks.0:      "0.0.0.0/0"
          ingress.1378041496.description:        "ssh access"
          ingress.1378041496.from_port:          "22"
          ingress.1378041496.ipv6_cidr_blocks.#: "1"
          ingress.1378041496.ipv6_cidr_blocks.0: "::/0"
          ingress.1378041496.protocol:           "tcp"
          ingress.1378041496.security_groups.#:  "0"
          ingress.1378041496.self:               "false"
          ingress.1378041496.to_port:            "22"
          ingress.4265099936.cidr_blocks.#:      "1"
          ingress.4265099936.cidr_blocks.0:      "0.0.0.0/0"
          ingress.4265099936.description:        "http access"
          ingress.4265099936.from_port:          "80"
          ingress.4265099936.ipv6_cidr_blocks.#: "1"
          ingress.4265099936.ipv6_cidr_blocks.0: "::/0"
          ingress.4265099936.protocol:           "tcp"
          ingress.4265099936.security_groups.#:  "0"
          ingress.4265099936.self:               "false"
          ingress.4265099936.to_port:            "80"
          name:                                  "devops-study"
          owner_id:                              <computed>
          revoke_rules_on_delete:                "false"
          vpc_id:                                <computed>

      + null_resource.provision_docker
          id:                                    <computed>


    Plan: 3 to add, 0 to change, 0 to destroy.

    ------------------------------------------------------------------------

    Note: You didn't specify an "-out" parameter to save this plan, so Terraform
    can't guarantee that exactly these actions will be performed if
    "terraform apply" is subsequently run. 

  ```

Terraform will let you know if you have any errors with your plan file, or
permissions problems in AWS. If the output looks like the above, you are good to
go, and you can create infrastructure with `terraform apply`.

```bash
  $ terraform apply --auto-approve
```
