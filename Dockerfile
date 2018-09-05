# use golang image to build our binary
FROM golang:alpine

# WORKDIR is the directory that will host our application. It is created if it
# doesn't already exist.
WORKDIR /app

# ADD copies the contents of the current directory to our working directory.
ADD ./app /app

# compile the application
RUN go build -o main .

# EXPOSE opens a port on the container to the outside world.
EXPOSE 8000

# and finally, run it on start.
ENTRYPOINT ["./main"]
