#!/bin/bash
set -e

<<'EOF'
This script installs OAI 5G Core. 

Following are the prerequisites for the hardware
=================================================
    Operating system: Ubuntu 22.04 LTS
    Laptop/Desktop/Server for OAI CN5G and OAI gNB
    CPU: 8 cores x86_64 @ 3.5 GHz
    RAM: 32 GB

Make sure your laptop/remote server cpu supports avx2. You can check via lscpu | grep avx2
EOF

# Function to prompt for Docker credentials
get_docker_credentials() {
    read -p "Enter your DockerHub Account username: " DOCKER_USERNAME
    read -s -p "Enter your DockerHub Account password: " DOCKER_PASSWORD
    echo
}

# Function to perform Docker login
docker_login() {
    echo "Logging into Docker..."
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
}

# Function to pull Docker images
pull_docker_images() {
    IMAGES=(
        "mysql:8.0"
        "oaisoftwarealliance/oai-amf:v2.0.1"
        "oaisoftwarealliance/oai-nrf:v2.0.1"
        "oaisoftwarealliance/oai-upf:v2.0.1"
        "oaisoftwarealliance/oai-smf:v2.0.1"
        "oaisoftwarealliance/oai-udr:v2.0.1"
        "oaisoftwarealliance/oai-udm:v2.0.1"
        "oaisoftwarealliance/oai-ausf:v2.0.1"
        "oaisoftwarealliance/oai-upf-vpp:v2.0.1"
        "oaisoftwarealliance/oai-nssf:v2.0.1"
        "oaisoftwarealliance/oai-pcf:v2.0.1"
        "oaisoftwarealliance/oai-nef:v2.0.1"
        "oaisoftwarealliance/trf-gen-cn5g:latest"
    )

    for IMAGE in "${IMAGES[@]}"
    do
        echo "Pulling Docker image: $IMAGE"
        docker pull $IMAGE
    done
}

# Function to perform Docker logout
docker_logout() {
    echo "Logging out of Docker..."
    docker logout
}

echo ">>> Initiate pulling the required OAI 5G Core Docker images from docker registry"
get_docker_credentials
docker_login

if [ $? -eq 0 ]; then
    pull_docker_images
    docker_logout
else
    echo "Docker login failed. Exiting..."
    exit 1
fi

# Clone the OAI core network source code from gitlab to your PC (home location)
echo ">>> Cloning OAI Core Network Source Code and initiate installation procedures"
cd ~
git clone --branch v2.0.1 https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git
cd oai-cn5g-fed
# Checkout the source code to latest version (i.e., v2.0.1 as on 10 Feb 2024)
git checkout -f v2.0.1
# Synchronize all git submodules
./scripts/syncComponents.sh
# Enable packet forwarding
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT

echo ">>> Installation of complete. Test the setup by bringing up core"
cd oai-cn5g-fed/docker-compose
python3 core-network.py --type start-basic --scenario 1
