# docker-cudaml

Repository which has some base images for running CUDA and cuDNN on Intel and ARM architectures.

## CUDA Images

If you want to use an NVIDIA GPU, You can use the following two images as the basis for your own images:

* `ghcr.io/mutablelogic/cuda-dev:1.0.2` - This image is based on Ubuntu 22.04 and includes the 12.6 CUDA toolkit and compiler build tools
* `ghcr.io/mutablelogic/cuda-rt:1.0.2` - This image is based on Ubuntu 22.04 and includes the 12.6 CUDA runtime libraries.

When running a runtime container, then install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) first. Then you can run the container with the following command:

```bash
docker run \
  --name <name> --rm \
  --runtime nvidia --gpus all 
  <image> <arguments>
```
