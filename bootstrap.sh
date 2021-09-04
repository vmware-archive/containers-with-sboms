#!/usr/bin/env bash
#
# Copyright (c) 2021 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

# This script bootstraps a debian/bullseye64 Vagrant box
# to demo building containers with SBoMs

# Update repos and upgrade installed packages
apt-get update && sudo apt-get -y upgrade

# Install system dependencies
apt-get install -y python3 python3-pip python3-venv attr buildah podman git curl debootstrap jq

# Install tern
git clone https://github.com/tern-tools/tern
pushd tern
python3 setup.py sdist
pip3 install dist/tern*
popd

# Install oras
curl -LO https://github.com/oras-project/oras/releases/download/v0.12.0/oras_0.12.0_linux_amd64.tar.gz
mkdir -p oras-install/
tar -zxf oras_0.12.0_*.tar.gz -C oras-install/
mv oras-install/oras /usr/local/bin/
rm -rf oras_0.12.0_*.tar.gz oras-install/

# Add /home/vagrant/.local/bin and /usr/sbin to $PATH
echo "export PATH=/home/vagrant/.local/bin:/usr/sbin:$PATH" >> /home/vagrant/.bashrc
# Switch to the "vfs" storage driver for buildah and podman so we can get a consistent mount point
# for this version of buildah
echo "export STORAGE_DRIVER=vfs" >> /home/vagrant/.bashrc

# Create a debian rootfs
mkdir debian
debootstrap --variant=minbase stable debian http://deb.debian.org/debian/
cd debian/ && tar cf ../containers-with-sboms/debian.tar .
