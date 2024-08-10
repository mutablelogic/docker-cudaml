# Paths to packages
DOCKER=$(shell which docker)
GIT=$(shell which git)
GO=$(shell which go)

# Other paths
ROOT_PATH := $(CURDIR)
BUILD_DIR := build

# Set OS and Architecture
ARCH ?= $(shell arch | tr A-Z a-z | sed 's/x86_64/amd64/' | sed 's/i386/amd64/' | sed 's/armv7l/arm/' | sed 's/aarch64/arm64/')
OS ?= $(shell uname | tr A-Z a-z)
VERSION ?= $(shell git describe --tags --always | sed 's/^v//')

# Docker tags
DOCKER_REGISTRY ?= ghcr.io/mutablelogic
DOCKER_TAG_BASE_BUILD="${DOCKER_REGISTRY}/cuda-dev-${OS}-${ARCH}:${VERSION}"
DOCKER_TAG_BASE_RUNTIME="${DOCKER_REGISTRY}/cuda-rt-${OS}-${ARCH}:${VERSION}"
DOCKER_TAG_LLAMACPP="${DOCKER_REGISTRY}/llamacpp-${OS}-${ARCH}:${VERSION}"

# ONNXRuntime flags 
ONNXRUNTIME_FLAGS := --config Release --build_shared_lib

# CUDA
ifdef CUDA_HOME
  GGML_CUDA := 1
  ONNXRUNTIME_FLAGS += --use_cuda --cuda_home=${CUDA_HOME} --cudnn_home=${CUDA_HOME}
endif

# Generate the pkg-config files
generate: mkdir go-tidy
	@echo "Generating pkg-config"
	@PKG_CONFIG_PATH=${ROOT_PATH}/${BUILD_DIR} go generate ./sys/llamacpp

# Test llamacpp bindings
test: generate llamacpp
	@echo "Running tests (sys)"
	@PKG_CONFIG_PATH=${ROOT_PATH}/${BUILD_DIR} ${GO} test -v ./sys/llamacpp/...

# Base images for building and running CUDA containers
docker-cuda: docker-dep
	@echo "Building ${DOCKER_TAG_BASE_BUILD}"
	@${DOCKER} build \
	  --tag ${DOCKER_TAG_BASE_BUILD} \
	  --build-arg ARCH=$(shell echo ${ARCH} | sed 's/amd64/x86_64/') \
	  --build-arg TARGET=build \
	  -f Dockerfile.cuda .
	@echo "Building ${DOCKER_TAG_BASE_RUNTIME}"
	@${DOCKER} build \
	  --tag ${DOCKER_TAG_BASE_RUNTIME} \
	  --build-arg ARCH=$(shell echo ${ARCH} | sed 's/amd64/x86_64/') \
	  --build-arg TARGET=runtime \
	  -f Dockerfile.cuda .

# Build docker container - assume we need to build the base images?
docker-cuda-push: docker-cuda
	@echo push docker images
	@${DOCKER} push ${DOCKER_TAG_BASE_BUILD}
	@${DOCKER} push ${DOCKER_TAG_BASE_RUNTIME}

# Build llama libraries
llamacpp: submodule-checkout
	@echo "Building llamacpp"
	@cd llama.cpp && make -j$(nproc) libllama.a libggml.a

onnxruntime: submodule-checkout
	@echo "Building onnxruntime"
	@cd onnxruntime && ./build.sh \
	  --parallel \
	  --compile_no_warning_as_error \
	  --skip_submodule_sync \
	  ${ONNXRUNTIME_FLAGS}

# Push docker container
docker-push: docker-dep 
	@echo push docker images
	@${DOCKER} push ${DOCKER_TAG_BASE_BUILD}
	@${DOCKER} push ${DOCKER_TAG_BASE_RUNTIME}
	@${DOCKER} push ${DOCKER_TAG_LLAMACPP}

# Update submodule to the latest version
submodule-update: git-dep
	@echo "Updating submodules"
	@${GIT} submodule foreach git pull origin master

# Submodule checkout
submodule-checkout: git-dep
	@echo "Checking out submodules"
	@${GIT} submodule update --init --remote

# Submodule clean
submodule-clean: git-dep
	@echo "Cleaning submodules"
	@${GIT} reset --hard
	@${GIT} submodule sync --recursive
	@${GIT} submodule update --init --force --recursive
	@${GIT} clean -ffdx
	@${GIT} submodule foreach --recursive git clean -ffdx	
	
# Make build directory
mkdir:
	@echo Mkdir ${BUILD_DIR}
	@install -d ${BUILD_DIR}

# go mod tidy
go-tidy: go-dep
	@echo Tidy
	@go mod tidy

# Clean
clean: submodule-clean go-tidy
	@echo "Cleaning"
	@rm -rf ${BUILD_DIR}
	
# Check for docker
docker-dep:
	@test -f "${DOCKER}" && test -x "${DOCKER}"  || (echo "Missing docker binary" && exit 1)

# Check for git
git-dep:
	@test -f "${GIT}" && test -x "${GIT}"  || (echo "Missing git binary" && exit 1)

# Check for go
go-dep:
	@test -f "${GO}" && test -x "${GO}"  || (echo "Missing go binary" && exit 1)
