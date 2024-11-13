<h1> Ubuntu XRDP VM Flist Creator </h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Manual Method](#manual-method)
  - [Using Makefile](#using-makefile)
- [What the Script Does](#what-the-script-does)
- [Notes](#notes)
- [Troubleshooting](#troubleshooting)
- [Clean Up](#clean-up)
- [Server Side: Dashboard Deployment](#server-side-dashboard-deployment)
- [Client Side: Install Remote Desktop Connection for Windows, MAC or Linux](#client-side-install-remote-desktop-connection-for-windows-mac-or-linux)
  - [Download the App](#download-the-app)
  - [Connect Remotely](#connect-remotely)
- [License](#license)

---

## Introduction

This directory contains a script to create a VM flist with Ubuntu and XRDP for the ThreeFold Grid. The flist includes a desktop environment (XFCE) and XRDP, allowing for remote desktop access to your deployed VM.

> Note: This is not an officially supported flist. You can use it as a guide to build your own.

## Prerequisites

- A Linux system with root access
- Sufficient disk space (at least 10GB free)
- A [ThreeFold ZOS Hub](https://manual.grid.tf/documentation/developers/flist/flist_hub/zos_hub.html) account with an API key
- `make` utility installed on your system (optional, for Makefile method)

## Usage

### Manual Method

1. Clone this repository:
   ```
   git clone https://github.com/threefoldtech/tf-images
   cd ./tf-images/tfgrid3/ubuntu_24_xrdp
   ```

2. Make the script executable:
   ```
   chmod +x create_vm_ubuntu_xrdp_flist.sh
   ```

3. Run the script with sudo privileges, providing your [ThreeFold ZOS Hub API key](https://manual.grid.tf/documentation/developers/flist/flist_hub/api_token.html) as an argument:
   ```
   sudo ./create_vm_ubuntu_xrdp_flist.sh YOUR_API_KEY_HERE
   ```
   Replace `YOUR_API_KEY_HERE` with your actual ThreeFold Hub API key.

### Using Makefile

1. Clone this repository:
   ```
   git clone https://github.com/threefoldtech/tf-images
   cd ./tf-images/tfgrid3/ubuntu_24_xrdp
   ```

2. Run the build command using make:
   ```
   make build
   ```

3. When prompted, enter your ThreeFold ZOS Hub API key.

4. Wait for the script to complete. This may take some time depending on your internet connection and system performance.

5. Once completed, the script will have created and uploaded an flist named `ubuntu-24.04_vm_xrdp.tar.gz` to your ThreeFold Hub account.

## What the Script Does

1. Installs necessary packages
2. Creates a base Ubuntu system using debootstrap
3. Installs XFCE desktop environment and XRDP
4. Configures a non-root user for XRDP access
5. Sets up firewall rules
6. Creates and uploads the flist to the ThreeFold Hub

## Notes

- The default non-root user created is `xrdpuser` with password `xrdppassword`. It's recommended to change this password after first login.
  - Simply set the variable PASSWORD="your password here" when deploying the VM on the Dashboard
  - You can also update your password with the command `sudo passwd` on the VM
- The script requires an active internet connection throughout its execution.
- Ensure you have the latest version of the script by pulling from this repository before each use.

## Troubleshooting

If you encounter any issues:
1. Check your internet connection
2. Ensure you have sufficient disk space
3. Verify that you're using a valid ThreeFold API key
4. Review the script output for any error messages

For persistent issues, please open an issue in this GitHub repository.

## Clean Up

To remove the created files after running the script, you can use either of the following methods:

- Manual method:
```
sudo rm -rf ubuntu-noble
sudo rm -rf logs
sudo rm -rf wget-log
sudo rm ubuntu-24.04_vm_xrdp.tar.gz
```

- Using Makefile:
```
make delete
```

Both methods will remove the `ubuntu-noble` directory, the `ubuntu-24.04_vm_xrdp.tar.gz` file, and the `logs`.

## Server Side: Dashboard Deployment

Once the Flist is set, deploy it on the Dashboard via the Micro VM page.

- Go to the Micro VM page
- Under `VM Image`, select ̀`Other` and insert the Flist URL
- Under `Entry Point`, make sure that nothing is written
- Open the `Environment Variables` windows and set the environment variables:
  - Name: LOCALIP
  - Value: The local PC IP you're using
    - You can use `curl ifconfig.me` to see your public IP address
  - Name: PASSWORD
  - Value: The password you want for your xrdp user
- Choose a node with IPv4 network and click `Deploy`

## Client Side: Install Remote Desktop Connection for Windows, MAC or Linux

For the client side (the local computer accessing the VM remotely), you can use remote desktop connection for Windows, MAC and Linux. The process is very similar in all three cases.

Simply download the app, open it and write the IPv4 address of the VM. You then will need to write the username and password to enter into your VM.

### Download the App

* Client side Remote app
  * Windows
    * [Remote Desktop Connection app](https://apps.microsoft.com/store/detail/microsoft-remote-desktop/9WZDNCRFJ3PS?hl=en-ca&gl=ca&rtc=1)
  * MAC
    * Download in app store
      *  [Microsoft Remote Desktop Connection app](https://apps.apple.com/ca/app/microsoft-remote-desktop/id1295203466?mt=12)
  * Linux
    * [Remmina RDP Client](https://remmina.org/)
 
### Connect Remotely

* General process
  * In the Remote app, enter the following:
    * the IPv4 Address of the VM
    * the VM root-access username and password
  * You now have remote desktop connection to your VM

## License

This work is under the Apache 2.0 license.