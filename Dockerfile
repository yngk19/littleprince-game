# Base image for appropriate architecture and OS
ARG BASE_IMAGE=ubuntu:22.04

FROM $BASE_IMAGE

# Install Free Pascal
RUN apt-get update && apt-get install -y fpc

# Set workdir
WORKDIR /app

# Copy main.pas to the container
COPY main.pas .

# Command to compile and run when the container starts
CMD ["fpc", "main.pas"] && ["./main"]
