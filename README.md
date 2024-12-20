# OAI 5G Core Lab Setup Guide

This repository is created as a guide for setting up your own OpenAirInterface (OAI) 5G Core Lab. It includes detailed instructions and scripts to help you deploy the OAI 5G Core on an AWS instance, configure the network components, and run experiments. The goal is to provide a comprehensive resource for anyone looking to explore and experiment with 5G network technologies using OAI.

### Prerequisites
Before proceeding with the installation, ensure your system meets the following requirements:

- **Operating System**: Ubuntu 22.04 LTS Laptop/Desktop/Server for OAI CN5G and OAI gNB
- **CPU**: 8 cores x86_64 @ 3.5 GHz (supports AVX2)
- **RAM**: 32 GB

To check if your CPU supports AVX2, run:
```bash
lscpu | grep avx2
```
The user should have sudo privileges

### Using an EC2 Instance
If your machine doesn't have the required specifications, you can set up an Ubuntu EC2 instance in the cloud. Follow this [YouTube tutorial](https://www.youtube.com/watch?v=osqZnijkhtE) to understand how to set up your own Ubuntu EC2 instance.

#### Recommended Settings for EC2 Instance for OAI Lab:
1. **Choose `Ubuntu 22.04 LTS`** instead of the latest one.
2. **Instance Type**: Select `t2.2xlarge`.
3. **Key Pair**: Choose `ED25519`.
4. **Security Group**: Allow SSH traffic from anywhere. Note: You can limit the allowed ssh traffic to your instance if you got a static IP address to configure.

Keep the key file you downloaded in your user's `.ssh` folder and opt for X11 Forwarding in your SSH client (e.g., MobaXterm) before starting an SSH session.

### Initial Setup
Once you have logged into your ubuntu server using ssh, you can follow the installation steps give below.

### Installation Steps

#### Step 1: Clone this repo and cd into it
```bash
cd ~
sudo apt install git
git clone https://github.com/abhilashmuraleedharan/oai-5g-setup.git
cd oai-5g-setup
```

#### Step 2: Install Docker
```bash
sudo ./install_docker.sh

# Create the docker group
sudo groupadd docker

# Add your user to the docker group
sudo usermod -aG docker $USER
newgrp docker

# Configure Docker to start on boot
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```
Reboot and check whether docker service is running after system restart by executing `docker run hello-world`. 

#### Step 3: Install OAI 5G Core
```bash
cd ~
git clone --branch develop https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git
cd ~/oai-5g-setup/
sudo ./install_oai_5g_core.sh
```

Start the core by executing below steps
```bash
cd ~/oai-cn5g-fed/docker-compose
python3 core-network.py --type start-basic --scenario 1
```
Verify all the core components are running fine by checking the output of `docker ps`

Note: If the Ubuntu OS version is later than 22.04 then you will need to update the `core-network.py`
script to use `docker compose` command instead of `docker-compose` command. 

#### Step 4: Install OAI 5G RAN
```bash
cd ~
git clone https://gitlab.eurecom.fr/oai/openairinterface5g.git
cd openairinterface5g
git checkout develop
source oaienv
sudo apt-get install -y libforms-dev
sudo apt-get install -y zlib1g-dev
cd cmake_targets
sudo ./build_oai -I
sudo ./build_oai --gNB --nrUE --build-lib nrscope
cd ran_build/build
sudo make rfsimulator
```
You should see the `nr-softmodem` and `nr-uesoftmodem` executables after compilation in the `build` directory

#### Step 5: Validate the setup
Exit/Close the current terminal session. Login to the server again by opening a fresh terminal session.

The Setup is now ready to do an E2E flow. The `single-ue-testing.txt` file is a good place to start.

### Notes

The steps mentioned in this repository are as per the releases and tags available in [Openairinterface 5G Project](https://gitlab.eurecom.fr/oai/openairinterface5g) on February 2024.

### Contributions

We welcome contributions from the community! Please refer to the Contributing Guide for more details.

### License

This project is licensed under the MIT License - see the LICENSE file for details.
