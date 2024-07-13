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
```

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
cd ~/oai-5g-setup/
sudo ./install_oai_5g_ran.sh
```
Note: This step will take a while to execute. Wait for the script to exit gracefully

### Notes

The steps mentioned in this repository are as per the releases and tags available in February 2024.

### Contributions

We welcome contributions from the community! Please refer to the Contributing Guide for more details.

### License

This project is licensed under the MIT License - see the LICENSE file for details.
