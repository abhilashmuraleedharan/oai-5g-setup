# OAI 5G Setup

## Prerequisites

Before proceeding with the installation, ensure your system meets the following requirements:

- **Operating System**: Ubuntu 22.04 LTS Laptop/Desktop/Server for OAI CN5G and OAI gNB
- **CPU**: 8 cores x86_64 @ 3.5 GHz (supports AVX2)
- **RAM**: 32 GB
  
To check if your CPU supports AVX2, run:
```bash
lscpu | grep avx2
```
The user should have sudo privileges


### Installation Steps

#### Step 1: Clone this repo and cd into it
```bash
cd ~
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
Test the installation by running `docker run hello-world`

#### Step 3: Install OAI 5G Core
```bash
cd ~
git clone --branch v2.0.1 https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git
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

The Setup is now ready to do an E2E flow.

### Notes

The steps mentioned in this repository are as per the releases and tags available in February 2024.

### Contributions

We welcome contributions from the community! Please refer to the Contributing Guide for more details.

### License

This project is licensed under the MIT License - see the LICENSE file for details.
