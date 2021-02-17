# My App

Build a sample Golang application + Docker for `linux/amd64` and `linux/aarch64` platforms and push to private (insecure) registry.

> Based upon [Tutorial: Everything You Need To Become a GitOps Ninja - Alex Collins & Alexander Matyushentsev](https://www.youtube.com/watch?v=r50tRQjisxw), modified for the video series "Bank of Pi" to explain the concept of GitOps.
## Setup your build environment

1. Create the builder configuration file [./private-registry.toml](./private-registry.toml) containing the registry information.

    ~~~toml
   [registry."registry.tekqube.lan:32000"]
        http = true
        insecure = true
    ~~~

2. Create a builder definition using the configuration file above

   ~~~bash
   # Create a new build context
   $ docker buildx create \
        --use \
        --name my-app-build \
        --config private-registry.toml

   my-app-build

   # Inspect and bootrap the builder
   $ docker buildx inspect --bootstrap

   [+] Building FINISHED
    => [internal] booting buildkit                           2.2s
    => => pulling image moby/buildkit:buildx-stable-1        1.6s
    => => creating container buildx_buildkit_my-app-build0   0.6s
   Name:   my-app-build
   Driver: docker-container

   Nodes:
   Name:      my-app-build0
   Endpoint:  unix:///var/run/docker.sock
   Status:    running
   Platforms: linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
   ~~~

## Build

Build the Docker and push to the registry.
    
~~~bash
# Build and push to the local repository
$ docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag registry.tekqube.lan:32000/gitops-workshop/my-app:v1 \
    --push .

[+] Building
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 316B
 => [internal] load .dockerignore
 ...
 => [builder 2/3] ADD my-app.go /src/my-app.go
 => [linux/amd64 builder 3/3] RUN GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /dist/my-app /src/my-app.go
 => [linux/amd64 builder 3/3] RUN GOOS=linux GOARCH=arm64 go build -ldflags="-w -s" -o /dist/my-app /src/my-app.go
 => [stage-1 1/1] COPY --from=builder /dist/my-app /my-app
 => exporting to image
 => => exporting layers
 ...
 => => pushing manifest for registry.tekqube.lan:32000/gitops-workshop/my-app:v1
~~~

## Run

Run the Docker, either on the build machine (amd64) or Raspberry Pi cluster:

~~~bash
# The Docker daemon will automatically download the appropriate architecture
$ docker run -e GREETING=Howdy registry.tekqube.lan:32000/gitops-workshop/my-app:v1
~~~

> **Note**: your Docker daemon needs to trust the insecure registry, add the following to `/etc/docker/daemon.json`:
> ~~~json
> {
>    "insecure-registries" : [ "registry.tekqube.lan:32000" ]
> }
> ~~~

## Clean Up

~~~bash
# Remove local image data
$ docker rmi registry.tekqube.lan:32000/gitops-workshop/my-app:v1
~~~
