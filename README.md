# docker-llamacpp

Repository which creates a llama.cpp server in a docker container, for amd64 and arm64,
the latter of which is missing from the "official" repository.

## Usage

The following will build the docker image and push to the repository:

```bash
git checkout git@github.com:mutablelogic/docker-llamacpp.git
cd docker-llamacpp
make docker && make docker-push
```

Set the environment variable DOCKER_REGISTRY to the name of the registry to push to, e.g.:

```bash
git checkout git@github.com:mutablelogic/docker-llamacpp.git
cd docker-llamacpp
DOCKER_REGISTRY=docker.io/user make docker && make docker-push
```

## Status

Requires the ability to update the llama.cpp submodule to the master branch.
Currently the github action uses a self-hosted runner to build the arm64 image.
