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

