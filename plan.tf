provider "docker" {
# this is the hostname of the docker service running on your machine
	host = "unix:///var/run/docker.sock" 
}

resource "docker_container" "foo" {
	image = "${docker_image.ubuntu.latest}"
	name = "foo"
}

resource "docker_image" "ubuntu" {
	name = "ubuntu:latest"
}
