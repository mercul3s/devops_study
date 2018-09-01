provider "docker" {
# this is the hostname of the docker service running on your machine
	host = "unix:///var/run/docker.sock" 
}

resource "docker_container" "webserver" {
	image = "${docker_image.nginx.latest}"
	name = "webserver"
    restart = "on-failure"
    must_run = "true" 
    ports {
        internal = 80
        external = 8080
    }
}

resource "docker_image" "nginx" {
	name = "nginx:latest"
}

