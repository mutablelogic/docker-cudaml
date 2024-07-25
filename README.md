# docker-llamacpp

Repository which creates a llama.cpp server in a docker container, for amd64 and arm64,
the latter of which is missing from the "official" repository.

## Usage

If you want to use an NVIDIA GPU, then install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) first.

You should put your `.gguf` model files in a directory called `/data`. Then use the following command
to start the Llama server:

```bash
docker run \
  --runtime nvidia --gpus all \
  -v /data:/models -p 8080:8080 \ 
  --env LD_LIBRARY_PATH=/usr/local/cuda-12.5/compat \
  ghcr.io/mutablelogic/llamacpp-linux-arm64:0.0.3 \
  -m /models/mistral-7b-v0.1.Q4_K_M.gguf
```

(I will get rid of the LD_LIBRARY_PATH argument shortly). You can then access the Llama server on port 8080.

## Building

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
Currently the github action uses a self-hosted runner to build the arm64 image. The runner
seems to need about 12GB of memory to build the image.
