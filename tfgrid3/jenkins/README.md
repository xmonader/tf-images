# Jenkins TF Image

A Docker-based flist used to deploy Jenkins on the Threefold Grid. This image sets up a Jenkins server with the ability to configure the admin username and password through environment variables, enabling automated setup without manual intervention. The image also includes SSH capabilities, allowing remote access to the Jenkins server.

## How to Use

1. **Build the Image**:  
   - Convert the Docker image into a flist.

2. **Upload the Flist**:  
   - Upload the flist to hub.grid.tf using the UI or via `curl` with an [API token](https://hub.grid.tf/token).

3. **Deploy on the Threefold Grid**:  
   - Deploy a VM on the Threefold Grid and use this flist as the root filesystem.
   - Ensure the necessary environment variables (as outlined below) are passed during deployment.

## Environment Variables

To configure the Jenkins setup, you need to provide the following environment variables:

- `JENKINS_ADMIN_USERNAME`: Username for the Jenkins admin account.
- `JENKINS_ADMIN_PASSWORD`: Password for the Jenkins admin account.
- `SSH_KEY`: SSH public key for remote access. This key will be added to the `authorized_keys` file of the root user.

## Jenkins Configuration
The image includes a Groovy script that automatically creates the Jenkins admin user based on the provided environment variables. This script runs during the initial setup of Jenkins, bypassing the need for manual configuration through the Jenkins UI.


## Testing

You can use the flist provided [here](https://hub.grid.tf/amryassir.3bot/amryassir-jenkinsv2-latest.flist.md)

### Deploy the VM:

- Deploy a VM with the Jenkins flist on the Threefold Grid.
- Ensure that the environment variables `JENKINS_ADMIN_USERNAME` and `JENKINS_ADMIN_PASSWORD` are set.

### Access Jenkins:

- Once the VM is running, access Jenkins via the VM's IP address on port `80`.
- Log in using the credentials specified in the environment variables.
