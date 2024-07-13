#!/bin/bash
set -e

# This script installs docker on a fresh Ubuntu server specifically OS version Ubuntu 22.04 LTS
echo ">>> installing python3"
sudo apt install python3

echo ">>> checking installed python version"
python3 --version

echo ">>> installing git net-tools and putty"
sudo apt-get update
sudo apt install -y git net-tools putty

echo ">>> Setting up Docker's apt repository"
sudo apt-get install -y ca-certificates curl

echo ">>> Adding Docker's official GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo ">>> Adding the repository to Apt sources"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>> Updating the apt package index"
sudo apt-get update

echo ">>> Installing the Docker packages"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

echo ">>> Verifying whether docker is installed properly"
sudo docker run hello-world
