<h1> OpenWebUI Deployment with Ollama Flist</h1>

<h2> Table of Contents </h2>

- [Introduction](#introduction)
- [Directory Structure](#directory-structure)
- [Create the Docker Image](#create-the-docker-image)
- [Convert the Docker Image to Zero-OS FList](#convert-the-docker-image-to-zero-os-flist)
- [TFGrid Deployment](#tfgrid-deployment)
  - [Playground Steps](#playground-steps)
- [Conclusion](#conclusion)

***

## Introduction

This project provides a self-contained deployment of **OpenWebUI** on the ThreeFold Grid, using a micro VM. The deployment is managed via **zinit** for automatic service management and includes:

- Docker daemon for container management
- Secure SSH server configuration
- **OpenWebUI** with Ollama integration
- Automatic container updates via Watchtower
- Self-healing services via **zinit**

The deployment automatically provisions:
- Secure SSH access
- OpenWebUI on port `8080`
- Persistent storage for Docker and WebUI data

***

## Directory Structure

```
.
├── Dockerfile
├── README.md
├── scripts
│   ├── start_containers.sh
│   └── sshd_init.sh
└── zinit
    ├── dockerd.yaml
    ├── start_containers.yaml
    ├── sshd.yaml
    └── ssh-init.yaml
```

- **`scripts/`**: Contains initialization and service scripts
- **`zinit/`**: Contains **zinit** service configurations for managing services
- **`Dockerfile`**: Defines the Docker image with all dependencies and configurations

***

## Create the Docker Image

To create the Docker image:

1. Clone this repository:
   ```bash
   git clone https://github.com/threefoldtech/tf-images
   cd ./tf-images/tfgrid3/openwebui
   ```

2. Build the Docker image:
   ```bash
   docker build -t <your-dockerhub-username>/openwebui-tfgrid .
   ```

3. Push to Docker Hub:
   ```bash
   docker push <your-dockerhub-username>/openwebui-tfgrid
   ```

***

## Convert the Docker Image to Zero-OS FList

1. Use the [TF Hub Docker Converter](https://hub.grid.tf/docker-convert)
2. Enter your Docker image name:
   ```text
   <your-dockerhub-username>/openwebui-tfgrid:latest
   ```
3. Convert and get your FList URL (example):
   ```text
   https://hub.grid.tf/<your-3bot>/openwebui-tfgrid-latest.flist
   ```

***

## TFGrid Deployment

### Playground Steps

1. Go to [ThreeFold Dashboard](https://dashboard.grid.tf)
2. Create a Micro VM:
   - **VM Image**: Paste your FList URL
   - **Entry Point**: `/sbin/zinit init` (default)
   - **Resources**: Minimum 2 vCPU, 4GB RAM, 10GB disk
   - **Mount**: Add a mount point at `/mnt/data`
3. Deploy
4. Set a gateway domain with port 8080 to access OpenWebUI

***

## Conclusion

This FList provides a self-contained deployment of **OpenWebUI** with Ollama on the ThreeFold Grid with:
- Automatic service management via **zinit**
- Docker container management
- Automatic container updates via Watchtower
- SSH access for maintenance
- Persistent storage for data
- Easy deployment via Docker and TF Grid

Deploy and enjoy a fully functional OpenWebUI setup on the decentralized ThreeFold Grid!