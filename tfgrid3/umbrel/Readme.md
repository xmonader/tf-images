
# Umbrel v1.2.2 Flist for Threefold Grid

This repository provides instructions to build and deploy the Umbrel v1.2.2 application on the Threefold Grid as a flist. The process includes building a Docker image for the Umbrel app, pushing it to the Threefold registry, and creating flist.

### Umbrel
Umbrel is a personal server OS designed to run various self-hosted applications. For more information, visit the [Umbrel repository](https://github.com/getumbrel/umbrel).


- `app/`: Contains the Docker setup for the Umbrel v1.2.2 application
- `flist/`: Directory for creating the flist based on the Docker image
- `docker-compose.yml`: Compose file for setting up the necessary containers locally for testing (optional)

## Building the Umbrel App Docker Image

The base image for the Umbrel v1.2.2 app is derived from [dockur/umbrel](https://github.com/dockur/umbrel).

1. Navigate to the `app` directory:
   ```bash
   cd app
   ```

2. Build the Docker image:
   ```bash
   docker build -t threefolddev/umbrel_app:v1.2.2 .
   ```

3. Push the image to your Docker Hub:
   ```bash
   docker push threefolddev/umbrel_app:v1.2.2
   ```

## Creating the Umbrel Flist

The next step is to create the flist for the Umbrel application based on the Docker image.

1. Navigate to the `flist` directory and build the flist docker image :
   ```bash
   cd ../flist
   docker build -t threefolddev/umbrel-flist:v1.2.2 .
   ```

2. Use the following command to Build the Docker image of umbrel flist suitable for deployment on the Threefold Grid:
   ```bash
   docker push threefolddev/umbrel-flist:v1.2.2
   ```

3. The resulting flist, `threefolddev/umbrel-flist`, is now ready for deployment on the Threefold Grid.

## Deploying on Threefold Grid

- Use Upload or Docker Convert the flist to the [Threefold Hub](https://hub.grid.tf/) if not already done.


