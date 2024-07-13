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

echo ">>> Cloning OAI RAN Source Code and build ue and gnb executables"
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

echo ">>> Setup is now ready to test an E2E flow"

