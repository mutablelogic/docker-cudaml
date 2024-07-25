ARG UBUNTU_VERSION=22.04
ARG CUDA_VERSION=12.5.1
ARG BASE_CUDA_DEV_CONTAINER=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}
ARG BASE_CUDA_RUN_CONTAINER=nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

# Setup build container
FROM ${BASE_CUDA_DEV_CONTAINER} AS build
ARG CUDA_DOCKER_ARCH=all
RUN apt-get -y update && apt-get -y install build-essential git libcurl4-openssl-dev
WORKDIR /app
COPY . .

# Make llama-server
ENV CUDA_DOCKER_ARCH=${CUDA_DOCKER_ARCH}
ENV GGML_CUDA=1
ENV LLAMA_CURL=1
RUN make -j$(nproc) llama-server

# Setup runtime container
FROM ${BASE_CUDA_RUN_CONTAINER} AS runtime
RUN apt-get -y update && apt-get  -y install libcurl4-openssl-dev libgomp1 curl
COPY --from=build /app/llama.cpp/llama-server /llama-server

# Expose
HEALTHCHECK CMD [ "curl", "-f", "http://localhost:8080/health" ]
ENTRYPOINT [ "/llama-server" ]