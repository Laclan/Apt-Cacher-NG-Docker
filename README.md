# tetio/apt-cacher-ng:2.0

- [Introduction](#introduction)
- [Getting Started](#getting-started)
  - [Building Image](#building-the-image)
    - [Repository added APT Backends](#docker-file-details)
    - [Scripts used during docker build](#build-scripts-that-are-used)
      - [ENTRYPOINT.sh](#entrypointsh)
      - [directory-build.sh](#directory-buildsh)
- [Quick Start](#quickstart)
- [Persistent Storage](#persistent-setup)
- [Docker Compose](#docker-compose)
- [Usage](#usage)
  - [Step 1](#step-1)
  - [Step 2](#step-2)
- [Change Log](#change-log)


# Introduction

Apt-Cacher NG is a caching proxy, specialized for package files from Linux distributors, primarily for [Debian](http://www.debian.org/) (and [Debian based](https://en.wikipedia.org/wiki/List_of_Linux_distributions#Debian-based)) distributions but not limited to those.

This is a custom `DockerFile` used to create a [Docker](https://www.docker.com/) container image for [Apt-Cacher NG](https://www.unix-ag.uni-kl.de/~bloch/acng/).

### Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).

# Getting started
## Building the Image

The `DockerFile` can be found under the [Image](https://gitea.master-docker-container.stoney.one/TetioKewl-DockerHub/Apt-Cacher-NG/src/branch/main/Image) section of this image.
~
You can run the script bellow to create a new version of the docker image with any modification that you have added.

    ./build-image.sh 

### Docker FIle Details
This Docker File has the [Proxmox HyperVisor](https://www.proxmox.com/en/proxmox-ve) and [Proxmox Backup Server](https://www.proxmox.com/en/proxmox-backup-server) Repository

| Distribution | URL Added | Location Files Added |
| ------------ | --------- | ---------------------|
| Proxmox HyperVisor | <http://download.proxmox.com/debian/pve> | backends_debian 
| Proxmox Backup Server | <http://download.proxmox.com/debian/pbs> | backends_debian

If you want any other specific repository added please create a [issue](https://github.com/Laclan/Apt-Cacher-NG-Docker/issues)


### Build Scripts that are used
#### Entrypoint.sh
The `entrypoint.sh` is used to execute the APT-Cacher-NG Service

#### Directory-build.sh
The `directory-build.sh` is used to setup the following directorys
- `pid`
- `cache`
- `logs`

It also setups the directory for the correct permission for writing the required files for the container

## Quickstart

Start Apt-Cacher NG using the `Docker-Compose.yml` file located under the [Apt-Cache-NG-Compose](https://gitea.master-docker-container.stoney.one/TetioKewl-DockerHub/Apt-Cacher-NG/src/branch/main/Apt-Cacher-NG-Compose).

The Compose file can be modifed and then ran via

Docker Compose

    Docker-Compose Up -d

Docker Compose Script

    ./Deploy-Container.sh

# Persistent Setup
## Docker Compose

To run Apt-Cacher NG with Docker Compose, create the following `docker-compose.yml` file with a `.env` file for variablibles
  
### Docker compose
  ```yaml
version: "3"

services:
  apt-cacher-ng:
    image: custom-apt-cacher-ng:latest
    container_name: apt-cacher-ng
    restart: unless-stopped
    env_file:
    - .env
    volumes:
    # Mapping for the Cache Directory
      - "${VOL_PATH}/cache:/var/cache/apt-cacher-ng"
    # Mapping for the Logs Folder
      - "${VOL_PATH}/logs:/var/log/apt-cacher-ng"
    # Mapping the Local ACNG Conf File to the Container ACNG.conf file
      - "${ACNGCONF_PATH}/acng.conf:/etc/apt-cacher-ng/acng.conf:ro"
    ports:
      - 3142:3142/tcp

```
### .env

```properties
VOL_PATH=/Docker-Local-Storage/APT-Cacher-NG
ACNGCONF_PATH=/Docker-Compose-Files/Apt-Cacher-NG/Apt-Cacher-NG-Compose
```

### acng.conf
The `acng.conf` file is the main configuration file for apt-cacher-ng, this is were all of the settings are put into the APT-Cacher-NG Service.

The file location is set under the `dockercompose.yml` via a combonation of `.env` file setting `ACNGCONF_PATH` and the local `acng.conf` file.

Link to documented version of the `acng.conf` under the Documentation Section

Link to my personal `acng.conf` file is located under the compose section
# Usage
To start using Apt-Cacher NG on your Debian (and Debian based) host you either need to setup a HTTP Proxy forward or direct mapping under the APT `sourcelists` file.

This method will use the HTTP Proxy Forward method as we can automate the detection of the apt proxy via shell scripts.

### Step 1
Save and make executable the `apt-proxy-detect.sh` file located under the [Apt-Proxy-Setup](https://gitea.master-docker-container.stoney.one/TetioKewl-DockerHub/Apt-Cacher-NG/src/branch/main/Apt-Proxy-Setup)

This script performs a port check of the `Apt-Cacher-NG` proxy each time you perform a APT update or install or upgrade. You can change both the port and IP via the Variable to specific your apt-cacher-ng location.

```bash
# !/bin/bash
# Apt Cacher NG
IP=10.27.30.200
PORT=3142
if nc -w1 -z $IP $PORT; then
    echo -n "http://${IP}:${PORT}"
else
    echo -n "DIRECT"
```

### Step 2
Save the `01proxy` file located under the [Apt-Proxy-Setup](https://gitea.master-docker-container.stoney.one/tetio/DockerCompose-DockerMasterController/src/branch/master/Apt-Cacher-NG/Apt-Proxy-Setup)

This file will tell apt that we have to go though a HTTP Proxy for all apt requests. The File will then execute the script and if the Apt-Cacher-NG Container is up it will pull though cache and if down will pull straight from the web.

```properties
# This Points to the Script
Acquire::http::Proxy-Auto-Detect "/mnt/apt-script/apt-proxy-detect.sh";
```
# Ansible Scripting for Injection of the Files

This Apt Caching Components can be automaticly setup from Ansible Playbook.

## The Script:
```bash
#!/bin/bash
ansible-playbook -T 30 -b --ask-become-pass --ask-pass  ~/Apt-Proxy-Setup/update-services.sh
```
## Ansible Playbook
```yml
- hosts: 
# Setup the Hosts for the scripting to be executing
  ignore_unreachable: yes
  tasks:
  - name: Create a directory apt-script if it does not exist
    ansible.builtin.file:
      path: /mnt/apt-script
      state: directory
      mode: '0777'
  - name: Copy Script to System
    ansible.builtin.copy:
      src: ~/Apt-Proxy-Setup/apt-proxy-detect.sh
      dest: /mnt/apt-script/apt-proxy-detect.sh
      owner: root
      mode: '0777'
  - name: Make Proxy File
    ansible.builtin.copy:
      src: ~/Apt-Proxy-Setup/01proxy
      dest: /etc/apt/apt.conf.d
      owner: root
      mode: '0777'
```
# Change Logs

- Monday, 26 December 2022
  - First Commit to Github