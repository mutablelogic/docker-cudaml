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
  ghcr.io/mutablelogic/llamacpp-linux-arm64:0.0.3 \
  --host 0.0.0.0 \
  --model /models/mistral-7b-v0.1.Q4_K_M.gguf -ngl 32 --ctx-size 4096 --temp 0.7 --repeat_penalty 1.1 \
  --in-prefix "<|im_start|>" --in-suffix "<|im_end|>"
```

You can then access the Llama server on port 8080.

## Building

To build either the llama.cpp library or the onnxruntime library:

```bash
CUDA_HOME=/usr/local/cuda make llamacpp onnxruntime
```

You can omit the CUDA_HOME environment variable if you don't want to build with CUDA support.
The following will build a docker image and push to the repository:

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
