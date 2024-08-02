# Paths to packages
DOCKER=$(shell which docker)
GIT=$(shell which git)

# Set OS and Architecture
ARCH ?= $(shell arch | tr A-Z a-z | sed 's/x86_64/amd64/' | sed 's/i386/amd64/' | sed 's/armv7l/arm/' | sed 's/aarch64/arm64/')
OS ?= $(shell uname | tr A-Z a-z)
VERSION ?= $(shell git describe --tags --always | sed 's/^v//')

# Docker tags
DOCKER_REGISTRY ?= ghcr.io/mutablelogic
DOCKER_TAG_BASE_BUILD="${DOCKER_REGISTRY}/cuda-dev-${OS}-${ARCH}:${VERSION}"
DOCKER_TAG_BASE_RUNTIME="${DOCKER_REGISTRY}/cuda-rt-${OS}-${ARCH}:${VERSION}"
DOCKER_TAG_LLAMACPP="${DOCKER_REGISTRY}/llamacpp-${OS}-${ARCH}:${VERSION}"

# Base images for building and running CUDA containers
docker-base: docker-dep
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
docker: docker-dep docker-base
	@echo "Building ${DOCKER_TAG_LLAMACPP}"
	@${DOCKER} build \
		--tag ${DOCKER_TAG_LLAMACPP} \
		--build-arg ARCH=${ARCH} \
		--build-arg BASE_IMAGE_BUILD=${DOCKER_TAG_BASE_BUILD} \
		--build-arg BASE_IMAGE_RUNTIME=${DOCKER_TAG_BASE_RUNTIME} \
		-f Dockerfile.llamacpp .

# Build llama-server
llama-server: submodule
	@echo "Building llama-server"
	@cd llama.cpp && make -j4 llama-server
	
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
submodule: git-dep
	@echo "Checking out submodules"
	@${GIT} submodule update --init --recursive --remote

# Check for docker
docker-dep:
	@test -f "${DOCKER}" && test -x "${DOCKER}"  || (echo "Missing docker binary" && exit 1)

# Check for git
git-dep:
	@test -f "${GIT}" && test -x "${GIT}"  || (echo "Missing git binary" && exit 1)