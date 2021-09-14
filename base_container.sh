#!/bin/sh
#
# Copyright (c) 2021 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

# This script will build a container image with an SBoM from scratch
# On successful completion we should have a debian base image,
# an SBOM file called "sbom1", and a config file called sbom_config1.json

# We create a container image using buildah
echo starting...
ctr=$(buildah from scratch)
echo creating container image...
mnt=$(buildah unshare buildah mount $ctr)
buildah add $ctr debian.tar

# We use a specific debian snapshot
# we will name the image accordingly
img=$(buildah commit $ctr localhost:5000/debian:20210914T205414Z)

# We then provide this directory to tern
echo generating sbom...
tern report --live $mnt -f spdxjson -o debian-sbom
echo image: localhost:5000/debian:20210914T205414Z
echo sbom: debian-sbom

# Now push the image and the sbom
buildah push --tls-verify=false localhost:5000/debian:20210914T205414Z
oras push localhost:5000/debian:20210914T205414Z-sbom debian-sbom:application/json

# Let's sign our artifacts
# This assumes a cosign keypair has been generated and exists
# in a directory called "cosign"
cosign sign -key ~/cosign/cosign.key localhost:5000/debian:20210914T205414Z
cosign sign -key ~/cosign/cosign.key localhost:5000/debian:20210914T205414Z-sbom

# clean up all the running containers
buildah rm --all
rm debian-sbom
echo ready.
