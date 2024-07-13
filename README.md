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

#### Step 1: Install Docker
```bash
sudo ./install_docker.sh
```

#### Step 2: Install OAI 5G Core
```bash
sudo ./install_oai_5g_core.sh
```
Verify all the core components are running fine by checking the output of `docker ps`

#### Step 3: Install OAI 5G RAN
```bash
sudo ./install_oai_5g_ran.sh
```

### Notes

The steps mentioned in this repository are as per the releases and tags available in February 2024.

### Contributions

We welcome contributions from the community! Please refer to the Contributing Guide for more details.

### License

This project is licensed under the MIT License - see the LICENSE file for details.
