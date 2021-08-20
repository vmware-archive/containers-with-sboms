#!/bin/sh
#
# Copyright (c) 2021 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

# This script will build a container image with an SBoM from scratch
# On successful completion we should have a debian base image,
# an SBOM file called "sbom1", and a config file called sbom_config.json

# We create a container image using buildah
echo starting...
ctr=$(buildah from scratch)
echo creating container...
mnt=$(buildah unshare buildah mount $ctr)
buildah add $ctr debian.tar
# We already know this is a debian 10 minbase rootfs so
# we will name the image accordingly
echo creating container image...
img=$(buildah commit $ctr localhost:5000/debian:10)

# The real directory where the data gets stored is somewhere else
realmnt=$(echo $mnt | sed 's/merged/diff/g')
# We then provide this directory to tern
tern report --live $realmnt -f spdxjson -o sbom1
echo image: localhost:5000/debian:10
echo sbom: sbom1
# Create a sbom config
echo {"sboms": [{"type": "SPDX", "describes": "debian:10", "host": "localhost:5000", "tool": "base_container.sh"}]} > sbom_config.json
echo sbom config: sbom_config.json
# Now push the image and the sbom
buildah push --tls-verify=false localhost:5000/debian:10
oras push localhost:5000/debian-sbom:10 --manifest-config sbom_config.json:application/vnd.vmware.sbom.config.v1+json sbom1:application/json
echo ready.
