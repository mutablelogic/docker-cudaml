# docker-cudaml

Repository which has some base images for running CUDA and cuDNN on Intel and ARM architectures.

## CUDA Images

If you want to use an NVIDIA GPU, then install the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) first. You can use the following two images as the basis for your own images:

* `ghcr.io/mutablelogic/cuda-dev:1.0.2` - This image is based on Ubuntu 22.04 and includes the 12.6 CUDA toolkit and compiler build tools
* `ghcr.io/mutablelogic/cuda-rt:1.0.2` - This image is based on Ubuntu 22.04 and includes the 12.6 CUDA runtime libraries.
