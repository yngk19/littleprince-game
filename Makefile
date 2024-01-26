.PHONY: all windows darwin linux

# Docker image name
IMAGE_NAME ?= my-fpc-app

# Build directory for Docker context
BUILD_DIR ?= build

# Define platform-specific build and run targets
windows:
	docker build -t ${IMAGE_NAME}-windows -m windows .
	docker run --rm -v ${PWD}:/app ${IMAGE_NAME}-windows

darwin:
	docker build -t ${IMAGE_NAME}-darwin -m darwin .
	docker run --rm -v ${PWD}:/app ${IMAGE_NAME}-darwin

linux:
	docker build -t ${IMAGE_NAME}-linux -m linux .
	docker run --rm -v ${PWD}:/app ${IMAGE_NAME}-linux

all: windows darwin linux
