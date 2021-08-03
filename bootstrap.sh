#!/usr/bin/env bash
#
# Copyright (c) 2021 VMware, Inc. All Rights Reserved.
# SPDX-License-Identifier: BSD-2-Clause

# This script bootstraps a debian/bullseye64 Vagrant box
# to demo building containers with SBoMs

# Update repos and upgrade installed packages
sudo apt-get update && sudo apt-get -y upgrade

# Install system dependencies
sudo apt-get install -y python3 python3-pip python3-venv attr buildah podman git curl debootstrap

# Install go1.16.6
curl -LO https://golang.org/dl/go1.16.6.src.tar.gz
mkdir -p go-install
tar -xvf go1.16.6.src.tar.gz -C go-install/

# Install tern
git clone https://github.com/tern-tools/tern
cd tern
python3 setup.py sdist
pip3 install dist/tern*

# Install oras
curl -LO https://github.com/oras-project/oras/releases/download/v0.12.0/oras_0.12.0_linux_amd64.tar.gz
mkdir -p oras-install/
tar -zxf oras_0.12.0_*.tar.gz -C oras-install/
sudo mv oras-install/oras /usr/local/bin/
rm -rf oras_0.12.0_*.tar.gz oras-install/

# Spin up distribution (docker) registry
podman pull registry:2.7.1
podman run -d -p 5000:5000 --restart always --name registry registry:2.7.1

# Add /home/vagrant/.local/bin and /usr/sbin to $PATH
echo "export PATH=/home/vagrant/.local/bin:/usr/sbin:$PATH" >> /home/vagrant/.bashrc
