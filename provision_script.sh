#!/bin/bash

# add docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# update apt
sudo apt-get update
apt-cache policy docker-ce

# install docker
sudo apt-get install -y docker-ce

# pull the container from docker-hub
sudo docker pull mercul3s/devops-study:latest 

# run the container, mapping port 80 to the container's 8080 open port
sudo docker run -d -p 80:8080 mercul3s/devops-study:latest 
